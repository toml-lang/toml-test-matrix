if [[ -f ./toolchain/swift/bin/swift ]]; then
	path+=($PWD/toolchain/swift/bin)
fi

deps() { print 'swift' }

setup() {
	swift build
	cp .build/x86_64-unknown-linux-gnu/debug/compliance .
}

typeset -A info=(
	lang    'Swift'
	toml    '1.0'
	site    'https://github.com/dduan/TOMLDecoder'
	src     'https://github.com/dduan/TOMLDecoder'
	decoder 'compliance'
	encoder ''
	perf    'TODO'
)
