use std::io::Read as _;

use toml_test_harness::Decoder as _;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut stdin = std::io::stdin();
    let mut raw = String::new();
    stdin.read_to_string(&mut raw)?;

    let decoded = rust_boml::decoder::Decoder.decode(raw.as_bytes())?;

    let json = serde_json::to_string_pretty(&decoded)?;

    print!("{json}");

    Ok(())
}
