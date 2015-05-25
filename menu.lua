-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------
local NO_BUILD = "android_1.0.1"

MENU_ANIMATION_RUNNING = false
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
-- include Corona's "widget" library
local widget = require "widget"
DECORATOR = require("DecorateBKG")
display.setDefault( "background", 0, 0, 0)
local showLoad = require("loadScreen")
--constants
BKG_ALPHA = 0.1
--------------------------------------------
--debug
local function BypassLevelBrowser()
	local path = system.pathForFile( "ToShow", system.TemporaryDirectory )
	-- io.open opens a file at path. returns nil if no file found
	local fh, reason = io.open( path, "w" )
	if fh then
		-- read all contents of file into a string
		fh:write("level1,level2,level3,level4,level5,level6,level7,level8,level9,level10,level11,level12")
	else
		print( "Reason open failed: " .. reason )  -- display failure message in terminal
	end
	io.close( fh )
	storyboard.gotoScene("showLevels","fade",fdspd)
end
-- forward declarations and other locals
local MENU_ITEMS_SPACE = 45
local buttonSizeCoef = 0.55
local playBtn
local levelDesignerBtn
local levelBrowserBtn
local DesLabel
local PlayLabel

local decorAstero
local player

local menuItems = {}
local lastX = -100;
local background
local NormaliserEnable = false

local mrotor;
local Mrotor;

local currentTopButton = 2;

