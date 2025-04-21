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

	# This gets output as "[[[[{}]]]]" rather than "[[[[[]]]]]" because Lua
	# "arrays" are just tables where the keys are numbers. For empty tables
	# there is no real way to know if it's supposed to be an array or not.
	#
	# There isn't really a good way to fix this and is just a limitation of Lua
	# that exists in various parsers. For the purpose of toml-test-matrix, I
	# think it's fine to just skip it.
	flags   '-skip valid/array/empty -skip valid/inline-table/array-02'
)
