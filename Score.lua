-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:

local empty_slots = {}   -- used to store the location and image of the star slot icons
local stars = {}         -- used to store the location and image of the star icons
local score = {}         -- The array that stores the scores that the player has (i.e. the number of coins, stars, vortexes and the total
local multiplier = 1     -- forgot :P
local coins              -- stores the location and image of the coins icon
local flame              -- stores the location and image of the flame icon
local vortex             -- stores the location and image of the vortex icon 
local text1              -- stores the location and text of the number of coins 
local text2              -- stores the location and text of the number of flames
local text3              -- stores the location and text of the number of vortexes
local text4              -- stores the location and text of the final score
local text5              -- stores the location of the text "final Score: "
local scoreCounter = {}  -- The array used to store the score counters (i.e. starts at zero and counts up until it reaches the actual score
local condition = 0      -- used to print the number of stars and make sure that all other displays are not shown before
local tick = 0           -- stores the timer
local threshold = 0      -- the variable used to store the delay before the scores start showing (after all stars are shown)

function animate()
	local constant = 0.05 -- this is used to store the constant value used to increase the alpha value of the displays
	tick = tick + 1       -- increments the timer 
	local increment = 13
	local increment2 = 23

	
	
	for i = 1,3 do -- for loop used to increase the value of alpha for the empty slots
		if empty_slots[i].alpha < 1 then -- checks that the alpha value of the empty slots is < 1 (which is the largest value alpha can take)
			empty_slots[i].alpha = empty_slots[i].alpha + constant -- increases the value of alpha by the constant variable
		end 
	end 
	



	if text3.alpha == 1 and text4.alpha < 1 then -- used to display the final score text
		text4.alpha = 1
	end 
	
	if tick > 50 then -- causes a delay before displaying the star icons
		if condition < score[1] then -- used to check that the program will display the right number of stars
			if stars[condition + 1].alpha < 1 then -- used to fade in the current star, else, move onto the next star
				stars[condition + 1].alpha =  stars[condition + 1].alpha + 0.05
			else
				condition = condition + 1
				if condition == score[1] then 
					threshold = tick + 50  -- used to give a value to the delay variable
					print (threshold)
				end
			end 
			print ("show", condition)
		end 
	end 
	

	if tick > threshold then -- used cause a delay
		
		if stars[score[1]].alpha == 1 and coins.alpha < 1 and text1.alpha < 1 then -- will start to fade in the coin, flame, vortex icons and all score
			if (coins.alpha + 0.05) > 1 then 
				coins.alpha = 1
			else
				coins.alpha = coins.alpha + 0.05
			end
			if (text1.alpha + 0.05) > 1 then 
				text1.alpha = 1
			else
				text1.alpha = text1.alpha + 0.05
			end
			if (flame.alpha + 0.05) > 1 then
				flame.alpha = 1
			else
				flame.alpha = flame.alpha + 0.05
			end
			if (text2.alpha + 0.05) > 1 then 
				text2.alpha = 1
			else
				text2.alpha = text2.alpha + 0.05
			end 
			if (vortex.alpha + 0.05) > 1 then
				vortex.alpha = 1
			else
				vortex.alpha = vortex.alpha + 0.05
			end
			if (text3.alpha + 0.05) > 1 then 
				text3.alpha = 1
			else
				text3.alpha = text3.alpha + 0.05
			end 
		end
		
		if flame.alpha == 1 then -- used to check that the texts are fully faded in before increasing the score counters all at the same time
			
			if scoreCounter[1] < score[2] and condition == score[1] and tick % 2 == 0 then
				 if (scoreCounter[1] + increment) > score[2] then
					scoreCounter[1] = score[2]
				else
					scoreCounter[1] = scoreCounter[1] + increment
				end 
				text1.text = scoreCounter[1]
			end 
			
			if scoreCounter[2] < score[3] and condition == score[1] and scoreCounter[1] == score[2] and tick % 2 == 0 then 
				if (scoreCounter[2] + increment) > score[3] then
					scoreCounter[2] = score[3]
				else
					scoreCounter[2] = scoreCounter[2] + increment
				end 
				text2.text = scoreCounter[2]
			end 
	
			if scoreCounter[3] < score[4] and condition == score[1] and (tick % 2 == 0) and scoreCounter[2] == score[3] then 
				if (scoreCounter[3] + increment ) > score[4] then
					scoreCounter[3] = score[4]
				else
					scoreCounter[3] = scoreCounter[3] + increment
				end
				text3.text = scoreCounter[3]
			end 
		end 
	
		score[5] = (score[2] + score[3] + score[4]) * (score[1] + 1) -- gives value to the final score
		if scoreCounter[4] < score[5] and scoreCounter[3] == score[4]  then -- increases the displayed final score until it is equal to the final score
			if (scoreCounter[4] + increment2) > score[5] then 
				scoreCounter[4] = score[5]
			else
			scoreCounter[4] = scoreCounter[4] + increment2
			end
			text4.text = scoreCounter[4]
		end 	
		if scoreCounter[4] == score[5] and condition < 100 then -- ensures that it will display the text "final score:" only once after the final score is revealed
		condition = 100	
		text5.alpha = 1
		end 
	end 
	
end
function scene:createScene( event )
	local group = self.view --sets all of the variables and constants used in this part of the program
	local coeff = 0.1
	local coeff2 = 0.2
	local spacing = display.contentWidth - 3 * (coeff * display.contentWidth)
	local spacing2 = display.contentWidth - 3 * (coeff2 * display.contentWidth)
	score[1] = 3
	score[2] = 999
	score[3] = 999
	score[4] = 999
	score[5] = 0
	scoreCounter[1] = 0
	scoreCounter[2] = 0
	scoreCounter[3] = 0
	scoreCounter[4] = 0
	
	

	
	
	for i = 1,3 do -- used to initialize the empty slot variables  
	empty_slots[i] = display.newImageRect( "crate.png", coeff * display.contentWidth, coeff * display.contentWidth)
	empty_slots[i].x = (i-1) * (coeff2 * display.contentWidth) + ((coeff2 * display.contentWidth)/2) + (i-1) * (spacing2/3)  + (spacing2/6)
	empty_slots[i].y = display.contentHeight/2
	group:insert(empty_slots[i])
	empty_slots[i].alpha = 0
	end
	
	for i = 1,3 do -- used to initialize the star variables 
	stars[i] = display.newImageRect("static star.jpg",1/3 * display.contentWidth,1/3 * display.contentWidth) 
	stars[i].x = empty_slots[i].x 
	stars[i].y = empty_slots[i].y
	stars[i].alpha = 0
	group:insert(stars[i])
	end
	
	coins = display.newImageRect("coins.jpg", coeff * display.contentWidth, coeff * display.contentWidth) --used to initialize the coin variable 
	coins.x = empty_slots[1].x
	coins.y = empty_slots[1].y + display.contentWidth * coeff + (spacing2/3)
	coins.alpha = 0
	group:insert(coins)
	
	flame = display.newImageRect("flame.jpg", coeff * display.contentWidth, coeff * display.contentWidth) -- flame variable
	flame.x = empty_slots[1].x
	flame.y = coins.y + display.contentWidth * coeff + (spacing2/6)
	flame.alpha = 0
	group:insert(flame)
	
	vortex = display.newImageRect("vacuum.jpg", coeff * display.contentWidth, coeff * display.contentWidth) -- vortex variable
	vortex.x = flame.x
	vortex.y = flame.y + display.contentWidth * coeff + (spacing2/6)
	vortex.alpha = 0
	group:insert(vortex)
	
	text1 = display.newText(scoreCounter[1], 0, 0, native.systemFont,30) -- coins score
	text1:setTextColor(255, 255, 255)
	text1.x = empty_slots[3].x
	text1.y = coins.y
	text1.alpha = 0
	group:insert(text1)
	
	text2 = display.newText(scoreCounter[2], 0,0, native.systemFont,30) -- flame score
	text2:setTextColor(255,255,255)
	text2.x = empty_slots[3].x
	text2.y = flame.y
	text2.alpha = 0
	group:insert(text2)
	
	text3 = display.newText(scoreCounter[3], 0,0, native.systemFont,30) -- vortex score
	text3:setTextColor(255,255,255)
	text3.x = empty_slots[3].x
	text3.y = vortex.y
	text3.alpha = 0
	group:insert(text3)
	
	text4 = display.newText(scoreCounter[4], 0,0, native.systemFont,30) -- final score
	text4:setTextColor(255,255,255)
	text4.x = empty_slots[3].x
	text4.y = vortex.y + display.contentWidth * coeff + (spacing/6)
	text4.alpha = 0
	group:insert(text4)
	
	text5 = display.newText("Final score:", 0,0, native.systemFont, 30)
	text5:setTextColor(255,255,255)
	text5.x = empty_slots[1].x * 2
	text5.y = text4.y
	text5.alpha = 0
	group:insert(text5)

	

end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	Runtime:addEventListener("enterFrame", animate)
	physics.start()
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	physics.stop()
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	package.loaded[physics] = nil
	physics = nil
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene