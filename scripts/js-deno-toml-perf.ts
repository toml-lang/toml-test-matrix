#!/usr/bin/env -S deno --allow-read

import { parse } from "jsr:@std/toml"

let data = await Deno.readTextFile(process.argv[2]);
let s = Date.now()
parse(data)
process.stdout.write(`${(Date.now() - s) / 1000}`)
