--------------------------------------------------------------------------------
--[[
BasicVent

Demonstrates how to use angle parameters to control particle direction.
--]]
--------------------------------------------------------------------------------

local CBE = require("CBEffects.Library")

local SampleVent = CBE.NewVent{
	title = "angles",
	preset = "waterfall",
	positionType = "atPoint", -- Keep particles at a single point with no randomness
	perEmit = 1,
	x = display.contentCenterX,
	y = display.contentCenterY,
	physics = {
		iterateAngle = true,
		angleIncr = 92, -- 90 + 2; add a quarter to the angles and increment the count by 2 for rotation
		gravityY = 0,
		angles = {
			{0, 360}
		}
	}
}

SampleVent:start()