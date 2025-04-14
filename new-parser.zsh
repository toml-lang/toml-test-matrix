# Parser template – copy to "parsers/[language]-[pkg-name].zsh".

# Print space-separated list of whatever is needed to build and run this; the
# tools are looked up in $PATH.
deps() {
	print 'tool build-tool'
}

# Do whatever is needed to run the decode, encode, and perf scripts. Working
# directory will be the source directory (src/[name]).
setup() {
	# Run configure, build binaries, etc.
}

# Run after completion, mostly to ensure output/[name].html is stable between
# runs (e.g. by removing memory addresses from stack traces). Should rarely be
# needed.
# after-run() {
# }

typeset -A info=(
	# Language name.
	lang    'MyLang'

	# TOML version that's supported.
	toml    '1.0'

	# Project site.
	site    'https://example.com'

	# Project source; only git supported for now.
	src     'https://example.com/toml.git'

	# Decoder binary for toml-test.
	#
	# If this starts with "./" it's run from the toml-test-matrix root
	# directory, otherwise from the parser's source directory. For example:
	#
	#   build/bin/decode
	#   ./scripts/mylang-toml-decode
	#
	# If the project doesn't have a decoder then add it in "scripts/[name]". For
	# interpreted languages without any setup you can run it directory. If it
	# needs to be compiled then copy and compile it in the setup function.
	decoder ''

	# Encoder binary; follows the same rules as decoder.
	#
	# Leave blank for "(doesn't include encoder)".
	#
	# Use TODO for "(TODO)".
	encoder 'build_tt/toml-test/tt_encoder'

	# Performance script; this should read a TOML file from the first positional
	# argument and print the time it took to parse that on stdout in seconds.
	#
	# For example in Python:
	#
	#    with open(sys.argv[1], 'rb') as fp:
	#        data = fp.read().decode()
	#    start = datetime.datetime.now()
	#    tomllib.loads(data)
	#    print(f'{(datetime.datetime.now() - start).total_seconds():f}')
	#
	# Note it prints the time in seconds, for example "0.0015" for 15ms.
	perf    'build_tt/perf'
)
