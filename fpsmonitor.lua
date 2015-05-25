module(..., package.seeall)  
local DebugLabel = display.newText("Debug",0,0,native.systemFont,30)
DebugLabel:setTextColor(255,255,255)
DebugLabel.x = display.contentWidth/2
DebugLabel.y = display.contentHeight/7
local LastTick = system.getTimer()
local averagePoint = 20
local nr = 1
local FPS = 0 
function tick()
	FPS = FPS + 1000/(system.getTimer() - LastTick)
	nr = nr + 1
	LastTick = system.getTimer() 
	if nr == averagePoint then
		FPS=FPS/averagePoint
		nr = 1
		DebugLabel.text = math.floor(FPS)
		FPS = 0
	end
end