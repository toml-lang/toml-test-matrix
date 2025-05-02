A test matrix of TOML implementations: https://toml-lang.github.io/toml-test-matrix

For the full list of implementations, see:
https://github.com/toml-lang/toml/wiki

Adding a parser
---------------
Edit `parsers.toml`

The tests result rely on having https://github.com/toml-lang/setup-toml-test set
up on the repo. That will upload a build artifact, which the program in fetches.
