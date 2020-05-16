#!/usr/bin/env lua5.3

-- fazer uma topologia mais complexa
-- verificar que o tempo vai subir muito mesmo com a Hmax igual
-- usar socket.select/listen para disparar em BG os seus sends

local EXE
EXE = {
    _ = function (cmd)
        local f = io.popen(cmd)
        local ret = f:read("*a")
        local ok = f:close()
        if ok then
            return ret
        else
            io.stderr:write('command aborted: '..cmd..'\n')
            return ok, 'EXE: '..cmd
        end
    end,

    bg = function (cmd)
        io.popen(cmd)
    end,

    fc = function (cmd, port, opts)
        port = port or 8330
        opts = opts or ''
        return EXE._('freechains --host=localhost:'..port..' '..opts..' '..cmd)
    end,
}

N = 25

ES = {
    {1,2}, {2,3}, {3,4}, {4,5}, {5,6}, {6,7}, {7,8}, {8,9}, {9,10},
    {2,11}, {11,12},
    {6,13}, {13,14}, {14,15}, {15,16}, {16,17}, {17,18}, {18,7},
    {6,19}, {19,20}, {20,21}, {21,22}, {8,22}, {22,23}, {23,24}, {24,25}, {25,10},
}

VS = {}
for i=1,N do
    VS[i] = {}
end

for _, e in ipairs(ES) do
    VS[e[1]][e[2]] = true
    VS[e[2]][e[1]] = true
end

function bcast (h, t)
    t = t or {}
    if t[h] then
        return
    end
    t[h] = true
    for i in pairs(VS[h]) do
        print('>>>',h,i)
        EXE.fc('chain send /chat localhost:'..(8400+i), 8400+h)
        bcast(i,t)
    end
end

for i=1,N do
    EXE.fc('host stop', 8400+i)
end

EXE._ 'rm -Rf /tmp/freechains'

for i=1,N do
    EXE._('freechains host create /tmp/freechains/'..(8400+i)..' '..(8400+i))
end

for i=1,N do
    EXE.bg('freechains host start /tmp/freechains/'..(8400+i))
end

EXE._ 'sleep 1'

pvt0 = '6F99999751DE615705B9B1A987D8422D75D16F5D55AF43520765FA8C5329F7053CCAF4839B1FDDF406552AF175613D7A247C5703683AEC6DBDF0BB3932DD8322'

old = os.time()

for i=1,N do
    EXE.fc('chain join /chat', 8400+i)
end

EXE.fc('chain post /chat inline "Ola"', 8401, '--sign='..pvt0)
bcast(1)

v1 = EXE.fc('chain heads /chat all', 8410)
v2 = EXE.fc('chain heads /chat all', 8416)

print(os.time() - old)
print(v1,v2)
