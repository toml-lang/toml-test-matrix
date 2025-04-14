deps() { print 'cabal' }

setup() { }

typeset -A info=(
	# TODO: this doesn't seem to have anything for integrating with toml-test.
	skip    '1'

	lang    'Haskell'
	toml    '1.0'
	site    'https://github.com/kowainik/tomland'
	src     'https://github.com/kowainik/tomland.git'
	decoder ''
	encoder 'TODO'
	perf    ''
)
