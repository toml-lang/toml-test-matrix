deps() { print 'cabal' }

setup() {
	cabal update

	grep 'buildable: False' toml-parser.cabal &&
		sed -i.orig 's/buildable: False/buildable: True/' toml-parser.cabal

	cd test-drivers
	cabal configure
	cabal build
	cd ..
	cabal configure
	cabal build

	# What a path... Copy it to something vaguely managable.
	cp dist-newstyle/build/x86_64-linux/ghc-*/toml-test-drivers-*/x/TomlDecoder/build/TomlDecoder/TomlDecoder .
	cp dist-newstyle/build/x86_64-linux/ghc-*/toml-test-drivers-*/x/TomlEncoder/build/TomlEncoder/TomlEncoder .
	cp dist-newstyle/build/x86_64-linux/ghc-*/toml-parser-*/x/toml-benchmarker/build/toml-benchmarker/toml-benchmarker .
}

typeset -A info=(
	# Stopped building for mysterious reasons. God I'm so tired of Haskell
	# throwing a hissy fit every other day. Horrible ecosystem and I'm done
	# dealing with it.
	skip 1

	lang    'Haskell'
	toml    '1.0'
	site    'https://github.com/glguy/toml-parser'
	src     'https://github.com/glguy/toml-parser.git'
	decoder 'TomlDecoder'
	encoder 'TomlEncoder'
	perf    'toml-benchmarker'
)
