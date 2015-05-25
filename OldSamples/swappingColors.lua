------------------
--[[
CBEffects Sample: Swapping Colors

An eternally going ring of particles that turn red on the left side of the screen and yellow on the right side.

Uses a field in the center to pull particles in, and two fields on either side to color them.

View it thus:

require("CBResources.samples.swappingColors")

It is most recommended to do this on a completely blank scene.
--]]
------------------
local CBE=require("CBEffects.Library") -- Require CBEffects

local AWVentGroup=CBE.VentGroup{
	{
		preset="sparks", -- We load the sparks preset
		title="ring",
		emitDelay=1,
		perEmit=1,
		startAlpha=1,
		endAlpha=1,
		onDeath=function()end, -- A blank onDeath parameter - the original preset onDeath changes the perEmit
		physics={
			velocity=45,
			angles={
				{15,35} -- Make it slightly tilted
			},
			gravityY=0 -- No gravity
		}
	}
}
AWVentGroup:start("ring") -- Start the ring

local FieldGroup=CBE.FieldGroup{
	{
		title="pull",
		targetVent=AWVentGroup:get("ring"), -- Set to the ring vent
		radius=display.contentCenterX,
		x=display.contentCenterX+100, -- The rotation axis is a bit off center
		y=display.contentCenterY+40
	},
	{
		title="red",
		targetVent=AWVentGroup:get("ring"), -- Set to the ring vent
		shape="rect",
		x=0,
		y=0,
		rectWidth=display.contentCenterX, -- Half of the screen size
		rectHeight=display.contentHeight,
		onCollision=function(p, f)
			p.colorSet={r=255, g=0, b=0}  -- Instantly change, without a transition
		end
	},
	{
		title="yellow",
		targetVent=AWVentGroup:get("ring"), -- Set to the ring vent
		shape="rect",
		x=display.contentCenterX, -- The left side is in the center
		y=0,
		rectWidth=display.contentCenterX,
		rectHeight=display.contentHeight,
		onCollision=function(p, f)
			p.colorSet={r=255, g=255, b=0}
		end
	}
}
FieldGroup:startMaster() -- Start the fields