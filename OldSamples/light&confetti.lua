------------------
--[[
CBEffects Sample: Light & Confetti

The "Confetti" preset vent and a field that work together to create a "light" effect.

Cancels the original particle transition to create alpha effects using the field.

View it thus:

require("CBResources.samples.light&confetti")

It is most recommended to do this on a completely blank scene.
--]]
------------------
local CBE=require("CBEffects.Library") -- Require CBEffects

local function clamp(a, limits, limitl) -- Build a simple clamp function
	if a<=limitl and a>=limits then
		return a
	elseif a>limitl then
		return limitl
	elseif a<limits then
		return limits
	end
end

local function lengthOf( a, b, c, d )
  local width, height = c-a, d-b
	return (width*width + height*height)^0.5
end

local TargetVentGroup=CBE.VentGroup{ -- Create the target vent for the collision field
	{
		preset="confetti",
		perEmit=10, -- High perEmit, may make it laggy, but I've done it so the light effect is more visible
		onCreation=function(p, v)
			transition.cancel(p.trans) -- Cancel the life transition - so that the transition isn't battling with the collision field for alpha changing
			p.trans=timer.performWithDelay(p.lifeSpan+v.lifeStart, p.kill) -- Create the new "transition", really just a timer that kills it at the end
		end,
		alpha=0, -- We don't want a "flash" effect
		startAlpha=0
	}
}
TargetVentGroup:startMaster() -- Start it

local FieldGroup=CBE.FieldGroup{ -- Create the field group itself
	{
		targetVent=TargetVentGroup:get("confetti"), -- Use the confetti vent from "TargetVentGroup"
		title="light", -- Title it
		radius=display.contentWidth, -- Make sure that it is a huge collision field so that particles are always colliding
		onCollision=function(p, f)
			p.alpha=clamp(1/lengthOf(p.x, p.y, f.x, f.y)*100, 0, 1) -- The backbone of the light - a function that sets alpha according to position
		end
	}
}
FieldGroup:startMaster() -- Start the field
timer.performWithDelay(800, function() transition.to(FieldGroup:get("light"), {x=math.random(1024), y=math.random(768), time=500}) end, 0) -- Transition the field to different positions