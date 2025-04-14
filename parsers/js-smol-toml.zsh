deps() { print 'node npm pnpm' }

setup() {
	npm install
	npm run build
	cp ../../scripts/js-smol-toml-* .
}

typeset -A info=(
	lang    'JS'
	toml    '1.0'
	site    'https://github.com/squirrelchat/smol-toml'
	src     'https://github.com/squirrelchat/smol-toml.git'
	decoder 'toml-test-parse.mjs'
	encoder 'toml-test-encode.mjs'
	perf    'js-smol-toml-perf.mjs'
	flags   '-int-as-float=1'
)
