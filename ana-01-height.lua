#!/usr/bin/env lua5.3

local json = require 'json'

-- maximum height distance

for _,f in ipairs { ... } do
    local blk = json.decode(assert(io.open(f)):read('*a'))
    local max=0 do
        local me = assert(tonumber(string.match(f,'(%d+)_')))
        for _, back in ipairs(blk.immut.backs) do
            local him = assert(tonumber(string.match(back,'(%d+)_')))
            local dif = me - him
            if dif > max then
                max = dif
            end
        end
    end
    print(max, f)
end
