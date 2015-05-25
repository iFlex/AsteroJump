local custom={}

local CBE=require("CBEffects.Library")

function custom.initiate()
	------------------------------------------------------------------------------
	-- Your Code Here
	------------------------------------------------------------------------------
	local mrand=math.random
	local newText=display.newText
	local textString=[[

The custom code option allows you to play around with all of the awesome CBEffects resources from CBResources. Edit as much as you want - simply put your code inside the "initiate" function found in custom.lua.

To load this on startup, change "mode" in main.lua (line #44) to "custom".

To return to the sample browser, change the mode to "samples".

To choose what to load on startup, use "choose" as the mode.

Happy effects!]]

	local myVent=CBE.NewVent{
		title = "custom code",
		build = function()
			return newText("CBResources Custom Code", 0, 0, "Courier New", mrand(5, 30))
		end,
		onCreation = function(p)
			p._particlephysics.angularVelocity = mrand(-10, 10)
		end,
		perEmit=3,
		emitDelay=10,
		positionType="inRect",
		rectLeft=0,
		rectTop=0,
		rectWidth=display.contentWidth,
		rectHeight=display.contentHeight,
		physics={
			velocity=0
		}
	}

	
	myVent:start()

	local customText = newText(textString, 30, 0, display.contentWidth-30, 0, "Trebuchet MS", 25)
end

return custom