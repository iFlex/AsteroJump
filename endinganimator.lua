-- requires 
local storyboard = require ("storyboard")
local widget = require "widget"
local scene = storyboard.newScene()

-- background
local group
local backButton
local retryButton
local nextButton
local sheetParam 
local sequenceData
local teleSheet
local EndAnimation
local Delay = 2000
local DebugLabel
----------------------------------------------------------
--------------Gregor's code

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
	local slid = display.contentWidth / 10

	
	
	for i = 1,3 do -- for loop used to increase the value of alpha for the empty slots
		if (empty_slots[i].alpha + constant) < 1 then -- checks that the alpha value of the empty slots is < 1 (which is the largest value alpha can take)
			empty_slots[i].alpha = empty_slots[i].alpha + constant -- increases the value of alpha by the constant variable
		else
			empty_slots[i].alpha = 1
		end 
	end 
	if tick > 50 then
		if score[1] > 0 and condition < 3 then
			if condition < score[1] then -- used to check that the program will display the right number of stars
				if stars[condition + 1].alpha < 1 then -- used to fade in the current star, else, move onto the next star
					if stars[condition + 1].alpha > 0.9 then
						stars[condition + 1].alpha = 1
					else
						stars[condition + 1].alpha = stars[condition + 1].alpha + (1 - stars[condition + 1].alpha) / 10
					end
				else
					condition = condition + 1
					if condition == score[1] then 
						threshold = tick + 50  -- used to give a value to the delay variable
						condition = 4
					end
				end 
			end  
		else
			if condition < 4 then 
				condition = 4
				threshold = tick 
			end 
		end 
	end
	
	if tick > threshold and threshold ~= 0 then -- used to cause a delay
		if (score[1] == 0 or stars[score[1]].alpha == 1) and coins.alpha < 1 then -- will start to fade in the coin, flame, vortex icons and all score
			if (coins.alpha + 0.05) > 1 then 
				coins.alpha = 1
			else
				coins.alpha = coins.alpha + 0.05
			end
			if (flame.alpha + 0.05) > 1 then
				flame.alpha = 1
			else
				flame.alpha = flame.alpha + 0.05
			end
			if (vortex.alpha + 0.05) > 1 then
				vortex.alpha = 1
			else
				vortex.alpha = vortex.alpha + 0.05
			end
		end
		
		if flame.alpha == 1 then -- used to check that the texts are fully faded in before increasing the score counters all at the same time
			--print (flame.alpha)
			if text1.x ~= empty_slots[3].x and tick % 2 == 0 then
				 if (text1.x - slid) < empty_slots[3].x then
					text1.x = empty_slots[3].x
				else
					text1.x = text1.x - slid
				end 
			end 
			
			if text2.x ~= empty_slots[3].x and text1.x == empty_slots[3].x and tick % 2 == 0 then 
				if (text2.x - slid) < empty_slots[3].x then
					text2.x = empty_slots[3].x
				else
					text2.x = text2.x - slid
				end 
			end 
	
			if text3.x ~= empty_slots[3].x and (tick % 2 == 0) and text2.x == empty_slots[3].x then 
				if (text3.x - slid) < empty_slots[3].x then
					text3.x = empty_slots[3].x
				else
					text3.x = text3.x - slid
				end
			end 
		end 
	
		
		if text3.x == empty_slots[3].x then -- increases the displayed final score until it is equal to the final score
			if ( text4.x - slid ) < empty_slots[3].x then
				text4.x = empty_slots[3].x
			else
				text4.x = text4.x - slid
			end
		end 	
		if text4.x == empty_slots[3].x  and condition < 100 then -- ensures that it will display the text "final score:" only once after the final score is revealed
		condition = 100	
		text5.alpha = 1
		end 
	end 
	
