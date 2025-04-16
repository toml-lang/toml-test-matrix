deps() { print 'cargo rustc' }

setup() {
	cd scripts
	cargo build --release
}

typeset -A info=(
	lang    'Rust'
	toml    '1.0'
	site    'https://github.com/Bright-Shard/boml'
	src     '' # We use the Cargo.toml for now 'https://github.com/toml-rs/toml.git'
	version $(awk '$1 == "boml" {print gensub(/"/, "", "g", $3)}' scripts/Cargo.toml)
	decoder './scripts/target/release/boml-decoder'
	encoder ''
	perf    './scripts/target/release/rust-boml-perf'
)
