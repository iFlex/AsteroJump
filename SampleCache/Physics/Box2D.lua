--------------------------------------------------------------------------------
--[[
Box2D

Demonstrates the new (CBEffects Two and One-Half and up) way to add Box2D physics to particles.
--]]
--------------------------------------------------------------------------------

local CBE = require("CBEffects.Library")

local physics = require("physics")
physics.start()
physics.setGravity(0, 9.8)
--physics.setDrawMode("hybrid")
--physics.setDrawMode("debug")

local physicsVentGroup = CBE.VentGroup{
	{
		title = "snow",
		preset = "snow",

		alpha = 1,

		onVentInit = function(v)
			v.pPhysics.setScale(0) -- Stop pPhysics when vent is initiated
		end,
		
		onCreation = function(p, v)
			physics.addBody(p, {density = 0.1, radius = p.width * 0.5})
		end
	},

	{
		title = "snow2",
		preset = "snow",
		
		alpha = 1, -- For visibility

		point1 = {0, display.contentHeight}, -- Have particles appear at bottom of screen
		point2 = {display.contentWidth, display.contentHeight},
		
		onVentInit = function(v)
			v.pPhysics.setScale(0)
		end,
		
		onCreation = function(p, v)
			physics.addBody(p, {density = 0.1, radius = p.width*0.5})
			p.gravityScale = -2 -- Make particles move upwards
		end
	}
}

physicsVentGroup:start("snow", "snow2")