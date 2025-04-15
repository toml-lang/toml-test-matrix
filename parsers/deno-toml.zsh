if [[ -f ./toolchain/deno/bin/deno ]]; then
	path+=($PWD/toolchain/deno/bin)
fi

deps() { print 'deno' }

setup() {
	cp ../../scripts/deno-toml-* .
}

typeset -A info=(
	lang    'Deno'
	toml    '1.0'
	site    'https://jsr.io/@std/toml'
	src     'https://github.com/denoland/std'
	decoder 'deno-toml-decoder.ts'
	encoder 'deno-toml-encoder.ts'
	perf    'TODO'
	flags   '-int-as-float=1'
)
