#!/usr/bin/env lua5.3

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

for i=0,10 do
    EXE.fc('host stop', 8400+i)
end

EXE._ 'rm -Rf /tmp/freechains'

for i=0,10 do
    EXE._('freechains host create /tmp/freechains/'..(8400+i)..' '..(8400+i))
end

for i=0,10 do
    EXE.bg('freechains host start /tmp/freechains/'..(8400+i))
end

EXE._ 'sleep 1'

pvt0 = '6F99999751DE615705B9B1A987D8422D75D16F5D55AF43520765FA8C5329F7053CCAF4839B1FDDF406552AF175613D7A247C5703683AEC6DBDF0BB3932DD8322'

old = os.time()

for i=0,10 do
    EXE.fc('chain join /chat', 8400+i)
end

EXE.fc('chain post /chat inline "Ola"', 8400, '--sign='..pvt0)

for i=1,10 do
    EXE.fc('chain send /chat localhost:'..(8400+i), 8400+i-1)
end

v = EXE.fc('chain heads /chat all', 8410)

print(os.time() - old)
print(v)
