--------------------------------------------------------------------------------
--[[
MultiField

Creates two Fields inside a FieldGroup that attract and repel on screen touch.
--]]
--------------------------------------------------------------------------------

local CBE = require("CBEffects.Library")

local burnVent = CBE.NewVent{
	preset = "burn",
	positionType = "inRadius",
	posRadius = display.contentCenterX, -- Have particles appear all around the screen
	physics = {
		gravityY = 0,
		velocity = 0
	}
}

local FieldGroup = CBE.FieldGroup{ -- We use a FieldGroup because we have more than one
	{
		targetVent = burnVent,
		title = "fg1",
		radius = display.contentCenterX*0.5,
		onFieldInit = function(f)
			f.magnitude = 0.003
		end
	},

	{
		targetVent = burnVent,
		title = "fg2",
		preset = "out",
		radius = display.contentCenterX*0.5,
		onFieldInit = function(f)
			f.magnitude = 0.003
		end
	}
}

local function onScreenTouch(event)
	FieldGroup:translate("fg1", event.x-display.contentWidth*0.25, event.y)
	FieldGroup:translate("fg2", event.x+display.contentWidth*0.25, event.y)

	if "began" == event.phase then
		FieldGroup:startMaster() -- startMaster() starts all fields
	elseif "ended" == event.phase then
		FieldGroup:stopMaster()
	end
end

burnVent:start()
Runtime:addEventListener("touch", onScreenTouch)