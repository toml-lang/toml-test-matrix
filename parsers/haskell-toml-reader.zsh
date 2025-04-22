deps() { print 'cabal' }

setup() {
	grep 'executable perf' toml-reader.cabal || cat >>toml-reader.cabal <<-EOF
		executable perf
		    buildable: True
		    main-is: perf.hs
		    default-language: Haskell2010
		    build-depends: base, toml-reader, time, text
		    hs-source-dirs: perf
	EOF
	mkdir -p perf
	cat >|perf/perf.hs <<-'EOF'
		import Control.Exception (evaluate)
		import qualified Data.Text as Text
		import Data.Time (diffUTCTime, getCurrentTime)
		import System.Environment (getArgs)
		import TOML.Parser (parseTOML)

		main :: IO ()
		main =
		 do args <- getArgs
		    filename <- case args of
		      [filename] -> pure filename
		      _ -> fail "Usage: perf <file.toml>"
		    txt <- readFile filename
		    evaluate (length txt) -- readFile uses lazy IO, force it to load
		    start <- getCurrentTime
		    evaluate (parseTOML filename (Text.pack txt))
		    stop <- getCurrentTime
		    print (stop `diffUTCTime` start)
	EOF

	# Note: Needs cabal 3.10 (or 3.8?) for --prefer oldest. 3.6 is too old at least.
	cabal update
	cabal configure --enable-test --prefer-oldest
	cabal build

	# What a path... Copy it to something vaguely managable.
	cp dist-newstyle/build/x86_64-linux/ghc-*/toml-reader-*/t/parser-validator/build/parser-validator/parser-validator .
	cp dist-newstyle/build/x86_64-linux/ghc-*/toml-reader-*/x/perf/build/perf/perf perf-bin
}

typeset -A info=(
	# Stopped building for mysterious reasons. God I'm so tired of Haskell
	# throwing a hissy fit every other day. Horrible ecosystem and I'm done
	# dealing with it.
	skip 1

	lang    'Haskell'
	toml    '1.0'
	site    'https://github.com/brandonchinn178/toml-reader'
	src     'https://github.com/brandonchinn178/toml-reader.git'
	decoder './src/haskell-toml-reader/parser-validator --check'
	encoder ''
	perf    'perf-bin'
)
