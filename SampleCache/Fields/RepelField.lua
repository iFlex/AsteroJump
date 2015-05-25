--------------------------------------------------------------------------------
--[[
RepelField

Creates a FieldGroup that repels particles. When the screen is touched, the FieldGroup is moved to that location and started.
--]]
--------------------------------------------------------------------------------

local CBE = require("CBEffects.Library")

local vent = CBE.NewVent{
	posRadius = display.contentCenterX -- Have particles appear all around the screen
}

local field = CBE.NewField{
	targetVent = vent, -- Without a targetVent, an error will occur
	preset = "out",
	radius = display.contentCenterX, -- Make the collision radius large so that more particles are affected by it
	onFieldInit = function(f)
		f.magnitude = 0.01 -- See note on AttractField
	end
}

local function onScreenTouch(event)
	field.x, field.y = event.x, event.y

	if "began" == event.phase then
		FieldGroup:start()
	elseif "ended" == event.phase then
		FieldGroup:stop()
	end
end

vent:start()
Runtime:addEventListener("touch", onScreenTouch)