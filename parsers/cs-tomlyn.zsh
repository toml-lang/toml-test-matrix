if [[ -f ./toolchain/dotnet/dotnet ]]; then
	export DOTNET_ROOT=$PWD/toolchain/dotnet
	path+=($DOTNET_ROOT)
fi

deps() { print 'dotnet' }

setup() {
	(
		if [[ ! -d cs-tomlyn-decoder ]]; then
			dotnet new console -o cs-tomlyn-decoder -f net8.0
			(
				cd cs-tomlyn-decoder
				rm Program.cs
				dotnet add package Tomlyn --version 0.19.0
				dotnet add package Newtonsoft.Json --version=13.0.3
			)
		fi
		cp ../../scripts/cs-tomlyn-decoder.cs cs-tomlyn-decoder/
	)
	(
		cd cs-tomlyn-decoder
		dotnet build -c Release
	)

	(
		if [[ ! -d cs-tomlyn-encoder ]]; then
			dotnet new console -o cs-tomlyn-encoder -f net8.0
			(
				cd cs-tomlyn-encoder
				rm Program.cs
				dotnet add package Tomlyn --version 0.19.0
				dotnet add package Newtonsoft.Json --version=13.0.3
			)
		fi
		cp ../../scripts/cs-tomlyn-encoder.cs cs-tomlyn-encoder/
	)
	(
		cd cs-tomlyn-encoder
		dotnet build -c Release
	)

	(
		if [[ ! -d cs-tomlyn-perf ]]; then
			dotnet new console -o cs-tomlyn-perf -f net8.0
			(
				cd cs-tomlyn-perf
				rm Program.cs
				dotnet add package Tomlyn --version 0.19.0
			)
		fi
		cp ../../scripts/cs-tomlyn-perf.cs cs-tomlyn-perf/
	)

	(
		cd cs-tomlyn-perf
		dotnet build -c Release
	)
}

typeset -A info=(
	lang    'C#'
	toml    '1.0'
	site    'https://github.com/xoofx/Tomlyn'
	src     'https://github.com/xoofx/Tomlyn.git'
	version '0.16.2'
	decoder 'cs-tomlyn-decoder/bin/Release/net8.0/cs-tomlyn-decoder'
	encoder 'TODO'
	perf    'cs-tomlyn-perf/bin/Release/net8.0/cs-tomlyn-perf'
)

