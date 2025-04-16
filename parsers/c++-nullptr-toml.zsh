deps() { print 'cmake c++' }

setup() {
	cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
	cmake --build build

	cp ../../scripts/c++-nullptr-toml-decoder .
}

typeset -A info=(
	lang    'C++'
	toml    '1.0'
	site    'https://github.com/nullptr-0/toml'
	src     'https://github.com/nullptr-0/toml'
	decoder 'c++-nullptr-toml-decoder'
	encoder ''
	perf    'TODO'
)
