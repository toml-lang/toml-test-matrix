export RUBYLIB=~/.cache/gem/ruby/3.2.0/gems/citrus-3.0.2/lib:$PWD/src/ruby-toml-rb/lib

deps() { print 'ruby bundle' }

setup() {
	bundle config set --local path ~/.local/share/gem
	bundle
	cp ../../scripts/ruby-toml-rb-decoder .
	cp ../../scripts/ruby-toml-rb-encoder .
	cp ../../scripts/ruby-toml-rb-perf .
}

typeset -A info=(
	lang    'Ruby'
	toml    '1.0'
	site    'https://github.com/emancu/toml-rb'
	src     'https://github.com/emancu/toml-rb.git'
	decoder 'ruby-toml-rb-decoder'
	encoder 'ruby-toml-rb-encoder'
	perf    'ruby-toml-rb-perf'
)
