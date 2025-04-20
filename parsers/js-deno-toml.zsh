if [[ -f ./toolchain/deno/bin/deno ]]; then
	path+=($PWD/toolchain/deno/bin)
fi

deps() { print 'deno' }

setup() {
	cp ../../scripts/deno-toml-* .
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
	decoder 'deno-toml-decoder.ts'
	encoder 'deno-toml-encoder.ts'
	perf    'TODO'
	flags   '-int-as-float=1'
)