end
function setUp( )
	local coeff = 0.08
	local coeff2 = 0.15
	local coeff3 = 0.01
	local spacing = display.contentWidth - 3 * (coeff * display.contentWidth)
	local spacing2 = display.contentWidth - 3 * (coeff2 * display.contentWidth)
	score[1] = nrStars
	score[2] = nrGold
	score[3] = nrFlames
	score[4] = nrVacums
	score[5] = (score[2] + score[3] + score[4]) * (score[1] + 1)
	scoreCounter[1] = 0
	
	
	for i = 1,3 do -- used to initialize the empty slot variables  
	empty_slots[i] = display.newImageRect( SELECTED_SKIN_PACK.."EmptyStar.png",SKIN_BASE_DIR, 1/3 * display.contentWidth * 0.6, 1/3 * display.contentWidth* 0.6)
	empty_slots[i].x = (i-1) * (coeff2 * display.contentWidth) + ((coeff2 * display.contentWidth)/2) + (i-1) * (spacing2/3)  + (spacing2/6)
	empty_slots[i].y = display.contentHeight/2 + (1.8 * coeff * display.contentWidth)
	group:insert(empty_slots[i])
	empty_slots[i].alpha = 0
	end
	
	for i = 1,3 do -- used to initialize the star variables 
	stars[i] = display.newImageRect(SELECTED_SKIN_PACK.."staticstar.png",SKIN_BASE_DIR,1/3 * display.contentWidth * 0.6,1/3 * display.contentWidth * 0.6) 
	stars[i].x = empty_slots[i].x 
	stars[i].y = empty_slots[i].y
	stars[i].alpha = 0
	group:insert(stars[i])
	end
	
	coins = display.newImageRect(SELECTED_SKIN_PACK.."move.png",SKIN_BASE_DIR, coeff * display.contentWidth, coeff * display.contentWidth) --used to initialize the coin variable 
	coins.x = empty_slots[1].x
	coins.y = empty_slots[1].y + display.contentWidth * coeff3 + (spacing2/3)
	coins.alpha = 0
	group:insert(coins)
	
	flame = display.newImageRect(SELECTED_SKIN_PACK.."flame.png",SKIN_BASE_DIR, coeff * display.contentWidth, coeff * display.contentWidth) -- flame variable
	flame.x = empty_slots[1].x
	flame.y = coins.y + display.contentWidth * coeff3 + (spacing2/6)
	flame.alpha = 0
	group:insert(flame)
	
	vortex = display.newImageRect(SELECTED_SKIN_PACK.."vacuum.png",SKIN_BASE_DIR, coeff * display.contentWidth, coeff * display.contentWidth) -- vortex variable
	vortex.x = flame.x
	vortex.y = flame.y + display.contentWidth * coeff3 + (spacing2/6)
	vortex.alpha = 0
	group:insert(vortex)
	
	text1 = display.newText(score[2], 0, 0, native.systemFont,30) -- coins score
	text1:setTextColor(255, 255, 255)
	text1.x = display.contentWidth * 2
	text1.y = coins.y
	text1.alpha = 1
	group:insert(text1)
	
	text2 = display.newText(score[3], 0,0, native.systemFont,30) -- flame score
	text2:setTextColor(255,255,255)
	text2.x = display.contentWidth * 2
	text2.y = flame.y
	text2.alpha = 1
	group:insert(text2)
	
	text3 = display.newText(score[4], 0,0, native.systemFont,30) -- vortex score
	text3:setTextColor(255,255,255)
	text3.x = display.contentWidth * 2
	text3.y = vortex.y
	text3.alpha = 1
	group:insert(text3)
	
	text4 = display.newText(score[5], 0,0, native.systemFont,30) -- final score
	text4:setTextColor(255,255,255)
	text4.x = display.contentWidth * 2
	text4.y = vortex.y + display.contentWidth * coeff
	text4.alpha = 1
	group:insert(text4)
	
	text5 = display.newText("Final score:", 0,0, native.systemFont, 30)
	text5:setTextColor(255,255,255)
	text5.x = empty_slots[1].x * 1.85
	text5.y = text4.y
	text5.alpha = 0
	group:insert(text5)

end

-- Called immediately after scene has moved onscreen:
function enter( event )
	Runtime:addEventListener("enterFrame", animate)	
end

------------------------
------------------------


local function onBack()
	storyboard.removeScene("engine")
	storyboard.removeScene("endinganimator")
	storyboard.gotoScene(BEFORE_ENGINE_SCENE,"fade",fdspd)
end
local function onNext()
	print("CurLev:",CurrentLevel)
	local oldLvl = CurrentLevel
	local pidx = CurrentLevel:find(".lvl")
	print("found dot:",pidx)
	local nr = ""
	local i = 6
	while i < pidx do
		nr = nr..CurrentLevel:sub(i,i)
		i = i+1
	end
	nr = tonumber(nr)
	nr = nr+1
	nr = tostring(nr)
	CurrentLevel = CurrentLevel:sub(0,5)
	CurrentLevel = CurrentLevel..nr
	print("Going to next level:",CurrentLevel)
	local found = false
	for token in LEVEL_LIST.gmatch(LEVEL_LIST, "[%w]+") do
		print("level:",token," next:",CurrentLevel)
		if(CurrentLevel == token) then
			found = true
			CurrentLevel = CurrentLevel..".lvl"
			break
		end
	end
	storyboard.removeScene("endinganimator")
	if found then
		if oldLvl ~= CurrentLevel then
			print("Different levels, removing old scene",oldLvl,CurrentLevel)
			storyboard.removeScene("engine")
		end
		storyboard.gotoScene("engine","fade",fdspd)
	else
		if BEFORE_ENGINE_SCENE ~= "levels" then
			BEFORE_ENGINE_SCENE = "chapterBrowser"
			CURRENT_CHAPTER = CURRENT_CHAPTER + 1
		end
		storyboard.gotoScene(BEFORE_ENGINE_SCENE,"fade",fdspd)
	end
