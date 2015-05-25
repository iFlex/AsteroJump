--------------------------------------------------------------------------------
--[[
HelloWorldRandomized

HelloWorld tutorial with random phrase choice.
--]]
--------------------------------------------------------------------------------

local CBE = require("CBEffects.Library")

local newText = display.newText
local mrand = math.random

local helloWorldList={
	"Hello, world!", -- Normal version
	"print(\"Hello, world!\")", -- Programmer version
	"Hola, mundo!", -- Español version
	"Howdy, world!" -- Cowboy version
}

local hello=CBE.NewVent{
	title = "HelloWorld",
	preset = "fluid", -- Use a different preset just to make it interesting
	build = function()
		local index = mrand(#helloWorldList) -- Random index of the helloWorldList
		return newText(helloWorldList[index], 0, 0, "Trebuchet MS", 30)
	end
}

hello:start()