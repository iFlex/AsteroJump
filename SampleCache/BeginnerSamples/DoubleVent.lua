--------------------------------------------------------------------------------
--[[
DoubleVent

Two default vents on either side of the screen - demonstrates beginning parameters

For each separate table inside of the main data table, a new vent is created. This demonstrates that fact.
--]]
--------------------------------------------------------------------------------

local CBE = require("CBEffects.Library")

-- One fourth of the screen width (the center - one half - halved)
local oneFourth = display.contentCenterX * 0.5

local double = CBE.VentGroup{
	{
		title = "vent1",
		x = oneFourth -- X is x-position
	},

	{
		title = "vent2",
		x = display.contentCenterX+oneFourth
	}
}

double:startMaster()
--double:start("vent1", "vent2") -- Would do the same thing