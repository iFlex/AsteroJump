------------------
--[[
CBEffects Sample: Pulling Field

Has a field that pulls particle inwards onCollision. When the screen is touched and/or dragged, the field moves to the touch point.

View it thus:

require("CBResources.samples.pullingField")

It is most recommended to do this on a completely blank scene.
--]]
------------------
local CBE=require("CBEffects.Library")

local fieldGroup -- Localize the fieldGroup, the ventGroup, and the red display circle
local ventGroup
local circ

ventGroup=CBE.VentGroup{
	{
		-- Since there's no preset, it loads the "default" preset
		title="genericVent" -- Title it - THIS IS IMPORTANT!!! ALWAYS!!!
	}
}
ventGroup:startMaster() -- Start it

fieldGroup=CBE.FieldGroup{
	{
		title="towardField",
		onCollision=function(p, f)
			--p:setLinearVelocity(0, 0)
			p:applyForce(f.x-p.x, f.y-p.y) -- Apply force according to the position of the particle VS the field
			p.xScale=p.xScale-0.01 -- Shrink it a bit every time it collides
			p.yScale=p.yScale-0.01
		end,
		targetVent=ventGroup:get("genericVent") -- Set the receptivity to the generic vent we created before
	}
}
fieldGroup:startMaster()

circ=display.newCircle(0, 0, fieldGroup:get("towardField").radius) -- Create the display circle
circ.x, circ.y=display.contentCenterX, display.contentCenterY
circ:setFillColor(0, 0, 0, 0) -- We just want it outlined for less distraction
circ.strokeWidth=5
circ:setStrokeColor(255, 0, 0)

local function touchScreen(event)
	fieldGroup:translate("towardField", event.x, event.y) -- Use the version Two and up "translate" function - an easier way to do the commented out version
	--fieldGroup:get("towardField").x, fieldGroup:get("towardField").y=event.x, event.y
	
	circ.x, circ.y=event.x, event.y -- Move the display circle
end
Runtime:addEventListener("touch", touchScreen) -- Add the listener