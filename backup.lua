-----------------------------------------------------------------------------------------
--
-- level designer
--
-----------------------------------------------------------------------------------------
-- le essential storyboard
local storyboard = require "storyboard" 
local widget = require"widget"
local scene = storyboard.newScene()
local levelData = {}
-- include Corona's "physics" library
-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------
-- Called when the scene's view does not exist:
local levelName = "level0.lvl"
local lastx = 0
local lasty = 0

local stg
local saveBtn
local deleteBtn
local ast
local enemy
local backBtn

local AstIndex = 0
local EnemyIndex = 0
local AllowMoveCamera = false
local AllowMoveAsteroid = false
local AllowGeneralMove = true
local stageH	=	display.contentHeight*0.15
local function GoBack()
	print("Going back to menu")
	storyboard.gotoScene("menu")
	return true
end
local function deleteSelection()
	return true
end
local function SaveLevel(event)
	local path = system.pathForFile( levelName, system.TemporaryDirectory )
	local fh, reason = io.open( path, "w" )
	if fh then
		for key2,value2 in pairs(levelData) do
			fh:write("{\n")
			fh:write(key2)
			fh:write("\n")
			for key,value in pairs(value2) do
				print("key:",key,"val:",value)
				if key == "image" then
					fh:write("x=")
					fh:write(value.x)
					fh:write("\n")
				
					fh:write("y=")
					fh:write(value.y)
					fh:write("\n")
				
					fh:write("width=")
					fh:write(value.width)
					fh:write("\n")
				
					fh:write("height=")
					fh:write(value.height)
					fh:write("\n")
				
					fh:write("rotation=")
					fh:write(value.rotation)
					fh:write("\n")
				else
					fh:write(key)
					fh:write("=")
					fh:write(value)
					fh:write("\n")
				end
			end
			fh:write("}\n")
		end
	else
		print( "Reason open failed: " .. reason )  -- display failure message in terminal
	end
	io.close( fh )
	print("DONE SAVING at:",path)
end
local function moveNewAst(e)
	if (e.phase == "began") then
		AllowGeneralMove = false
	elseif (e.phase == "moved") then
		--e.target.x = e.x
		e.target.y = e.y
		if(e.target.y >= stageH*1.5) then
			if e.target.name == "ast" then
				DoAdd = "ast"
			else
				DoAdd = "enemy"
			end
			AllowGeneralMove = true
		end
	else
		if(e.target.y > stageH) then
			if e.target.name == "ast" then
				DoAdd = "ast"
			else
				DoAdd = "enemy"
			end
		else
			e.target.y = stageH/2
		end
		AllowGeneralMove = true
	end
	return false -- unfortunately, this will not propogate down if false is returned
end
local function AddAsteroidToPedestal()
	stg:toFront()
	deleteBtn:toFront()
	saveBtn:toFront()
	if enemy then
		enemy:toFront()
	end
	ast = display.newImageRect("rock1.png" , stageH, stageH )
	ast.x = display.contentWidth/2-stageH/2
	ast.y = stageH/2
	ast.name = "ast"
	ast:addEventListener("touch",moveNewAst)
end

local function AddEnemyToPedestal()
	stg:toFront()
	deleteBtn:toFront()
	saveBtn:toFront()
	if ast then
		ast:toFront()
	end
	--backBtn:toFront()
	
	enemy = display.newImageRect( "enemy1.png" , stageH, stageH )
	enemy.x = display.contentWidth/2+stageH/2
	enemy.y = stageH/2
	enemy.name = "enemy"
	enemy:addEventListener("touch",moveNewAst)
end
local function moveCamera(ddx,ddy)
	for key,value in pairs(levelData) do
		levelData[key]["image"].x = levelData[key]["image"].x + ddx
		levelData[key]["image"].y = levelData[key]["image"].y + ddy
	end
end

