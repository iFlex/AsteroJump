--------------------------------------------------------------------------------
--[[
TouchPoint

Starts a vent when screen is touched and tracks touch position.
--]]
--------------------------------------------------------------------------------

local CBE = require("CBEffects.Library")

local myVent = CBE.NewVent{
	preset = "burn"
}

local function onScreenTouch(event)
	myVent.x, myVent.y = event.x, event.y -- We want the vent to move no matter what the phase of the event

	if "began" == event.phase then
		myVent:start() -- Start if began
	elseif "ended"==event.phase then
		myVent:stop() -- Stop if ended
	end
end

Runtime:addEventListener("touch", onScreenTouch)
