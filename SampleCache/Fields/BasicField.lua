--------------------------------------------------------------------------------
--[[
BasicField

Demonstrates the basic usage of a Field when coupled with a Vent
--]]
--------------------------------------------------------------------------------

local CBE = require("CBEffects.Library")

local vent = CBE.NewVent{
	posRadius = display.contentCenterX * 0.5,
	posInner = display.contentCenterX * 0.45,
	onCreation = function(p)
		p:setLinearVelocity((display.contentCenterX - p.x) * 0.02, (display.contentCenterY - p.y) * 0.02)
	end
}

local field = CBE.newField{
	targetVent = vent, -- Without a targetVent, an error will occur
	preset = "stop"
}

vent:start()
field:start() -- Fields must be started, just like Vents