export RUBYLIB=./src/ruby-perfect_toml/lib

# TODO: also needs ruby-devel, but can't easily check that here as it only
# checks $PATH.
deps() { print 'ruby bundle' }

setup() {
	bundle config set --local path ~/.local/share/gem
	bundle
	cp ../../scripts/ruby-perfect_toml-perf .
}

typeset -A info=(
	lang    'Ruby'
	toml    '1.0'
	site    'https://github.com/mame/perfect_toml'
	src     'https://github.com/mame/perfect_toml.git'
	decoder 'tool/decoder.rb'
	encoder 'tool/encoder.rb'
	perf    'ruby-perfect_toml-perf'
)
