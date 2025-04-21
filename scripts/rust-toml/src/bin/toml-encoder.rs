use std::io::Read as _;

use toml_test_harness::Encoder as _;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut stdin = std::io::stdin();
    let mut raw = String::new();
    stdin.read_to_string(&mut raw)?;

    let decoded: toml_test_harness::DecodedValue = serde_json::from_str(&raw)?;

    let toml = rust_toml::encoder::Encoder.encode(decoded)?;

    print!("{toml}");

    Ok(())
}
