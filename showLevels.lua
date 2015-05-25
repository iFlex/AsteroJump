--chapter shower
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local showLoad = require("loadScreen")
--local decor = require("DecorateBKG")
-- include Corona's "widget" library
local widget = require "widget"
--local showLoad = require("loadScreen")
display.setDefault( "background", 0, 0, 0)
------------------------------------------------
local levelData = {}
local CellDim = 0
local IconDim = 0
local nrLevelsPerRow = 5
local backBtn
local nr = 0
local group = nil
local GoTo = "menu"
local DBGlabel 

local function backToMenu()
	GoTo = "chapterBrowser"
	storyboard.removeScene( "showLevels" )
end

local function goToLevel()
	GoTo = "engine"
	storyboard.removeScene( "showLevels" )
end
local function ProceedToLevel(event)
	if event.phase == "ended" then
		-- read all contents of file into a string
		CurrentLevelType = "story"
		CurrentLevel = {event.target.name,".lvl"}
		CurrentLevel = table.concat(CurrentLevel)
		print("\nCreated file:",CurrentLevel)
		goToLevel()
	end
end
local function LoadLevels()
	local nesting_level = 0
	local createNew = false
	local parents_list = {}
	local startY = (display.contentHeight - CellDim*5)/2
	
	DBGlabel.text = DBGlabel.text.."\nParsing line"
	
	for token in LEVEL_LIST.gmatch(LEVEL_LIST, "[%w]+") do
		DBGlabel.text = DBGlabel.text.."\nToken:"..token
		print("level:",token)
		levelData[nr] = {}
		levelData[nr]["image"] = display.newImageRect("level.png",IconDim,IconDim )
		levelData[nr]["image"].icons = {}
		DBGlabel.text = DBGlabel.text.."\nLoaded image"

		levelData[nr]["image"].x = math.floor(nr%nrLevelsPerRow) * CellDim + CellDim/2
		levelData[nr]["image"].y = startY+math.floor(nr/nrLevelsPerRow) * CellDim + CellDim/2
		levelData[nr]["image"].name = token
		DBGlabel.text = DBGlabel.text.." pos"
	
		levelData[nr]["label"] = display.newText( tostring(nr+1), 0, 0, native.systemFont, display.contentWidth*0.09 )
		levelData[nr]["label"].x = levelData[nr]["image"].x
		levelData[nr]["label"].y = levelData[nr]["image"].y
		levelData[nr]["label"]:setTextColor( 0, 0, 0)
		DBGlabel.text = DBGlabel.text.." lbld"
	
		group:insert(levelData[nr]["image"])
		group:insert(levelData[nr]["label"])
		DBGlabel.text = DBGlabel.text.." grp"
	
		local nrStars = 0 -- -1 level locked 0 no stars 1 - 3 nr of stars to display 
		local starCoef = 0.15
		local radius = IconDim*0.5
		local angleSpacing = 15
		local startAngle   = 0
		-- read score data from file and get number of stars for this level
		-- print("Attepmting score read:",system.pathForFile( "", system.ResourceDirectory).."/"..token)
		DBGlabel.text = DBGlabel.text.."\nObtaining ResourceDir..."
		local tpth = system.pathForFile( "", system.ResourceDirectory)
		DBGlabel.text = DBGlabel.text.."\nReading score status:"
		--[[local scoredata = ScoreRecorder.get_score(tpth.."/"..token)
		DBGlabel.text = DBGlabel.text.." DONE:"..type(scoredata)
		if scoredata ~= nil then
			if type(scoredata) == "table" and scoredata["stars"] ~= nil then
				nrStars = scoredata["stars"]
			end
		end]]--
		-- if level is locked set it to -1
		if nrStars > -1 then
			for i =1,nrStars do
				levelData[nr]["image"].icons[i] = display.newImageRect("staticstar.png",IconDim*starCoef,IconDim*starCoef)
				levelData[nr]["image"].icons[i].x = levelData[nr]["image"].x + radius*math.cos(math.rad(startAngle + (i-1)*angleSpacing))
				levelData[nr]["image"].icons[i].y = levelData[nr]["image"].y + radius*math.sin(math.rad(startAngle + (i-1)*angleSpacing))
				group:insert(levelData[nr]["image"].icons[i])
			end
			levelData[nr]["image"]:addEventListener("touch", ProceedToLevel)	
		else
			levelData[nr]["image"].icons[1] = display.newImageRect("lock.png",IconDim*starCoef,IconDim*starCoef)
			levelData[nr]["image"].icons[1].x = levelData[nr]["image"].x + radius*math.cos(math.rad(startAngle + angleSpacing))
			levelData[nr]["image"].icons[1].y = levelData[nr]["image"].y + radius*math.sin(math.rad(startAngle + angleSpacing))
		end
		nr = nr+1
	end
end

local function MoveLvl(d)
	for key,value in pairs(levelData) do
		levelData[key]["image"].x = levelData[key]["image"].x + d
		levelData[key]["label"].x = levelData[key]["label"].x + d
	end
end

local function setupScene()
	--decor.initDecorator(group,{selfTick="true",noNebula="true"})
	CellDim = (display.contentWidth/nrLevelsPerRow)
	IconDim = CellDim*0.95
	backBtn = widget.newButton{
		defaultFile="backButton.png",
		overFile="backButtonOver.png",
		width = display.contentWidth*0.1, height= display.contentWidth*0.1,
		onRelease = backToMenu	-- event listener function
	}
	DBGlabel.text = DBGlabel.text.."\nCreate Button"
	
	backBtn.x = backBtn.width/2
	backBtn.y = display.contentHeight - backBtn.width/2 
	group:insert(backBtn)
	DBGlabel.text = DBGlabel.text.."\nLoading levels..."
	LoadLevels("ToShow")
	-- all display objects must be inserted into group
end

function scene:createScene( event )
	group = self.view
	showLoad.init()
	showLoad.trigger(display.contentWidth/2,display.contentHeight/2)
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	DBGlabel = display.newText("Debug begins:",0,0,display.contentWidth,display.contentHeight,native.systemFont, 32)
	DBGlabel:setTextColor(255,0,0)
	group:insert(DBGlabel)
	setupScene()
	BEFORE_ENGINE_SCENE = "showLevels"
	showLoad.clear()
	-- INSERT code here (e.g. start timers, load audio, start listeners, etc.)
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	for key,value in pairs(levelData) do
		for i = 1,#levelData[key]["image"].icons do
			levelData[key]["image"].icons[i]:removeSelf()
			levelData[key]["image"].icons[i] = nil
		end
		--levelData[key]["image"]:removeEventListener("tap", ShowLevels)
		levelData[key]["image"]:removeSelf()
		levelData[key]["image"] = nil
		
		levelData[key]["label"]:removeSelf()
		levelData[key]["label"] = nil
	end
	if backBtn then
		backBtn:removeSelf()	-- widgets must be manually removed
		backBtn = nil
	end
	levelData = nil;
	
	--decor.clean();
	storyboard.gotoScene(GoTo,"fade",fdspd)
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