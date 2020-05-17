#!/usr/bin/env lua5.3

local socket = require 'socket'

-- fazer uma topologia mais complexa
-- verificar que o tempo vai subir muito mesmo com a Hmax igual
-- usar socket.select/listen para disparar em BG os seus sends

math.randomseed(os.time())
function normal (n)
    local x
    repeat
        x = math.ceil(math.log(1/math.random())^.5*math.cos(math.pi*math.random())*150 + n/2)
    until x>=1 and x<=n
    return x
end

function fc (cmd, port, opts)
    opts = opts or ''
    os.execute('freechains --host=localhost:'..port..' '..opts..' '..cmd)
end

function fc_ (cmd, port, opts)
    opts = opts or ''
    cmd  = 'freechains --host=localhost:'..port..' '..opts..' '..cmd
    local f   = assert(io.popen(cmd))
    local ret = f:read("*a")
    assert(f:close())
    return ret
end

N = 21

ES = {
    {1,2}, {2,3}, {3,4}, {4,5}, {5,6}, {6,7}, {7,8}, {8,9}, {9,10},
    {2,11}, {11,12}, {12,2},
    {6,13}, {13,14}, {14,15}, {15,16}, {16,7},
    {6,17}, {17,18}, {18,19}, {7,19}, {19,20}, {20,21}, {21,8},
}

VS = {}
for i=1,N do
    VS[i] = {}
end

for _, e in ipairs(ES) do
    VS[e[1]][e[2]] = true
    VS[e[2]][e[1]] = true
end

for i=1,N do
    fc('host stop', 8400+i)
end

os.execute('rm -Rf /tmp/freechains')

for i=1,N do
    os.execute('freechains host create /tmp/freechains/'..(8400+i)..' '..(8400+i))
end

for i=1,N do
    os.execute('freechains host start /tmp/freechains/'..(8400+i)..' &')
end

os.execute('sleep 5')

local SS = {}
for i=1,N do
   local c = assert(socket.connect('localhost', 8400+i))
    assert(c:send('FC v0.3.7 chain listen\n'))
    assert(c:send('/chat\n'))
    SS[i] = c
end

local pvt0 = '6F99999751DE615705B9B1A987D8422D75D16F5D55AF43520765FA8C5329F7053CCAF4839B1FDDF406552AF175613D7A247C5703683AEC6DBDF0BB3932DD8322'
--local sha0 = '64976DF4946F45D6EF37A35D06A1D9A1099768FBBC2B4F95484BA390811C63A2'

for i=1,N do
    fc('chain join /chat trusted', 8400+i)
end

local msg = 0
local fst = os.time()
local old = fst
local nxt = old + normal(30)

local exit = false
while true do
    local now = os.time()
    if now >= fst+300 then
        exit = true
    end
    if now >= nxt then
        old = now
        nxt = now + normal(30)

        msg = msg + 1
        local hst = math.random(N)
        local txt = '#'..msg..' - @'..hst..': '..string.rep('x',normal(100))
        fc('chain post /chat inline "'..txt..'"', 8400+hst)
    end

    local ss = socket.select(SS,nil,1)
    if exit and #ss==0 then
        break
    end
    for i=1,#ss do
        for j=1,N do
            if ss[i] == SS[j] then
                print('DATA on', j)
                local n = ss[i]:receive('*l')
                if tonumber(n) > 0 then
                    for k in pairs(VS[j]) do
                        fc('chain send /chat localhost:'..(8400+k)..' &', 8400+j)
                    end
                end
            end
        end
    end
end

v1 = fc_('chain heads /chat all', 8410)
v2 = fc_('chain heads /chat all', 8415)

print(os.time() - fst)
print(v1,v2)
