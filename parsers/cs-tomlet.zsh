if [[ -f ./toolchain/dotnet9/dotnet ]]; then
	export DOTNET_ROOT=$PWD/toolchain/dotnet9
	path+=($DOTNET_ROOT)
fi

deps() { print 'dotnet' }

setup() {
	dotnet restore
	dotnet msbuild -p:Configuration=Release
}

typeset -A info=(
	lang    'C#'
	toml    '1.0'
	site    'https://github.com/SamboyCoding/Tomlet'
	src     'https://github.com/SamboyCoding/Tomlet'
	decoder 'TomlTestDecoder/bin/Release/net9.0/TomlTestDecoder'
	encoder 'TODO'
	perf    'TODO'
)
