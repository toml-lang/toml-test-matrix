if [[ -f ./toolchain/deno/bin/deno ]]; then
	path+=($PWD/toolchain/deno/bin)
fi
export DENO_NO_UPDATE_CHECK=1

deps() { print 'deno' }

setup() {
	cp ../../scripts/js-deno-toml-* .
}

# These lines are added inconsistently to the stack traces.
after-run() {
	sed -Ei '/ at eventLoopTick /d' output/js-deno-toml.html
}

typeset -A info=(
	lang    'JS'
	toml    '1.0'
	site    'https://jsr.io/@std/toml'
	src     'https://github.com/denoland/std'
	decoder 'js-deno-toml-decoder.ts'
	encoder 'js-deno-toml-encoder.ts'
	perf    'js-deno-toml-perf.ts'
	flags   '-int-as-float=1'
)
