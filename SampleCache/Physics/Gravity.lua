--------------------------------------------------------------------------------
--[[
Gravity

Particles flying in an arc described by the launch angle and the gravity.
--]]
--------------------------------------------------------------------------------

local CBE = require("CBEffects.Library")

local SampleVent = CBE.NewVent{
	title = "laserVent",
	preset = "lasergun",
	positionType = "inRadius", -- Add a bit of randomness to the position
	rotateTowardVel = true,
	towardVelOffset = 90,
	lifeStart = 300,
	physics = {
		velocity = 20,
		gravityY = 0.5,
		autoAngle = true,
		angles = {{45, 65}} -- Angles from 45 to 65
	}
}

SampleVent:start()