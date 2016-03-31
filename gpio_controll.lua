local turbo = require("turbo")
local config = require("config")
local template_file = assert(io.open(config.template_path, "r"), "Can't open template!")
local template = template_file:read("*a")
template_file:close()


-- You can uncomment this to test on machines without GPIO's:
-- local simulation = {}

-- Comment to disable debug log:
function dprint(...) print("DEBUG: ", ...) end


function write(what, where)
    if simulation then
        simulation[tostring(where)] = tostring(what)
        dprint("SIMULATION WRITE", ("%q %q"):format(tostring(what), tostring(where)))
        return
    else
        dprint("WRITE", ("%q %q"):format(tostring(what), tostring(where)))
    end

    local f = io.open(where, "w")
    if f then
        f:write(what)
        f:close()
        return
    else
        error("Can't open for write!")
    end
end

function read(where)
    if simulation then
        dprint("SIMULATION READ", ("%q %q"):format(tostring(where), tostring(simulation[where] or 0)))
        return simulation[where] or 0
    else
        dprint("READ", where)
    end

    local f = io.open(where, "r")
    if f then
        local t = f:read("*a")
        f:close()
        return t
    else
        error("Can't open for read!")
    end
end



local debugHandler = class("debugHandler", turbo.web.RequestHandler)
function debugHandler:get()
    self:write("<html><body><h1>Debug</h1>\n")
    for k,v in pairs(simulation) do
        self:write("<p><b>" .. k .. "</b>\t")
        self:write("<i>" .. v .. "</i></p>\n")
    end
    self:write("\n</html></body>")
end

local Handler = class("Handler", turbo.web.RequestHandler)
function Handler:get(pin, state)
    if tonumber(pin) and tonumber(state) then
        dprint("SETTING PIN", pin, state)
        write(pin, "/sys/class/gpio/export")
        write("out", "/sys/class/gpio/gpio" .. pin .. "/direction")
        write(state, "/sys/class/gpio/gpio" .. pin .. "/value")
        write(cpin, "/sys/class/gpio/unexport")
    end

    local render = {
        gpios = {},
        date = os.date()
    }

    for _, cpin in pairs(config.pins) do
        dprint("READING PIN", cpin)
        write(cpin, "/sys/class/gpio/export")
        write("in", "/sys/class/gpio/gpio" .. cpin .. "/direction")
        local value = read("/sys/class/gpio/gpio" .. cpin .. "/value")
        local t = {
            pin = cpin
        }
        if value == "1" then
            t.active = true
        end
        render.gpios[#render.gpios + 1] = t
        write(cpin, "/sys/class/gpio/unexport")
    end

    self:write(turbo.web.Mustache.render(template, render))
end



local app = turbo.web.Application({
    {"^/$", Handler},
    {"^/debug$", debugHandler},
    {"^/set/(%d*)/(%d*)/$", Handler}
})


app:listen(config.webport)
turbo.ioloop.instance():start()
