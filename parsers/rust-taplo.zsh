deps() { print 'cargo rustc' }

setup() {
	cd scripts
	cargo build --release
}

typeset -A info=(
	lang    'Rust'
	toml    '1.0'
	site    'https://github.com/tamasfe/taplo'
	src     '' # We use the Cargo.toml for now 'https://github.com/tamasfes/taplo.git'
	version '0.12.1'
	decoder './scripts/target/release/taplo-decoder'
	encoder 'TODO'  # './scripts/target/release/taplo-encoder'
	perf    './scripts/target/release/rust-taplo-perf'
)
