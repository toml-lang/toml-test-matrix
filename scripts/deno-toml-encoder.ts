#!/usr/bin/env deno

import { stringify } from "jsr:@std/toml"

let convert = (v) => {
	if (typeof(v) === 'object' && v.constructor && v.constructor.name === 'Array')
		return v.map(convert)
	else if (v.type === undefined || v.value === undefined) {
		for (let k in v)
			v[k] = convert(v[k])
		return v
	}

	switch (v.type) {
	case 'string':         return v.value
	case 'integer':        return BigInt(v.value)
	case 'float':          return parseFloat(v.value.replace('inf', 'Infinity'))
    case 'bool':           return v.value === 'true' ? true : false
    // TODO: no way to distinguish: https://github.com/denoland/std/issues/6591
	case 'datetime':       return new Date(v.value)
	case 'datetime-local': return new Date(v.value)
	case 'date-local':     return new Date(v.value)
	case 'time-local':     return new Date(v.value)
	//case 'datetime':       return new toml.OffsetDateTime(v.value)
	//case 'datetime-local': return new toml.LocalDateTime(v.value)
	//case 'date-local':     return new toml.LocalDate(v.value)
	//case 'time-local':     return new toml.LocalTime(v.value)
	default:               throw(`unknown type: ${v}`)
	}
}

let d   = new TextDecoder(),
    doc = ''
for await (let c of Deno.stdin.readable)
	doc += d.decode(c)
let j = JSON.parse(doc)
for (let k in j)
	j[k] = convert(j[k])
process.stdout.write(stringify(j))
