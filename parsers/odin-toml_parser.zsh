if [[ -f ./toolchain/odin/odin ]]; then
	path+=($PWD/toolchain/odin)
fi

deps() { print 'odin' }

setup() {
	odin build . -out:toml_parser
}

typeset -A info=(
	lang    'Odin'
	toml    '1.0'
	site    'https://github.com/Up05/toml_parser'
	src     'https://github.com/Up05/toml_parser'
	decoder 'toml_parser'
	encoder ''
	perf    'TODO'
)
