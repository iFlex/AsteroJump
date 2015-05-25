module(..., package.seeall)
-- Your code here
local screenW = display.contentWidth
local screenH = display.contentHeight

local circle = nil
local scaleCoeff = 0.1
local degree = 8
--local group = nil;
local stillLoading = false;
function init()
		rect = display.newRect(0,0,display.contentWidth,display.contentHeight)
		rect:setFillColor(0,0,0)
		rect.alpha = 0.5
		rect.isVisible = false 
		
		circle = display.newImage("loaderimg.png")
		circle.x = screenW/2
		circle.y = screenH/2
		circle.width = screenW * scaleCoeff
		circle.height = circle.width
		circle.isVisible = false
	
	print("Initialised Loader screen");
end

local function showLoading(event)
	if circle and circle.isVisible then
		circle:rotate(degree)	
		print("Rotating loader")
		if(stillLoading) then
			timer.performWithDelay(100,showLoading,1)
		end
	end
end

function trigger(x,y)
	circle.x = x;
	circle.y = y;
	circle.isVisible = true;
	rect.isVisible = true;
	
	stillLoading = true;
	timer.performWithDelay(100,showLoading,1)
end

function clear()
	if circle then
		stillLoading = false;
		circle:removeSelf()
		rect:removeSelf()
		circle = nil
		rect = nil
		print("Loader cleared");
	end
end