local function multitouch(e)
	if (e.phase == "began") then
			lastx = e.x
			lasty = e.y
			AllowMoveCamera = true
			AllowMoveAsteroid = true
			print("touch began!","is bkg",e.target == background)
        elseif (e.phase == "moved") then
			if e.target == background and AllowMoveCamera and AllowGeneralMove then
				print("moving camera...")
				moveCamera( e.x - lastx , e.y - lasty )
			else
				print(AllowMoveAsteroid)
				if AllowMoveAsteroid and AllowGeneralMove then
					print("moving asteroid...")
					e.target.x = e.x
					e.target.y = e.y
				end
			end
			lastx = e.x
			lasty = e.y
        else
			print ("touch ended")
			AllowMoveCamera = false
			AllowMoveAsteroid = false
			--if e.target ~= background
		end
		return false -- unfortunately, this will not propogate down if false is returned
end
local function AddAsteroid(asteroid)
	key = {"ast",tostring(AstIndex)}
	key = table.concat(key)
	AstIndex = AstIndex + 1
	print("adding key:",key)
	levelData[key] = {}
	levelData[key]["gravity"]  = 0
	levelData[key]["angleforce"] = 20
	levelData[key]["density"]  = 50.0
	levelData[key]["friction"] = 1.0
	levelData[key]["bounce"]   = 1.0
	levelData[key]["acidness"]   = 0
	levelData[key]["explosiveness"]   = 0
	asteroid:removeEventListener("touch",moveNewAst)
	levelData[key]["image"] = asteroid
	levelData[key]["radius"] = asteroid.width/2 
	levelData[key]["imgname"] = "rock1.png"
	levelData[key]["image"]:addEventListener("touch",multitouch)
	asteroid = nil
	AddAsteroidToPedestal()
end

local function AddEnemy(asteroid)
	key = {"enemy",tostring(EnemyIndex)}
	key = table.concat(key)
	EnemyIndex = EnemyIndex + 1
	print("adding key:",key)
	levelData[key] = {}
	levelData[key]["gravity"]  = 0
	levelData[key]["angleforce"] = 0
	levelData[key]["GoForce"] = 3
	levelData[key]["range"] = 3
	levelData[key]["actionType"] = "ever-charging"
	levelData[key]["density"]  = 0.2
	levelData[key]["friction"] = 0.2
	levelData[key]["bounce"]   = 0.15
	levelData[key]["acidness"]   = 0
	levelData[key]["explosiveness"]   = 0
	asteroid:removeEventListener("touch",moveNewAst)
	levelData[key]["image"] = asteroid
	levelData[key]["radius"] = asteroid.width/2 
	levelData[key]["imgname"] = "enemy1.png"
	levelData[key]["image"]:addEventListener("touch",multitouch)
	asteroid = nil
	AddEnemyToPedestal()
end
local function FRAME(event)
	if DoAdd == "ast" then
		DoAdd = nil
		AddAsteroid(ast)
	end
	if DoAdd == "enemy" then
		DoAdd = nil
		AddEnemy(enemy)
	end
