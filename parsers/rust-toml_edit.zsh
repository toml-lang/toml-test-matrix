deps() { print 'cargo rustc' }

setup() {
	cd scripts
	cargo build --release
}

typeset -A info=(
	lang    'Rust'
	toml    '1.0'
	site    'https://github.com/toml-rs/toml/tree/main/crates/toml_edit'
	src     '' # We use the Cargo.toml for now 'https://github.com/toml-rs/toml.git'
	version $(awk '$1 == "toml_edit" {print gensub(/"/, "", "g", $3)}' scripts/Cargo.toml)
	decoder './scripts/target/release/toml_edit-decoder'
	encoder './scripts/target/release/toml_edit-encoder'
	perf    './scripts/target/release/rust-toml_edit-perf'
)
