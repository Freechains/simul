#!/usr/bin/env lua5.3

local socket = require 'socket'

math.randomseed(os.time())
function normal (n)
    n = n/2
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

print('-=-=- REMOVE ALL -=-=-=-')
io.read()

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
    assert(c:send('/id\n'))
    SS[i] = c
end

for i=1,N do
    fc('chain join /id trusted', 8400+i)
end

--print'-=-=- GO -=-=-=-'
--io.read()

local sec  = 1
local min  = 60*sec
local hour = 60*min

local _day  = 10*min
local _hour = _day  / 24
local _min  = _hour / 60
local _sec  = _min  / 60

local TOTAL   = 3*_day      -- simulation time
local INIT    = 1*min       -- wait time after 1st message
local LATENCY = 250         -- network latency (start time)

local fst = os.time()

local AUTHOR = {
    hosts  = {12,15},       -- hosts to post
    period = 5*_hour,       -- time for each post
    length = 10*1000*1000,  -- message length (30MB photo 4GB video)
    time   = { old=fst,nxt=fst }
}

local VIEWER = {
    period = AUTHOR.period / 50, -- 50 comments/post
    length = 50,                 -- message length (small comments)
    time   = { old=fst,nxt=2*INIT }
}

local msg  = 0
local exit = false
local fst_

while true do
    local now = os.time()
    if now >= fst+TOTAL then
        exit = true
    end
    if not exit then
        if now >= AUTHOR.time.nxt then
            AUTHOR.time.old = now
            AUTHOR.time.nxt = now + normal(AUTHOR.period)
            if msg == 0 then
                AUTHOR.nxt = now + INIT  -- first message --height 1-- must propagate
            elseif msg == 1 then
                fst_ = now
            end

            msg = msg + 1
            local hst = AUTHOR.hosts[math.random(#AUTHOR.hosts)]
            local LEN = normal(AUTHOR.length)
            while LEN > 0 do
                local len = math.min(LEN,127500)
                local txt = '#'..msg..' - @'..hst..': '..string.rep('x',len)
                fc('chain post /id inline "'..txt..'"', 8400+hst)
                LEN = LEN - len
            end
        end

        if now >= VIEWER.time.nxt then
            VIEWER.time.old = now
            VIEWER.time.nxt = now + normal(VIEWER.period)

            msg = msg + 1
            local hst = math.random(N)
            local txt = '#'..msg..' - @'..hst..': '..string.rep('x',normal(VIEWER.length))
            fc('chain post /id inline "'..txt..'"', 8400+hst)
        end
    end

    local ss = socket.select(SS,nil,1)
    if exit and #ss==0 then
        break
    end
    local s = ss[1]
    for i=1,N do
        if s == SS[i] then
            --print('DATA on', i)
            local n = s:receive('*l')
            if tonumber(n) > 0 then
                local cmd = 'sleep 0'
                local t = {}
                local hs = {} do
                    for k in pairs(VS[i]) do
                        hs[#hs+1] = k
                    end
                end
                while #hs > 0 do
                    local j = table.remove(hs, math.random(1,#hs))
                    --print('',i,'->',j)
                    local dt = (LATENCY==0 and 0) or normal(LATENCY)
                    local cmd1 = 'sleep '..(dt/1000)
                    local cmd2 = 'freechains --host=localhost:'..(8400+i)..' chain send /id localhost:'..(8400+j)
                    cmd = cmd..' ; '..cmd1..' ; '..cmd2
                end
                os.execute(cmd..' &')
            end
        end
    end
end

v1 = fc_('chain heads /id all', 8410)
v2 = fc_('chain heads /id all', 8415)

local dt = os.time() - fst_

for i=1,N do
    fc('host stop', 8400+i)
end

print('TOTAL',   dt)
print('HOST 10', v1)
print('HOST 15', v2)
