--chapter shower
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local showLoad = require("loadScreen")
--local EFFECTS = require("ParticleFXhandler")
--local decor = require("DecorateBKG")
-- include Corona's "widget" library
local group
local widget = require "widget"
display.setDefault( "background", 0, 0, 0)
------------------------------------------------
local levelData = {}
local keys = {}
local CamSpeed = 10
local IconDim = 0
local Spacing = 0
local backBtn
local background
local nr = 1
local TARGET = 1
local SLIDE_TRESHOLD = 5
local TOTAL_STARS = 0
local starIcon = nil
local totalStarsText = nil 
local planetD = nil
local Rradius = 0
local Lradius = 0
local yOrigin = 0
local zoomInCoef = 1.005
local nrSteps = 0
-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------
local function backToMenu()
	storyboard.gotoScene("menu","fade",fdspd)
end

local selected = nil
local function moveSelected()
	if selected ~= nil then
		if levelData[selected]["image"].y < display.contentHeight/2 then
			local dy = (display.contentHeight/2 - levelData[selected]["image"].y) / CamSpeed
			local dx = (display.contentWidth/2 - levelData[selected]["image"].x) / CamSpeed
			if dy < 1 then
				dy = 1
			end
			moveCam(dx,dy)
			zoomObjs(zoomInCoef)
			nrSteps = nrSteps + 1
		else
			LEVEL_LIST = levelData[selected]["levels"]
			storyboard.gotoScene("showLevels","fade",fdspd)
		end
	end
end

local function ShowLevels(event)
	if selected == nil then
		print("Selecting...")
		selected = event.target.name
		for i=1,#keys do 
			print(keys[i],"=",selected,keys[i] == selected)
			if keys[i] == selected then
				CURRENT_CHAPTER = i
				print("CC:",i)
				break;
			end
		end
		for k,v in pairs(levelData) do
			levelData[k]["image"]:removeEventListener("tap", ShowLevels)
		end
	end
end

local function LoadChapters(LevelName,group)
	--todo for each chapter check if level is perfect
	local path = system.pathForFile( LevelName, system.ResourceDirectory )
	local levelF,reason = io.open(path,"r")
	print("reading chapters:",LevelName)
	local nesting_level = 0
	local createNew = false
	local parents_list = {}
	for line in levelF:lines() do
		local c = line:sub(0,1)
		if c == '#' then
			print("#")
		else
			print("\n",line)
			if createNew then
				parents_list[nesting_level] = nr
				nesting_level = nesting_level + 1
				levelData[nr] = {} -- created a new record
				levelData[nr]["title"] = line
				nr = nr + 1
				createNew = false
			else
				local splitPos = line:find('=')
				if splitPos ~= nil then
					--print(line,line:sub(0,splitPos-1),line:sub(splitPos+1,line:len()))
					levelData[parents_list[nesting_level-1]][line:sub(0,splitPos-1)] = line:sub(splitPos+1,line:len()) 
				end
			end
			
			if c == '{' then -- got an object
				createNew = true
			end
			if c == '}' then
				nesting_level = nesting_level - 1
				table.remove(parents_list, nesting_level);
			end
		end
	end
	io.close(levelF)
	local dist = 1
	local stampSize = 0.3
	local nrl = 0
	
	for key,value in pairs(levelData) do
		if levelData[key]["imgname"] then
			nrl = nrl + 1
		end
	end
	
	for key,value in pairs(levelData) do
		print("level name:",key)
		print("levels:",levelData[key]["levels"])
		if levelData[key]["imgname"] then
			keys[#keys+1] = key
			
			levelData[key]["image"]        = display.newImage("rock1.png")--warning: if this is not kept as an explicit string it won't work on the device! don't know why... --levelData[key]["imgname"])
			levelData[key]["image"].x      = dist * ( Spacing + IconDim ) - IconDim/2 
			levelData[key]["image"].y      = Spacing + IconDim/2
			levelData[key]["image"].width  = IconDim
			levelData[key]["image"].height = IconDim
			levelData[key]["image"].name   = key
			Rradius = display.contentHeight - levelData[key]["image"].y
			
			levelData[key]["label"]   = display.newText( levelData[key]["title"], 0, 0, native.systemFont, display.contentWidth*0.1 )
			levelData[key]["label"].x = levelData[key]["image"].x
			levelData[key]["label"].y = levelData[key]["image"].y + IconDim/2 + levelData[key]["label"].height
			levelData[key]["label"]:setTextColor( 255, 255, 255)
			--levelData[key]["label"].isVisible = false
			Lradius = display.contentHeight - levelData[key]["label"].y
			
			dist = dist + 1
			group:insert(levelData[key]["image"])
			group:insert(levelData[key]["label"])
			
			levelData[key]["image"].stamp = display.newImageRect("perfectchapter.png",IconDim*stampSize,IconDim*stampSize)
			levelData[key]["image"].stamp.x = levelData[key]["image"].x
			levelData[key]["image"].stamp.y = levelData[key]["image"].y + levelData[key]["image"].height*0.4
			levelData[key]["image"].stamp.isVisible = false
			group:insert(levelData[key]["image"].stamp)
		end
	end
	--Rradius = Rradius + nrl*levelData[fk]["image"].height
	--Lradius = Lradius + nrl*levelData[fk]["image"].height
	yOrigin = display.contentHeight --+ nrl*levelData[fk]["image"].height
