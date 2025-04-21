#!/usr/bin/env deno

import { parse } from "jsr:@std/toml"

let convert = (v) => {
	switch (typeof(v)) {
	case 'string':  return {type: 'string',  value: v}
	case 'bigint':  return {type: 'integer', value: v.toString()}
	case 'number':  return {type: 'float',   value: v.toString()}
	case 'boolean': return {type: 'bool',    value: v.toString()}
	case 'object':
		switch (v.constructor.name) {
		case 'Object':
			for (let k in v)
				v[k] = convert(v[k])
			return v
		case 'Array':
			return v.map(convert)

		// TODO: no way to distinguish: https://github.com/denoland/std/issues/6591
		case 'Date': return {type: 'datetime', value: v.toISOString()}
		//case 'LocalDateTime':  return {type: 'datetime-local',  value: v.toISOString()}
		//case 'LocalDate':      return {type: 'date-local',      value: v.toISOString()}
		//case 'LocalTime':      return {type: 'time-local',      value: v.toISOString()}
		default:
			throw(`unknown type: ${v.constructor.name}`)
		}
	default:
		throw(`unknown type: ${typeof(v)}`)
	}
}

let d   = new TextDecoder(),
    doc = ''
for await (let c of Deno.stdin.readable)
	doc += d.decode(c)

let t = parse(doc)
for (let k in t)
	t[k] = convert(t[k])
process.stdout.write(JSON.stringify(t, null, 4))