end
local function onRetry()
	storyboard.removeScene("endinganimator")
	storyboard.gotoScene("engine","fade",fdspd)
end
local function ClearAnimation(e)
	EndAnimation:pause()
	EndAnimation = nil
end
local function Restart()
	if EndAnimation then
		EndAnimation:play()
	end
end
local function RepeatAnimation(e)
	if(e.phase == "ended") then
		timer.performWithDelay(Delay,Restart,1)
	end
end
function scene:createScene(event)
	--save score
	local store_location = nil
	local levelData = {}
	-- this only ensures that no matter what level name the user chooses for custom levels
	-- it will never conflict with the story levels ( example: user builds custom level called level1 )
	if CurrentLevelType == "story" then
		store_location = system.ResourceDirectory;
	else
		store_location = system.DocumentsDirectory;
	end
	
	group = self.view
	--todo precalculate final score before starting animations ( to be able to store it in the file )
	setUp();
	if( GameEndReason == "Finished!")then
		--build score vector
		levelData["stars"] = nrStars
		levelData["score"] = score[5]
		--
		ScoreRecorder.update_score(system.pathForFile( "", store_location).."/"..CurrentLevel,levelData)
	end
	local sizeCoef = 0.2
	backButton = widget.newButton{
		defaultFile="backButton.png",
		overFile="backButtonOver.png",
		width = display.contentWidth*sizeCoef, height = display.contentWidth*sizeCoef,
		onRelease = onBack	-- event listener function
	}
	retryButton = widget.newButton{
		defaultFile = "retryButton.png",
		overFile = "retryButtonOver.png",
		width = backButton.width,
		height = backButton.height,
		onRelease = onRetry,
	}
	nextButton = widget.newButton{
		defaultFile = "playButton.png",
		overFile = "playButtonOver.png",
		width = backButton.width,
		height = backButton.height,
		onRelease = onNext,
	}
	retryButton.x = display.contentWidth/2
	retryButton.y = display.contentHeight-retryButton.height/2
	backButton.y = retryButton.y
	nextButton.y = retryButton.y
	
	backButton.x = retryButton.x - retryButton.width - backButton.width
	nextButton.x = retryButton.x + retryButton.width + backButton.width
	
	DebugLabel = display.newText(GameEndReason,0,0,native.systemFont,display.contentWidth*0.1)
	DebugLabel:setTextColor(255,255,255)
	DebugLabel.x = display.contentWidth/2
	DebugLabel.y = display.contentHeight/2
	
	sheetParam = { width=107, height=127, numFrames=4, sheetContentWidth=107, sheetContentHeight=509} 
	sequenceData = {name = "normalRun", start=1, count=4, time=200,loopDirection = "bounce",loopCount = 1}
	teleSheet = graphics.newImageSheet(SELECTED_SKIN_PACK.."PlayerStandingAnimation.png",SKIN_BASE_DIR , sheetParam )
	EndAnimation = display.newSprite( teleSheet, sequenceData )
	EndAnimation.x = display.contentWidth/2
	EndAnimation.y = display.contentHeight/4
	EndAnimation:addEventListener("sprite",RepeatAnimation)
	EndAnimation:play()
	
	group:insert(EndAnimation)
	group:insert(DebugLabel)
	group:insert(retryButton)
	group:insert(backButton)
	group:insert(nextButton)

	if NO_RETRY then
		retryButton.isVisible = false
	end
	if NO_NEXT  then
		nextButton.isVisible = false
	end
	--reset controller
	NO_RETRY = false
	NO_NEXT = false
end

function scene:enterScene(event)
	enter();
end

function scene:exitScene(event)
end

function scene:destroyScene(event)
	EndAnimation:pause()
	Runtime:removeEventListener("enterFrame", animate)
	EndAnimation = nil
end


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













