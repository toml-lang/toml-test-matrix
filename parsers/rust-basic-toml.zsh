deps() { print 'cargo rustc' }

setup() {
	cd scripts
	cargo build --release
}

typeset -A info=(
	lang    'Rust'
	toml    '1.0'
	site    'https://github.com/dtolnay/basic-toml'
	src     '' # We use the Cargo.toml for now 'https://github.com/dtolnay/basic-toml.git'
	version $(awk '$1 == "basic-toml" {print gensub(/"/, "", "g", $3)}' scripts/Cargo.toml)
	decoder './scripts/target/release/basic-toml-decoder'
	# TODO: doesn't encode at least dates correctly; e.g. for
	#   lower = 1987-07-05t17:45:00z
	# It outputs:
	#   [lower]
	#   "$__toml_private_datetime" = "1987-07-05T17:45:00Z"
	encoder 'TODO' # ./scripts/target/release/basic-toml-encoder'
	perf    './scripts/target/release/rust-basic-toml-perf'
)