end
local function MoveLvl(key,dx)
	if selected then
		return
	end
	local d 
	if key then
		levelData[key]["label"].isVisible = true
		
		d = ( display.contentWidth/2 - levelData[key]["image"].x )
		d = d / 10
	else
		d = dx
	end
	for k,value in pairs(levelData) do
		--if key and k ~= key then
		--	levelData[k]["label"].isVisible = false
		--end
		levelData[k]["image"].x = levelData[k]["image"].x + d
		levelData[k]["label"].x = levelData[k]["label"].x + d
		local angle = math.atan2( levelData[k]["image"].y - yOrigin,levelData[k]["image"].x-display.contentWidth/2)

	end
end

local AllowMove = false
local lx = 0
local Middler = 1

local function moveLevels(event)
	print (event.phase)
	if event.phase == "began" then
		lx = event.x
		AllowMove = true
		if TARGET ~= nil then
			Middler = TARGET
		end
		TARGET = nil
		--if Middler == nil then
		--	Middler = 1
		--end
	end
	if event.phase == "moved" then
		if AllowMove then
			local dx = event.x - lx
			lx = event.x
			MoveLvl(nil,dx)
			if dx > SLIDE_TRESHOLD then
				TARGET = Middler - 1
				if TARGET < 1 then
					TARGET = 1
				end
				AllowMove = false
			elseif dx < -SLIDE_TRESHOLD then
				TARGET = Middler + 1
				if TARGET > #keys then
					TARGET = #keys
				end
				AllowMove = false
			end
		end
	end
	if event.phase == "ended" then
		AllowMove = false
		if TARGET == nil then
			TARGET = Middler
		end
		--if TARGET == nil then
		--	TARGET = 1
		--end
	end
end
local function FRAME(event)
	for key,value in pairs(levelData) do
		if levelData[key]["imgname"] then
			levelData[key]["image"].stamp.x = levelData[key]["image"].x
		end
	end
	
	if TARGET then
		MoveLvl(TARGET,0)
	end
	if selected then
		moveSelected()
	else
		if levelData[keys[CURRENT_CHAPTER]]["image"].y > (Spacing + IconDim/2) then
			print(levelData[keys[CURRENT_CHAPTER]]["image"].y,(Spacing + IconDim/2))
			local ddy = ((Spacing + IconDim/2) - levelData[keys[CURRENT_CHAPTER]]["image"].y)/CamSpeed
			local ddx = (display.contentWidth/2 - levelData[keys[CURRENT_CHAPTER]]["image"].x)/(CamSpeed*2)
			if math.abs(ddy) < 1 then
				ddy = -1
			end
			moveCam(0,ddy)
			if nrSteps > 0 then
				zoomObjs(1/zoomInCoef)
				nrSteps = nrSteps - 1
			end
		end
	end
