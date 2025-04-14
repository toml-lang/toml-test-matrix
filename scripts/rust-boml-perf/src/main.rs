fn main() {
    let mut args = std::env::args_os();
    args.next();
    let path = std::path::PathBuf::from(args.next().expect("Missing TOML path argument"));
    let raw = std::fs::read_to_string(&path).unwrap();
    let timer = std::time::Instant::now();
    let value = boml::Toml::parse(&raw);
    let delta = timer.elapsed().as_secs_f32();
    value.unwrap();
    println!("{delta}");
}
