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
	version '0.3.1'
	decoder './scripts/target/release/boml-decoder'
	encoder './scripts/target/release/boml-encoder'
	perf    './scripts/target/release/rust-boml-perf'
)
