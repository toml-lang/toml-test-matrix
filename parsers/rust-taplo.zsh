deps() { print 'cargo rustc' }

setup() {
	cd scripts
	cargo build --release
}

typeset -A info=(
skip 1
	lang    'Rust'
	toml    '1.0'
	site    'https://github.com/tamasfe/taplo'
	src     '' # We use the Cargo.toml for now 'https://github.com/tamasfes/taplo.git'
	version $(grep 'taplo =' scripts/Cargo.toml | grep -Eo '[0-9.]{3,}')
	decoder './scripts/target/release/taplo-decoder'
	encoder 'TODO'  # './scripts/target/release/taplo-encoder'
	perf    './scripts/target/release/rust-taplo-perf'
)