end
-- Called when the scene's view does not exist:
local function setupScene()
	background = display.newRect( 0,0, display.contentWidth, display.contentHeight )
	background:setFillColor(0,0,0,255)
	background.x = display.contentWidth / 2
	background.y = display.contentHeight / 2
	background.alpha = BKG_ALPHA
	group:insert(background)
	
	IconDim = display.contentWidth*0.7
	Spacing = IconDim*0.15

	background:addEventListener( "touch" , moveLevels )
	backBtn = widget.newButton{
		defaultFile="backButton.png",
		overFile="backButtonOver.png",
		width = display.contentWidth*0.1, height= display.contentWidth*0.1,
		onRelease = backToMenu	-- event listener function
	}
	backBtn.x = backBtn.width/2
	backBtn.y = display.contentHeight - backBtn.width/2 
	
	LoadChapters("chapters.dsc",group)
	-- all display objects must be inserted into group
	totalStarsText = display.newText("Total:", 0, 0, native.systemFont, display.contentWidth*0.05 )
	totalStarsText.anchorX = 0.5
	totalStarsText.anchorY = 0.5
	totalStarsText.y = totalStarsText.height/2
	totalStarsText.x = display.contentWidth*0.05
	
	starIcon = display.newImageRect("staticstar.png",totalStarsText.height*1.1,totalStarsText.height*1.1)
	starIcon.y = totalStarsText.y  
	starIcon.isVisible = false
	
	planetD = display.newImageRect("planet1.png",display.contentWidth,display.contentWidth)
	planetD.x = display.contentWidth/2
	planetD.y = display.contentHeight+planetD.height/4
	planetD.width = planetD.width*1.1
	planetD.height = planetD.height*1.1
	if planetD.y - planetD.height/2 < display.contentHeight/2 then
		planetD.y = planetD.y + 1.1*(display.contentHeight/2 - (planetD.y - planetD.height/2))
	end
	-- todo add sun glare animation
	
	group:insert(totalStarsText)
	group:insert(starIcon)
	group:insert(planetD)
	group:insert(backBtn)

end
function scene:createScene( event )
	group = self.view
	showLoad.init()
	showLoad.trigger(display.contentWidth/2,display.contentHeight/2)
	setupScene()
end
function checkPerfectLevels()
	TOTAL_STARS = 0
	for key,value in pairs(levelData) do
		local isPerfect = true
		if levelData[key]["imgname"] then
			--check if the chapter is perfect
			print("chapter levels:",levelData[key]["levels"])
			local splitted = levelData[key]["levels"]:gmatch("[%w]+")
			for levelName in splitted do
				print("Attepmting score read:",levelName)--,system.pathForFile( "", system.ResourceDirectory).."/"..levelName)
				--[[local scoredata = ScoreRecorder.get_score(system.pathForFile( "", system.ResourceDirectory).."/"..levelName)
				if scoredata ~= nil then
					if scoredata["stars"] ~= nil then
						TOTAL_STARS = TOTAL_STARS + scoredata["stars"]
						print("Stars:", scoredata["stars"] )
						if scoredata["stars"]< 3 then
							isPerfect = false
						end
					else
						isPerfect = false
					end
				else
					isPerfect = false
				end--]]
			end
			-- show perfect if necessary
			if isPerfect then
				levelData[key]["image"].stamp.isVisible = true
			else
				levelData[key]["image"].stamp.isVisible = false
			end
		end
	end
	totalStarsText.text = "Total: "..TOTAL_STARS 
	starIcon.x = starIcon.width + totalStarsText.x + totalStarsText.width
	starIcon.isVisible = true
