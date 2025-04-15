# TODO: also needs lua-5.3-devel and lua-cjson
deps() { print 'lua ' }

setup() {
	cp ../../scripts/lua-tinytoml-decoder .
}

typeset -A info=(
	lang    'Lua'
	toml    '1.0'
	site    'https://github.com/FourierTransformer/tinytoml'
	src     'https://github.com/FourierTransformer/tinytoml'
	decoder 'lua-tinytoml-decoder'
	encoder ''
	perf    'TODO'
)
