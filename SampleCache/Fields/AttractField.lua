--------------------------------------------------------------------------------
--[[
AttractField

Creates a FieldGroup that attracts particles. When the screen is touched, the FieldGroup is moved to that location and started.
--]]
--------------------------------------------------------------------------------

local CBE = require("CBEffects.Library")

local vent = CBE.NewVent{
	posRadius = display.contentCenterX
}

local field = CBE.NewField{
	targetVent = vent,
	radius = display.contentCenterX, -- Make the collision radius large so that more particles are affected by it
	onFieldInit = function(f)
		f.magnitude = 0.01 -- The preset, to make things convenient, multiplies all forces by it's magnitude. Normally, this wouldn't do anything unless you specified what happens that's associated with the magnitude
	end
}

local function onScreenTouch(event)
	field.x, field.y = event.x, event.y

	if "began" == event.phase then
		field:start()
	elseif "ended" == event.phase then
		field:stop()
	end
end

vent:start()
Runtime:addEventListener("touch", onScreenTouch)