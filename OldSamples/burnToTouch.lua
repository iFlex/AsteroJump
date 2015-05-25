------------------
--[[
CBEffects Sample: Burn to Touch

Loads the "burn" preset and, when the screen is touched or clicked, moves the vent to the event point.

This sample I made because I like the "burn" preset the most :) - that's why it's basically just raw CBEffects.

View it thus:

require("CBResources.samples.burnToTouch")

It is most recommended to do this on a completely blank scene.
--]]
------------------
local CBE=require("CBEffects.Library")

local flameTrans -- Localize the transition

local flameVent=CBE.VentGroup{
	{preset="burn"} -- Just loading it, no changes
}
flameVent:start("burn") -- Start it

local function touchScreen(event)
	if event.phase=="ended" then
		if flameTrans then
			transition.cancel(flameTrans) -- Cancel the transition if it exists
		end
		flameTrans=transition.to(flameVent:get("burn"), {x=event.x, y=event.y, time=1000}) -- Move the vent
	end
end
Runtime:addEventListener("touch", touchScreen) -- Add the listener