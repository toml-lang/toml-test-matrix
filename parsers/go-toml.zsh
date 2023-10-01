setup() {
	go build ./cmd/toml-test-decoder
	go build ./cmd/toml-test-encoder
	go build ./cmd/tomlv
}

typeset -A info=(
	lang    'Go'
	toml    '1.0'
	site    'https://github.com/burntSushi/toml'
	src     'git@github.com:BurntSushi/toml.git'
	version ''
	decoder 'toml-test-decoder'
	encoder 'toml-test-encoder'
	perf    'tomlv'
)
