deps() { print 'opam' }

setup() {
	opam init -a --disable-shell-hook
	eval $(opam env)
	opam -y pin --with-test add .

	opam install -y yojson zarith decimal ocamlfind
	ocamlfind ocamlopt -package otoml,zarith,decimal,yojson -linkpkg ./examples/testsuite_client_decoder.ml -o decoder
	ocamlfind ocamlopt -package otoml,zarith,decimal,yojson -linkpkg ./examples/testsuite_client_encoder.ml -o encoder
}

typeset -A info=(
	lang    'OCAML'
	toml    '1.0'
	site    'https://github.com/dmbaturin/otoml'
	src     'https://github.com/dmbaturin/otoml.git'
	decoder 'decoder'
	encoder 'encoder'
	perf    'TODO'
)