end
-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	BEFORE_ENGINE_SCENE = "chapterBrowser"
	MENU_ANIMATION_RUNNING = false
	-- INSERT code here (e.g. start timers, load audio, start listeners, etc.)	
	showLoad.clear()
	selected = nil
	if CURRENT_CHAPTER > #keys then
		CURRENT_CHAPTER = #keys
	end
	print("eCC:",CURRENT_CHAPTER)
	for k,v in pairs(levelData) do
		levelData[k]["image"]:addEventListener("tap", ShowLevels)
	end
	Runtime:addEventListener("enterFrame",FRAME)
	checkPerfectLevels()
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
	--decor.clean()
	Runtime:removeEventListener("enterFrame",FRAME)
	selected = nil
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	
	background:removeEventListener("touch",moveLevels)
	background:removeSelf()
	background = nil
	for key,value in pairs(levelData) do
		levelData[key]["image"].stamp:removeSelf()
		levelData[key]["image"].stamp = nil
		levelData[key]["image"]:removeEventListener("tap", ShowLevels)
		levelData[key]["image"]:removeSelf()
		levelData[key]["image"] = nil
		
		levelData[key]["label"]:removeSelf()
		levelData[key]["label"] = nil
	end
	if backBtn then
		backBtn:removeSelf()	-- widgets must be manually removed
		backBtn = nil
	end
end

function moveCam(dx,dy)
	for key,v in pairs(levelData) do
		levelData[key]["image"].x = levelData[key]["image"].x + dx
		levelData[key]["image"].y = levelData[key]["image"].y + dy
		levelData[key]["label"].x = levelData[key]["label"].x + dx
		levelData[key]["label"].y = levelData[key]["label"].y + dy
		if levelData[key]["image"].stamp then
			levelData[key]["image"].stamp.x = levelData[key]["image"].stamp.x + dx
			levelData[key]["image"].stamp.y = levelData[key]["image"].stamp.y + dy
		end
	end
	--planetD.x = planetD.x + dx
	planetD.y = planetD.y + dy
end
function zoomObjs(coef)
	local distX
	local distY
	local angle
	local radius
	for key,v in pairs(levelData) do
		distX = levelData[key]["image"].x - background.x
		distY = levelData[key]["image"].y - background.y
		angle = math.atan2(distY,distX)
		radius = math.sqrt(distX^2+distY^2)
		radius = (radius * coef)
		levelData[key]["image"].x = background.x + radius*math.cos(angle)
		levelData[key]["image"].y = background.y + radius*math.sin(angle)
		levelData[key]["image"].width = levelData[key]["image"].width * coef
		levelData[key]["image"].height = levelData[key]["image"].height * coef
		
		distX = levelData[key]["label"].x - background.x
		distY = levelData[key]["label"].y - background.y
		angle = math.atan2(distY,distX)
		radius = math.sqrt(distX^2+distY^2)
		radius = (radius * coef)
		levelData[key]["label"].x = background.x + radius*math.cos(angle)
		levelData[key]["label"].y = background.y + radius*math.sin(angle)
		--levelData[key]["label"].width = levelData[key]["label"].width * coef
		--levelData[key]["label"].height = levelData[key]["label"].height * coef
		
		if levelData[key]["image"].stamp then
			distX = levelData[key]["image"].stamp.x - background.x
			distY = levelData[key]["image"].stamp.y - background.y
			angle = math.atan2(distY,distX)
			radius = math.sqrt(distX^2+distY^2)
			radius = (radius * coef)
			levelData[key]["image"].stamp.x = background.x + radius*math.cos(angle)
			levelData[key]["image"].stamp.y = background.y + radius*math.sin(angle)
			levelData[key]["image"].stamp.width = levelData[key]["image"].stamp.width * coef
			levelData[key]["image"].stamp.height = levelData[key]["image"].stamp.height * coef
		end
	end
	
	distX = planetD.x - background.x
	distY = planetD.y - background.y
	angle = math.atan2(distY,distX)
	radius = math.sqrt(distX^2+distY^2)
	radius = (radius * coef)
	--planetD.x = background.x + radius*math.cos(angle)
	planetD.y = background.y + radius*math.sin(angle)
	planetD.width = planetD.width * coef
	planetD.height = planetD.height * coef
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