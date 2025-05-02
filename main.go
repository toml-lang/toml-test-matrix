package main

import (
	"archive/zip"
	"bytes"
	"cmp"
	_ "embed"
	"encoding/json"
	"errors"
	"fmt"
	"html"
	"html/template"
	"io"
	"net/http"
	"os"
	"slices"
	"strings"
	"sync"
	"time"

	"github.com/BurntSushi/toml"
	tomltest "github.com/toml-lang/toml-test"
	"zgo.at/hubhub"
	"zgo.at/jfmt"
	"zgo.at/zstd/zmap"
)

//go:embed index.gohtml
var index []byte

var indexTpl = template.Must(template.New("").
	Option("missingkey=error").
	Funcs(template.FuncMap{
		"compliant": func(p parser) template.HTML {
			if !p.Tested {
				return "<span title='Not tested'>❔</span>"
			}
			if p.Tests.FailedValid == 0 {
				return "<span title='Compliant'>✅</span>"
			}
			return "<span title='Non-compliant'>❌</span>"
		},
		"bars": func(passed, failed int, mute bool) template.HTML {
			passw := 100.0
			failw := 0.0

			if failed > 0 {
				failw = float64(failed) / float64(passed+failed) * 100.0
				passw = 100 - failw
			}

			var (
				allpass   = "allpass"
				barf      = "barf"
				failclass string
			)
			if failed > 0 {
				allpass = ""
				failclass = "didfail"
				if mute {
					failclass += "-mute"
					barf += " barf-mute"
				}
			}

			return template.HTML(fmt.Sprintf(`
				<div class="bars">
					<span class="barp %s" style="width:%f%%"></span><span class="%s" style="width:%f%%"></span>
				</div>
				<small class="pass">pass: %d</small>
				<span class="fail %s">fail: %d</span>
			`, allpass, passw, barf, failw, passed, failclass, failed))
		},
	}).
	Parse(string(index)))

type artifact struct {
	ID                 int64     `json:"id"`
	Name               string    `json:"name"`
	CreatedAt          time.Time `json:"created_at"`
	ArchiveDownloadURL string    `json:"archive_download_url"`
	SizeInBytes        int64     `json:"size_in_bytes"`
	WorkflowRun        struct {
		ID      int64  `json:"id"`
		HEADSha string `json:"head_sha"`
	} `json:"workflow_run"`
}

type (
	parser struct {
		Lang string `toml:"lang"`
		Name string `toml:"name"`
		Src  string `toml:"src"`

		Tested bool  `toml:"-"`
		Tests  Tests `toml:"-"`
		HasEnc bool  `toml:"-"`
	}
	Tests struct {
		tomltest.Tests
		Encoder []string `json:"encoder"`
		Version string   `json:"version"`
		TOML    string   `json:"toml"`
	}
)

