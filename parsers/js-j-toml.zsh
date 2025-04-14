deps() { print 'node' }

setup() {
	cp ../../scripts/js-toml-j-* .
}

typeset -A info=(
	lang    'JS'
	toml    '1.0'
	site    'https://github.com/LongTengDao/j-toml'
	src     'https://github.com/LongTengDao/j-toml.git'
	decoder 'js-toml-j-decode'
	encoder 'js-toml-j-encode'
	perf    'js-toml-j-perf'
)
