#!/usr/bin/env lua5.3

local json = require 'json'
local f = ...

-- maximum time/local distance

local blk = json.decode(assert(io.open(f)):read('*a'))
print(blk['local'] - blk.immut.time, f)