func main() {
	hubhub.Token = strings.TrimSpace(os.Getenv("GITHUB_TOKEN"))
	if hubhub.Token == "" {
		// GitHub won't let unauthed users get artifacts; for public repos
		// anyone can see them with a token, but do need that token :-/
		// https://github.com/actions/upload-artifact/issues/51
		fmt.Fprintln(os.Stderr, "Must set GITHUB_TOKEN to a personal access token.\n"+
			"The token needs to have 'public_repo' permission.")
		os.Exit(1)
	}

	if err := os.MkdirAll("output", 0o755); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	var parsers struct {
		Tested   []parser `toml:"tested"`
		Untested []parser `toml:"untested"`
	}
	_, err := toml.DecodeFile("parsers.toml", &parsers)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	var (
		mu      sync.Mutex
		wg      sync.WaitGroup
		haveErr = false
		langs   = make(map[string]struct{})
	)
	wg.Add(len(parsers.Tested))
	for i, p := range parsers.Tested {
		langs[p.Lang] = struct{}{}
		r := strings.Trim(strings.TrimPrefix(p.Src, "https://github.com/"), "/")

		go func() {
			defer wg.Done()
			var list struct {
				TotalCount int        `json:"total_count"`
				Artifacts  []artifact `json:"artifacts"`
			}
			_, err := hubhub.Request(&list, "GET", "https://api.github.com/repos/"+r+"/actions/artifacts", nil)
			if err != nil {
				fmt.Fprintf(os.Stderr, "fetching artifacts list for %q: %v\n", r, err)
				haveErr = true
				return
			}

			for _, a := range list.Artifacts {
				if !strings.HasPrefix(a.Name, "toml-test") {
					continue
				}

				// TODO: download all from the same group/run and merge them:
				// "name": "toml-test_2025-04-28T06-50-04.055Z_6752cc7_windows_amd64",
				// "name": "toml-test_2025-04-28T06-49-26.887Z_6752cc7_darwin_arm64",
				// "name": "toml-test_2025-04-28T06-49-03.458Z_6752cc7_linux_amd64",
				tests, err := fetchReport(a)
				if err != nil {
					fmt.Fprintf(os.Stderr, "processing artifact for %q: %v\n", r, err)
					haveErr = true
					break
				}

				mu.Lock()
				parsers.Tested[i].Tested = true
				parsers.Tested[i].Tests = tests
				mu.Unlock()

				buf := new(bytes.Buffer)
				writeReport(buf, p, tests, a)
				err = os.WriteFile(fmt.Sprintf("output/%s-%s.html", p.Lang, p.Name), buf.Bytes(), 0o644)
				if err != nil {
					fmt.Fprintf(os.Stderr, "processing artifact for %q: %v\n", r, err)
					haveErr = true
					break
				}
				break
			}
		}()
	}
	wg.Wait()

	all := append([]parser{}, parsers.Tested...)
	for _, p := range parsers.Untested {
		langs[p.Lang] = struct{}{}
		all = append(all, p)
	}
	slices.SortFunc(all, func(a, b parser) int { return cmp.Compare(a.Name, b.Name) })
	slices.SortStableFunc(all, func(a, b parser) int { return cmp.Compare(a.Lang, b.Lang) })

	buf := new(bytes.Buffer)
	err = indexTpl.Execute(buf, struct {
		Langs   []string
		Parsers []parser
		Now     time.Time
	}{zmap.KeysOrdered(langs), all, time.Now().UTC()})
	if err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
		haveErr = true
	}

	err = os.WriteFile("index.html", buf.Bytes(), 0o644)
	if err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
		haveErr = true
	}

	if haveErr {
		os.Exit(1)
	}
}

func fetchReport(a artifact) (Tests, error) {
	r, err := hubhub.Request(nil, "GET", a.ArchiveDownloadURL, nil)
	if err != nil {
		return Tests{}, err
	}
	if r.StatusCode != 302 {
		return Tests{}, fmt.Errorf("unexpected status: %s", r.Status)
	}

	l := r.Header.Get("Location")
	if l == "" || !strings.HasPrefix(l, "http") {
		return Tests{}, fmt.Errorf("empty or unexpected Location: header: %s", r.Status)
	}

	tmp, err := os.CreateTemp("", "toml-test-*")
	if err != nil {
		return Tests{}, err
	}
	defer os.Remove(tmp.Name())

	resp, err := http.DefaultClient.Get(l)
	if err != nil {
		return Tests{}, err
	}
	defer resp.Body.Close()
	_, err = io.Copy(tmp, resp.Body)
	if err != nil {
		return Tests{}, err
	}
	err = tmp.Close()
	if err != nil {
		return Tests{}, err
	}

	tmp, err = os.Open(tmp.Name())
	if err != nil {
		return Tests{}, err
	}
	defer tmp.Close()

	z, err := zip.NewReader(tmp, a.SizeInBytes)
	if err != nil {
		return Tests{}, err
	}
	if len(z.File) == 0 {
		return Tests{}, errors.New("no files in ZIP?")
	}

	if len(z.File) != 1 || z.File[0].Name != "_toml-test_.json" {
		var all []string
		for _, f := range z.File {
			all = append(all, f.Name)
		}
		return Tests{}, fmt.Errorf("unexpected files in ZIP: %s", all)
	}

	src, err := z.File[0].Open()
	if err != nil {
		return Tests{}, err
	}
	defer src.Close()

	dst := new(bytes.Buffer)
	_, err = io.Copy(dst, src)
	if err != nil {
		return Tests{}, err
	}

	var tests Tests
	err = json.Unmarshal(dst.Bytes(), &tests)
	if err != nil {
		return Tests{}, err
	}

	return tests, nil
}