local jumpFlag = 0;
local jumpTarget = 2;
local waitToExit = 500;
-- 'onRelease' event listener for playBtn
local function SwitchAnimation(index)
		if(player.animationIndex == index or index > #player.animations ) then
			return
		end
		if(player.animationIndex ~= 0) then
			player.animations[player.animationIndex]:pause()
			player.animations[player.animationIndex].isVisible = false
		end
		player.animationIndex = index
		player.animations[index].x = player.x
		player.animations[index].y = player.y
		player.animations[index].width = player.width
		player.animations[index].height = player.height
		player.animations[index].isVisible = true
		player.animations[index]:play()
end

local function absorbPlayer()
	local absorbCoef = 5
	local dampCoef = 0.9
					
	if(jumpTarget == 1)then
		absorbCoef = 1;
	end	
	
	local difx = player.x - menuItems[jumpTarget].x
	local dify = player.y - menuItems[jumpTarget].y
	local angle = math.atan2(dify,difx)
	local angle = angle + math.rad(absorbCoef)
	local radius = math.sqrt(difx^2 + dify^2)
	local oldWidth = player.width
	player.width = player.width * dampCoef
	player.height = player.height * dampCoef
	radius = (radius * player.width)/oldWidth
	if( absorbCoef == 1)then
		radius = (player.width+menuItems[jumpTarget].width)/2*dampCoef
	end
	player.x = menuItems[jumpTarget].x + radius * math.cos(angle)
	player.y = menuItems[jumpTarget].y + radius * math.sin(angle)
	if( player.width < 2 or player.height < 2 ) then
		jumpFlag = 3
	end
end

local function attachPlayer()
	local angle = math.atan2(player.y - menuItems[jumpTarget].y,player.x - menuItems[jumpTarget].x);
	local dist = (player.width+menuItems[jumpTarget].width)/2*0.87
	player.x = menuItems[jumpTarget].x + dist*math.cos(angle)
	player.y = menuItems[jumpTarget].y + dist*math.sin(angle)
	player.rotation = math.deg(angle)+90
	jumpFlag = 3
	SwitchAnimation(1)
end

local function settlePlayer()
	if jumpFlag == 1 then
		for i =1,#menuItems do
			local dist = math.sqrt((player.x - menuItems[jumpTarget].x)^2+(player.y - menuItems[jumpTarget].y)^2)
			if( dist < (player.width+menuItems[jumpTarget].width)/2*0.9) then--collision
				jumpFlag = 2
				break;
			end
		end
	end
	if jumpFlag == 2 then
		if jumpTarget == 2 or jumpTarget == 1 then
			absorbPlayer()
		else
			attachPlayer()
		end
	end
end
local function jumpToTarget(trg)
	jumpFlag = 1
	jumpTarget = trg
	SwitchAnimation(4)
	player.rotation = math.deg(math.atan2(player.y - menuItems[trg].y,player.x - menuItems[trg].x)-90)
	if(menuItems[trg].angle<90) then
		player.rotation = menuItems[trg].angle 
	elseif menuItems[trg].angle == 90 then
		player.rotation = menuItems[trg].angle - 90
	else
		player.rotation = menuItems[trg].angle + 90
	end
end
local function GoToAppropriate()
	if(jumpTarget == 3) then
		storyboard.gotoScene( "levels", "fade", fdspd )
	elseif jumpTarget == 2 then
		storyboard.gotoScene( "chapterBrowser", "fade", fdspd )
	elseif jumpTarget == 1 then
		storyboard.gotoScene( "levelDesigner", "fade", fdspd )
	end
end 
local allowMove = false
local distance = 0;
local MAX_DIST = display.contentWidth/4;
local slide_dir = 0
local slamFlag = false
function commonBegan(event)
	if jumpFlag < 3 and event.phase == "began" then
		NormaliserEnable = false
		allowMove = true
		distance = 0;
		slide_dir = 0;
	end
end
function commonMoved(event)
	if allowMove and not NormaliserEnable then
	if( lastX > 0 )then	
		slide_dir =  lastX - event.x 
		moveItems( slide_dir , 0.5)
		distance = distance + math.abs(lastX-event.x)
	end
	lastX = event.x
	if(distance > MAX_DIST)then
		--print("GIVE CONTROL TO ANIMATOR")
		NormaliserEnable = true
		allowMove = false
		getClosestButton()
	end
	end
end
function commonEnded(event)
	if allowMove and not NormaliserEnable then
		if slide_dir ~= 0 then
			NormaliserEnable = true
			getClosestButton()
		end
		allowMove = false
		sp = currentTopButton
		distance = 0
		slamFlag = false
	end
end
local function onLevelBrowseRelease(e)
	if e.phase == "began" then
		commonBegan(e)
	elseif e.phase == "moved" then
		commonMoved(e)
	else
		commonEnded(e)
		if slide_dir == 0 then
			jumpToTarget(3)
			DesLabel.isVisible = false
			--timer.performWithDelay(waitToExit,GoToAppropriate,1)
		end
	end
	return true	-- indicates successful touch
end
local function onLevelDesignerRelease(e)
	if e.phase == "began" then
		commonBegan(e)
	elseif e.phase == "moved" then
		commonMoved(e)
	else
		commonEnded(e)
		if slide_dir == 0 then
			jumpToTarget(1)
			DesLabel.isVisible = false
			--timer.performWithDelay(waitToExit,GoToAppropriate,1)
		end
	end
	return true-- indicates successful touch
end
local function onPlayBtnRelease(e)
	if e.phase == "began" then
		commonBegan(e)
	elseif e.phase == "moved" then
		commonMoved(e)
	else
		commonEnded(e)
		if slide_dir == 0 then
			--debug
			jumpToTarget(2)
			PlayLabel.isVisible = false
			--timer.performWithDelay(waitToExit,GoToAppropriate,1)
			--BypassLevelBrowser()
		end
	end
	return true	-- indicates successful touch
end
local function onAboutPress(e)
	if e.phase == "began" then
		commonBegan(e)
	elseif e.phase == "moved" then
		commonMoved(e)
	else
		commonEnded(e)
		if slide_dir == 0 then
			jumpToTarget(4)
			PlayLabel.isVisible = false
		end
	end
	return true	-- indicates successful touch
end
-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-----------------------------------------------------------------------------------------
-- Called when the scene's view does not exist:
function applyChangesToOwned(entity)
	if(entity.owning) then
		for key,val in pairs(entity.owning) do
			val["dobj"].x = entity.x * val["x_rel"] 
			val["dobj"].y = entity.y * val["y_rel"]
			val["dobj"].angle = entity.rotation * val["a_rel"]
			
			--val["dobj"].width = entity.width * val["w_rel"]
			--val["dobj"].height = entity.height * val["h_rel"]
		end
	end
end
function CorrectPosition(entity)

	local radius = display.contentHeight*0.6--ath.sqrt((entity.x-decorAstero.x)^2+(entity.y-decorAstero.y)^2)
	--taking care of position
	entity.x = decorAstero.x + radius*math.cos(math.rad(entity.angle))
	entity.y = decorAstero.y + radius*math.sin(-math.rad(entity.angle))
	--taking care of size
	local cf = 0.30
	if entity.x >= 0 and entity.x <= display.contentWidth and buttonSizeCoef > cf  then
		cf = cf + (buttonSizeCoef - cf)* math.sin( math.rad( (entity.x*180)/display.contentWidth ));
		--print( "entity presumed angle", (entity.x*180)/display.contentWidth, "actual angle", entity.angle, "cf", cf )
	end
	entity.size = math.floor(display.contentWidth*cf);
end

function moveItems(dir,amount)
	if(dir > 0) then
		dir = 1
	elseif dir < 0 then
		dir = -1
	else
		return 
	end
	for i =1,#menuItems do
		--print("Before",menuItems[i].angle,"after",(menuItems[i].angle + amount*dir)%360)
		menuItems[i].angle = (menuItems[i].angle + amount*dir)%360
		CorrectPosition(menuItems[i])
	end
end
function moveMenu(event)
	--if event.phase == "began" then
	--	slamFlag = true
	--end
	print("moveMenu function")
	if jumpFlag < 3 and event.phase == "began" then
		commonBegan(event)
	end
	if allowMove and not NormaliserEnable and event.phase == "moved" then
		commonMoved(event)
	end
	if allowMove and not NormaliserEnable and event.phase == "ended" then
		commonEnded(event)
	end
	--print("Phase",event.phase,"NormaliserEnable",NormaliserEnable,"slide_dir",slide_dir)
end
function getClosestButton()
	local dir = 0
	local otherLim = 0
	local start = 0
	local stop = 0
	if slide_dir > 0 then
		dir = 1
		start = currentTopButton + 1
		stop = #menuItems
		if(start > #menuItems)then
			start = #menuItems
		end
	elseif slide_dir < 0 then
		dir = -1
		start = 1
		stop = currentTopButton - 1
		if( stop == 0 )then
			stop = 1
		end
	end
	
	minDist = display.contentWidth
	sp  = 0
	print ("cuising interval:",start,stop,dir,currentTopButton,"sd",slide_dir)
	if start == stop and start ~= 0 then
		print("Special edge case",start,currentTopButton)
		sp = start
	else
		if stop > 0 and start<= #menuItems then
			print("cruising...")
			for i = start,stop do
				if( minDist > math.abs( menuItems[i].angle - 90 ) )then--and i ~= currentTopButton ) then
					minDist = math.abs( menuItems[i].angle - 90 )
					sp = i
				end		
			end
		end
	end
	
	if( sp > 0 ) then 
		currentTopButton = sp
	else
		sp = currentTopButton
	end
	--make sure it slides in the right direction
	slide_dir = 90 - menuItems[sp].angle
	print("CTB",currentTopButton)
end
local function SwitchAnimBack(e)
	if(e.phase == "ended")then
		SwitchAnimation(1)
	end
end

local Tick = 0
function animate(event)
	DECORATOR.animate()

	if not MENU_ANIMATION_RUNNING then
		return
	end
	-- do all continuous actions here
	if mrotor then
		--Mrotor:rotate(-0.3)
		mrotor:rotate(0.5)
	end
	Tick = Tick+1
	if player.animationIndex == 1 and jumpFlag < 2 then
		if( Tick % player.period == 0 ) then
			local choice = math.floor(math.random() * player.randomize)%5+2
			print("animating:",choice)
			SwitchAnimation(choice)
			if(player.randomize)then
				local rand =  math.floor(math.random() * player.randomize)
				if(rand>0)then
					player.period = rand
				end
			end
		end
	end
			
	for i=1,#menuItems do
		if menuItems[i].width ~= menuItems[i].size then
			if i == 2 then
				--print("updateing size",menuItems[i].width,"->",menuItems[i].size)
			end
			--menuItems[i].width = menuItems[i].size;
			--menuItems[i].height = menuItems[i].size;
		end
		applyChangesToOwned(menuItems[i])
	end
	if player.animationIndex ~= 0 then
		player.animations[player.animationIndex].x = player.x
		player.animations[player.animationIndex].y = player.y
		player.animations[player.animationIndex].width = player.width
		player.animations[player.animationIndex].height = player.height
		player.animations[player.animationIndex].rotation = player.rotation
	end
	-- do all menu and player actions here
	if jumpFlag > 3 then
		return
	end
	if jumpFlag == 3 then
		--call exit function
		timer.performWithDelay(waitToExit,GoToAppropriate,1)
		jumpFlag = 4
		return
	end
	if jumpFlag == 1 then
		local spd = 20
		local radius = math.sqrt((player.x - menuItems[jumpTarget].x)^2+(player.y - menuItems[jumpTarget].y)^2)
		local angle = math.atan2(player.y - menuItems[jumpTarget].y,player.x - menuItems[jumpTarget].x);
		player.x = player.x - radius/spd*math.cos(angle)
		player.y = player.y - radius/spd*math.sin(angle)
	end
	settlePlayer()
	
	if NormaliserEnable and slide_dir ~= 0 then
		local amount = 2
		--get closest element to 90	
		if minDist ~= 0 then
			NormaliserEnable = not (menuItems[sp].x == display.contentWidth/2)	
			if NormaliserEnable == true then
				local dst = math.abs(90.0 - menuItems[sp].angle)
				
				if not slamFlag then
					dst = dst / 10
				end
				moveItems(slide_dir,dst)
			end
		end
	end
	--[[local amount = 1
	local dir = -1
	for i =1,#menuItems do
		menuItems[i].angle = menuItems[i].angle + amount*dir
		if i == 2 then
			CorrectPosition(menuItems[i])
		end
	end]]--
end
function scene:createScene( event )
	print ("creating menu scene")
	local group = self.view
	-- display a background image
	background = display.newRect( 0,0,display.contentWidth, display.contentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0, 0
	background:setFillColor(0,0,0)
	background:addEventListener("touch",moveMenu)
	DECORATOR.initDecorator(nil,{noGroup = true})
	-- create/position logo/title image on upper-half of the screen
	mrotor = display.newImageRect("minrotor.png",display.contentHeight*2.1,display.contentHeight*2.1)
	mrotor.alpha = 0.3
	--Mrotor = display.newImageRect("Mrotor.png",display.contentHeight*2.1,display.contentHeight*2.1)
	--Mrotor.alpha = 0.0 -- 0.1
	
	local titleLogo = display.newImage( "title.png")
	local ratio = titleLogo.height/titleLogo.width;
	titleLogo.width = display.contentWidth*0.9;
	titleLogo.height = titleLogo.width * ratio;
	
	titleLogo.x = display.contentWidth * 0.5
	titleLogo.y = titleLogo.height/2*1.05

	-- create a widget button (which will loads level1.lua on release)
	playBtn = widget.newButton{
		defaultFile="b_play_button.png",
		overFile="b_play_button_over.png",
		width=display.contentWidth*buttonSizeCoef, height=display.contentWidth*buttonSizeCoef,
		onEvent = onPlayBtnRelease	-- event listener function
	}
	playBtn:addEventListener("touc",moveMenu)
	
	playBtn.anchorX = 0.5
	playBtn.anchorY = 0.5
	PlayLabel = display.newText("Play",0,0,native.systemFont,playBtn.width/3)
	PlayLabel:setTextColor(255,255,255)
	
	playBtn.owning = { item1 = {dobj = PlayLabel, x_rel = 1, y_rel = 1, w_rel = 1, h_rel = 1, a_rel = 1} };
	
	levelDesignerBtn = widget.newButton{
		defaultFile="b_lds_button.png",
		overFile="b_lds_button_over.png",
		width=display.contentWidth*buttonSizeCoef, height=display.contentWidth*buttonSizeCoef,
		onEvent = onLevelDesignerRelease-- event listener function
	}
	levelDesignerBtn:addEventListener("touc",moveMenu)
	
	levelBrowserBtn = widget.newButton{
		defaultFile="b_lbsr_button.png",
		overFile="b_lbsr_button_over.png",
		width=display.contentWidth*buttonSizeCoef, height=display.contentWidth*buttonSizeCoef,
		onEvent = onLevelBrowseRelease-- event listener function
	}
	levelBrowserBtn:addEventListener("touc",moveMenu)
	
	DesLabel = display.newText("Make\nLevel",0,0,native.systemFont,levelDesignerBtn.width/4)
	DesLabel:setTextColor(255,255,255)
	
	levelDesignerBtn.owning = { item1 = {dobj = DesLabel, x_rel = 1, y_rel = 1, w_rel = 1,h_rel = 1, a_rel = 1} }
	
	aboutBtn = widget.newButton{
		defaultFile="b_about_button.png",
		overFile="b_about_button_over.png",
		width=display.contentWidth*buttonSizeCoef, height=display.contentWidth*buttonSizeCoef,
		onEvent = onAboutPress-- event listener function
	}
	
	local siz = display.contentWidth * 0.4;
	decorAstero = display.newImageRect(SELECTED_SKIN_PACK.."rock1.png",SKIN_BASE_DIR,siz,siz);
	decorAstero.width = siz
	decorAstero.height = siz
	
	decorAstero.x = display.contentWidth/2;
	decorAstero.y = display.contentHeight;
	
	mrotor.x = decorAstero.x
	mrotor.y = decorAstero.y
	--Mrotor.x = decorAstero.x
	--Mrotor.y = decorAstero.y
	
	player = display.newImage(SELECTED_SKIN_PACK.."player.png",SKIN_BASE_DIR);

	playBtn.angle = 90;
	levelDesignerBtn.angle = 90+MENU_ITEMS_SPACE
	levelBrowserBtn.angle = 90-MENU_ITEMS_SPACE
	aboutBtn.angle = 90-2*MENU_ITEMS_SPACE 
	
	CorrectPosition(playBtn)
	CorrectPosition(levelDesignerBtn)
	CorrectPosition(levelBrowserBtn)
	CorrectPosition(aboutBtn)
	
	menuItems[1] = levelDesignerBtn
	menuItems[2] = playBtn
	menuItems[3] = levelBrowserBtn
	menuItems[4] = aboutBtn
	
	for i =1,#menuItems do
		menuItems[i].size = menuItems[i].width
	end
	
	-- for debug purposes
	verLabel = display.newText("BUILD: "..NO_BUILD,0,0,native.systemFont,playBtn.width/10)
	verLabel:setTextColor(255,255,255)
	
	-- all display objects must be inserted into group
	group:insert( background )
	
	--group:insert( Mrotor )
	group:insert( mrotor )
	group:insert( titleLogo )
	group:insert( playBtn )
	group:insert( PlayLabel ) 
	group:insert( levelDesignerBtn )
	group:insert( DesLabel )
	group:insert( levelBrowserBtn )
	group:insert( aboutBtn )
	group:insert( decorAstero )
	group:insert( player )
	group:insert( verLabel )
	--this main timer will be runnign for as long as the game is running
	--and will support the background animation for any frame
	--setup animations
	player.animationIndex = 0
	player.animations = {}
	
	local sheetParam = { width=107, height=127, numFrames=1, sheetContentWidth=107, sheetContentHeight=127} 
	local sequenceData = {name = "normalRun", start=1, count=1, time=200,loopDirection = "forward"}
	local teleSheet = graphics.newImageSheet(SELECTED_SKIN_PACK.."player.png",SKIN_BASE_DIR, sheetParam)
	player.animations[1] = display.newSprite( teleSheet, sequenceData)
	player.animations[1].isVisible = false
	player.animations[1].name = "player"
	
	sheetParam = { width=107, height=127, numFrames=4, sheetContentWidth=107, sheetContentHeight=509} 
	sequenceData = {name = "normalRun", start=1, count=4, time=200,loopCount = 3}
	teleSheet = graphics.newImageSheet(SELECTED_SKIN_PACK.."PlayerStandingTele.png",SKIN_BASE_DIR, sheetParam )
	player.animations[2] = display.newSprite( teleSheet, sequenceData)
	player.animations[2].isVisible = false
	player.animations[2]:addEventListener("sprite",SwitchAnimBack)
	player.animations[2].name = "player"
	
	sheetParam = { width=107, height=127, numFrames=4, sheetContentWidth=107, sheetContentHeight=509} 
	sequenceData = {name = "normalRun", start=1, count=4, time=200,loopCount = 3}
	teleSheet = graphics.newImageSheet(SELECTED_SKIN_PACK.."PlayerStandingTele.png",SKIN_BASE_DIR, sheetParam )
	player.animations[3] = display.newSprite( teleSheet, sequenceData)
	player.animations[3].isVisible = false
	player.animations[3]:addEventListener("sprite",SwitchAnimBack)
	player.animations[3].name = "player"
	
	sheetParam = { width=107, height=127, numFrames=4, sheetContentWidth=107, sheetContentHeight=509} 
	sequenceData = {name = "normalRun", start=1, count=4, time=200,loopCount = 3}
	teleSheet = graphics.newImageSheet(SELECTED_SKIN_PACK.."PlayerFlyAnimation.png",SKIN_BASE_DIR, sheetParam  )
	player.animations[4] = display.newSprite( teleSheet, sequenceData)
	player.animations[4].isVisible = false
	player.animations[4]:addEventListener("sprite",SwitchAnimBack)
	player.animations[4].name = "player"
	
	sheetParam = { width=107, height=127, numFrames=4, sheetContentWidth=107, sheetContentHeight=509} 
	sequenceData = {name = "normalRun", start=1, count=4, time=200,loopDirection = "bounce",loopCount = 1}
	teleSheet = graphics.newImageSheet(SELECTED_SKIN_PACK.."PlayerStandingAnimation.png",SKIN_BASE_DIR,sheetParam )
	player.animations[5] = display.newSprite( teleSheet, sequenceData )
	player.animations[5].isVisible = false
	player.animations[5].name = "player"
	player.animations[5]:addEventListener("sprite",SwitchAnimBack)
	
	for i=1,#player.animations do
		group:insert(player.animations[i])
	end
	 
	player.period = 120
	player.randomize = 120
	player.jumpTo = 1
	Runtime:addEventListener("enterFrame",animate)
		
	DECORATOR.toBack()
	background.alpha = BKG_ALPHA
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	MENU_ANIMATION_RUNNING = true
	siz = display.contentWidth * 0.3;
	player.rotation = 0
	player.width = siz 
	player.height = siz
	player.x = display.contentWidth/2
	player.y = decorAstero.y-(decorAstero.height+player.height)/2*0.9
	player.isVisible = false
	SwitchAnimation(5)
	CurrentLevel = ""
	PlayLabel.isVisible = true
	DesLabel.isVisible = true
	jumpFlag = 0
	-- INSERT code here (e.g. start timers, load audio, start listeners, etc.)
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	Runtime:removeEventListener("enterFrame",animate)
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
	if levelDesignerBtn then
		levelDesignerBtn:removeSelf()	-- widgets must be manually removed
		levelDesignerBtn = nil
	end
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