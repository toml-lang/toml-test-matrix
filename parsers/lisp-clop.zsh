deps() { print 'ros' }

setup() {
	cd roswell
	ros build decoder.ros
}

typeset -A info=(
	lang    'Lisp'
	toml    '1.0'
	site    'https://github.com/sheepduke/clop'
	src     'https://github.com/sheepduke/clop.git'
	decoder 'roswell/decoder'
	encoder ''
	perf    'TODO'
	flags   '-timeout=3s'
)
