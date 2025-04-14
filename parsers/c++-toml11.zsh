deps() { print 'c++ cmake' }

# C++ compiler is slower than a blind crippled tortoise, so we need all these
# stupid tricks if we don't want to wait 40 seconds...
setup() {
	git submodule update --init --recursive
	cmake -B build -DTOML11_BUILD_TOML_TESTS=ON
	cmake --build ./build -j4

	if [[ ! -e c++-toml11-perf.cpp ]] || \
			[[ "$(sha256sum <<<$(< c++-toml11-perf.cpp))" != "$(sha256sum <<<$(< ../../scripts/c++-toml11-perf.cpp))" ]]; then
			cp ../../scripts/c++-toml11-perf.cpp .
	fi
	if [[ ! -e perf ]] || [[ c++-toml11-perf.cpp -nt perf ]]; then
			c++ -I./include -std=c++17 -O2 c++-toml11-perf.cpp -o perf
	fi
}

typeset -A info=(
	lang    'C++'
	toml    '1.0'
	site    'https://github.com/ToruNiina/toml11'
	src     'https://github.com/ToruNiina/toml11.git'
	decoder 'build/tests/toml11_decoder'
	encoder 'build/tests/toml11_encoder'
	perf    'perf'
)
