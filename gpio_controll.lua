local turbo = require("turbo")
local config = require("config")
local template_file = assert(io.open(config.template_path, "r"), "Can't open template!")
local template = template_file:read("*a")
template_file:close()



function setPin(pinid, state)
	local pinid = assert(tonumber(pinid))
	local state = assert(tonumber(state))	

	local cpin = config.pins[pinid]
	if cpin then
		os.execute(("gpio -1 mode %d out"):format(cpin.pin))
		os.execute(("gpio -1 write %d %d"):format(cpin.pin, cpin.state))
		cpin.state = state
		cpin.active = (state == 1)
		return true
	end
end



local Handler = class("Handler", turbo.web.RequestHandler)
function Handler:get(pinid, state)
	local pinid = tonumber(pinid)
	local state = tonumber(state)

	if pinid and state then
		setPin(pinid, state)
	end

	local render = {
		gpios = config.pins,
		date = os.date()
	}


	self:write(turbo.web.Mustache.render(template, {
		gpios = config.pins
	}))
end



for k,v in pairs(config.pins) do
	v.pin = assert(tonumber(v.pin))
	v.pinid = k
	v.state = v.state or 0
	v.active = v.active or false
	v.name = v.name or "GPIO " .. v.pin
end

local app = turbo.web.Application({
    {"^/$", Handler},
    {"^/debug$", debugHandler},
    {"^/set/(%d*)/(%d*)/$", Handler}
})


app:listen(config.webport)
turbo.ioloop.instance():start()

