if [[ -f ./toolchain/dotnet9/dotnet ]]; then
	export DOTNET_ROOT=$PWD/toolchain/dotnet9
	path+=($DOTNET_ROOT)
fi

deps() { print 'dotnet' }

setup() {
	grep 'perf/perf.csproj' Tomlet.sln ||
	cat >>Tomlet.sln <<-EOF
		Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBD}") = "perf", "perf/perf.csproj", "{DDBC07E0-61B8-438D-A9DE-8384ADA1D9C0}"
		EndProject
	EOF

	mkdir -p perf
	cp ../../scripts/cs-tomlet-perf.cs perf
	sed 's/TomlTestEncoder/perf/' TomlTestDecoder/TomlTestDecoder.csproj >!perf/perf.csproj

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
	perf    'TODO' # TODO: Doesn't work on account of Tomlet bugs 'perf/bin/Release/net9.0/perf'
)
