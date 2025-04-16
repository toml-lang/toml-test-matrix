A test matrix of TOML implementations: https://toml-lang.github.io/toml-test-matrix

For the full list of implementations, see:
https://github.com/toml-lang/toml/wiki

Adding a parser
---------------
See `new-parser.zsh` for a template with instructions.

Running it
----------
The results are committed in git, so you don't really need to run it unless
you're adding a new parser, or want to re-check the results.

You can use `./run check` to check for dependencies; these are just looked up in
$PATH. If you want to wrap this in Docker or VMs or whatnot then use a wrapper
scripts and prepend that to $PATH. There is no real cross-platform way to
abstract this more. `check` is just an informational command: it doesn't do
anything

Use `./run setup` to clone the sources, compile binaries, etc. Then `./run run`
to run `toml-test`, and `./run gen` to generate a new index.html.

For all of the above you can add a parser name to run just for that one parser:

    % ./run setup go-toml
    % ./run run go-toml
    % ./run gen

Which is probably what you want if you're just adding a new parser.

See `./run` for more detailed help.
