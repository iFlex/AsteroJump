--------------------------------------------------------------------------------
--[[
Ring

A vent with preset "default" edited to appear in a ring.

Be careful that the posInner parameter is never above the posRadius parameter!
--]]
--------------------------------------------------------------------------------

local CBE = require("CBEffects.Library")

local vent = CBE.NewVent{
	posRadius = display.contentCenterX * 0.5, 
	posInner = display.contentCenterX * 0.45 -- Just give it a little bit of space to appear in
}

vent:start()