end
function scene:createScene( event )
	local group = self.view
	local key = "player"
	levelData[key] = {}
	levelData[key]["imgname"] = "player.png"
	levelData[key]["width"] = 100
	levelData[key]["height"] = 100
	levelData[key]["radius"] = 50
	levelData[key]["gravity"]  = 0
	levelData[key]["angleforce"] = 0
	levelData[key]["density"]  = 0.1
	levelData[key]["friction"] = 1.0
	levelData[key]["bounce"]   = 1.0
	levelData[key]["acidness"]   = 0
	levelData[key]["explosiveness"]   = 0
	levelData[key]["x"] = display.contentWidth/2
	levelData[key]["y"] = display.contentHeight/2
	levelData[key]["rotation"] = 0
	levelData[key]["image"] = display.newImageRect( levelData[key]["imgname"], tonumber(levelData[key]["width"]), tonumber(levelData[key]["height"]) )
	levelData[key]["image"].x = tonumber(levelData[key]["x"])
	levelData[key]["image"].y = tonumber(levelData[key]["y"])
	levelData[key]["image"].rotation = tonumber(levelData[key]["rotation"])	
	levelData[key]["startObj"] = "ast0"
	levelData[key]["image"]:addEventListener("touch",multitouch)
	group:insert(levelData[key]["image"])
	
	key = "exit"
	levelData[key] = {}
	levelData[key]["imgname"] = "exit.png"
	levelData[key]["width"] = 100
	levelData[key]["height"] = 100
	levelData[key]["radius"] = 50
	levelData[key]["gravity"]  = 3
	levelData[key]["angleforce"] = 0
	levelData[key]["density"]  = 1000.0
	levelData[key]["friction"] = 0.0
	levelData[key]["bounce"]   = 1.0
	levelData[key]["bodyType"] = "static"
	levelData[key]["acidness"]   = 0
	levelData[key]["explosiveness"] = 0
	levelData[key]["x"] = display.contentWidth/2
	levelData[key]["y"] = levelData["player"]["image"].y - levelData["player"]["image"].height 
	levelData[key]["rotation"] = 0
	levelData[key]["image"] = display.newImageRect( levelData[key]["imgname"], tonumber(levelData[key]["width"]), tonumber(levelData[key]["height"]) )
	levelData[key]["image"].x = tonumber(levelData[key]["x"])
	levelData[key]["image"].y = tonumber(levelData[key]["y"])
	levelData[key]["image"].rotation = tonumber(levelData[key]["rotation"])	
	levelData[key]["startObj"] = "ast0"
	levelData[key]["image"]:addEventListener("touch",multitouch)
	group:insert(levelData[key]["image"])
	
	stg = display.newRect( 0 , 0 , display.contentWidth, stageH)
	stg:setFillColor(140, 140, 140)
	
	deleteBtn = widget.newButton{
		defaultFile="delete.png",
		overFile="deleteOver.png",
		width=stageH, height=stageH,
		onRelease = deleteSelection	-- event listener function
	} 
	
	deleteBtn.x = display.contentWidth-stageH/2
	deleteBtn.y = stageH/2
	
	saveBtn = widget.newButton{
		defaultFile="save.png",
		overFile="saveOver.png",
		width=stageH, height=stageH,
		onRelease = SaveLevel	-- event listener function
	} 
	saveBtn.x = stageH/2
	saveBtn.y = stageH/2
	
	--AddAsteroidToPedestal()
	--AddEnemyToPedestal()
	backBtn = widget.newButton{
		defaultFile="backButton.png",
		overFile="backButtonOver.png",
		width=stageH/2, height=stageH/2,
		onRelease = GoBack	-- event listener function
	} 
	backBtn.x = backBtn.width/2
	backBtn.y = display.contentHeight - backBtn.width/2
	
	local group = self.view
	group:insert(stg)
	group:insert(saveBtn)
	--group:insert(ast)
	--group:insert(enemy)
	group:insert(deleteBtn)
	group:insert(backBtn)
	group:insert(levelData["player"]["image"])
	group:insert(levelData["exit"]["image"])
	Runtime:addEventListener("enterFrame",FRAME)
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	background:addEventListener( "touch", multitouch )
end

-- Called when scene is about to move offscreen:
local function DestroyObject(obj)
	if obj then
		obj:removeSelf()
		obj = nil
	end
end
function scene:exitScene( event )
	local group = self.view
	Runtime:removeEventListener("enterFrame",FRAME)
	DestroyObject(stg)
	DestroyObject(saveBtn)
	DestroyObject(deleteBtn)
	DestroyObject(ast)
	DestroyObject(enemy)
	DestroyObject(backBtn)
	for key,value in pairs(levelData) do
		if( levelData[key]["field"]) then
			DestroyObject(levelData[key]["field"])
		end
		DestroyObject(levelData[key]["image"])
		levelData[key]=nil
	end
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	print("scene destroyed")
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
return scene