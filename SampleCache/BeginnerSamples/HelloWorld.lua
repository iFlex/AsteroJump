--------------------------------------------------------------------------------
--[[
HelloWorld

Loads the water preset and changes particles to text objects that say "Hello, World!"

This is the CBEffects version of the classic tutorial :)
--]]
--------------------------------------------------------------------------------

local CBE = require("CBEffects.Library")

local newText = display.newText

local hello = CBE.NewVent{
	preset = "water", -- An interesting effect
	build = function()
		return newText("Hello, World!", 0, 0, "Trebuchet MS", 30)
	end
}

hello:start()