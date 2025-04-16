export RUBYLIB=$PWD/src/ruby-tomlrb/lib

deps() { print 'ruby bundle' }

setup() {
	bundle config set --local path ~/.local/share/gem
	bundle
	cp ../../scripts/ruby-tomlrb-decoder .
	cp ../../scripts/ruby-tomlrb-perf .
}

typeset -A info=(
	lang    'Ruby'
	toml    '1.0'
	site    'https://github.com/fbernier/tomlrb'
	src     'https://github.com/fbernier/tomlrb.git'
	decoder 'ruby-tomlrb-decoder'
	encoder ''
	perf    'ruby-tomlrb-perf'
)