func writeReport(w io.Writer, p parser, tests Tests, a artifact) {
	fmt.Fprintln(w, `<style>
		html     { font:16px/1.4rem sans-serif; }
		div      { }
		h3       { margin-left:2rem; background:#ffe3e3; padding:.5rem .4rem; }
		h4       { margin-left:3rem; }
		div >pre { margin-left:5rem; }
	</style>`)

	fmt.Fprintf(w, "<pre>%s\n%s %s (%s)\nrun on %s\n\n",
		tests.Version, p.Name, a.WorkflowRun.HEADSha[:7], p.Src, a.CreatedAt)
	if tests.Skipped > 0 {
		fmt.Fprintf(w, "skipped tests: %d\n", tests.Skipped)
	}
	fmt.Fprintf(w, "  valid tests: %3d passed, %2d failed\n", tests.PassedValid, tests.FailedValid)
	fmt.Fprintf(w, "invalid tests: %3d passed, %2d failed\n\n</pre>", tests.PassedInvalid, tests.FailedInvalid)

	var failedValid, failedInvalid, failedEncoder []int
	for i, t := range tests.Tests.Tests {
		if !t.Failed() {
			continue
		}
		switch {
		case t.Encoder():
			failedEncoder = append(failedEncoder, i)
		case t.Invalid():
			failedInvalid = append(failedInvalid, i)
		default:
			failedValid = append(failedValid, i)
		}
	}

	if len(failedValid) > 0 {
		fmt.Fprint(w, "<h2>FAILED VALID TESTS</h2>\n\n")
		for _, i := range failedValid {
			failure(w, tests.Tests.Tests[i])
		}
	}
	if len(failedEncoder) > 0 {
		fmt.Fprint(w, "<h2>FAILED ENCODER TESTS</h2>\n\n")
		for _, i := range failedEncoder {
			failure(w, tests.Tests.Tests[i])
		}
	}
	if len(failedInvalid) > 0 {
		fmt.Fprint(w, "<h2>FAILED INVALID TESTS</h2>\n\n")
		for _, i := range failedInvalid {
			failure(w, tests.Tests.Tests[i])
		}
	}
}

func failure(w io.Writer, t tomltest.Test) {
	fmt.Fprintf(w, "<div>\n<h3>%s</h3>\n", html.EscapeString(t.Path))

	if t.Failed() {
		fmt.Fprintf(w, "<pre>%s</pre>\n", html.EscapeString(t.Failure))
	}
	showStream(w, "input sent to parser-cmd", t.Input)

	out, err := jfmt.NewFormatter(0, "", "  ").FormatString(t.Output)
	if err == nil {
		t.Output = out
	}

	if t.OutputFromStderr {
		showStream(w, "output from parser-cmd (stderr)", t.Output)
	} else {
		showStream(w, "output from parser-cmd (stdout)", t.Output)
	}
	if t.Type() == tomltest.TypeValid {
		showStream(w, "want", t.Want)
	} else {
		showStream(w, "want", "Exit code 1")
	}
	fmt.Fprint(w, "\n</div>\n\n")
}

func showStream(w io.Writer, name, s string) {
	fmt.Fprintf(w, "\n<h4>%s</h4>\n", html.EscapeString(name))
	if s == "" {
		fmt.Fprintln(w, "<empty>")
		return
	}
	fmt.Fprintf(w, "<pre>%s</pre>", html.EscapeString(s))
}
