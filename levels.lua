-----------------------------------------------------------------------------------------
--
-- levels.lua
--
-----------------------------------------------------------------------------------------
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
-- include Corona's "widget" library
local widget = require "widget"
--------------------------------------------
-- forward declarations and other locals
local group
local selectedFile
local currentPath
local cPathText
local upText
local playBtn
local EditBtn
local levelsTable = {}
local backBtn
local cFolderLen = {1}
local DEBUG = nil
local UTmask
local BKmask
-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------
local function backToMenu()
	storyboard.removeScene("levels")
	storyboard.gotoScene("menu","fade",fdspd)
end
local lfs = require "lfs"
local function onPlayBtnPress()
	local path = system.pathForFile( "", system.DocumentsDirectory )
	CurrentLevel =  path..currentPath..selectedFile
	CurrentLevelType = "custom"
	NO_NEXT = true
	storyboard.gotoScene("engine","fade",500)
end
local function onEditBtnPress()
	local path = system.pathForFile( "", system.DocumentsDirectory )
	CurrentLevel = path..currentPath..selectedFile
	--this function will load the leveldesigner
	storyboard.removeScene("levels")
	storyboard.gotoScene("levelDesignerNew","fade",500)
end
local function scrollListener( event )
	playBtn.isVisible = false
    editBtn.isVisible = false
    
	local phase = event.phase
    local direction = event.direction
    if "began" == phase then
        print( "Began" )
    elseif "moved" == phase then
 		print( "Moved" )
    elseif "ended" == phase then
        print( "Ended" )
    end
    -- If we have reached one of the scrollViews limits
    if event.limitReached then
        if "up" == direction then
            print( "Reached Top Limit" )
        elseif "down" == direction then
            print( "Reached Bottom Limit" )
        elseif "left" == direction then
            print( "Reached Left Limit" )
        elseif "right" == direction then
            print( "Reached Right Limit")
        end
    end
    return true
end
-- Create a ScrollView
local scrollView = widget.newScrollView
{
    top = 0,
    left = 0,
    width = display.contentWidth,
    height = display.contentHeight,
    scrollWidth = 10,
    scrollHeight = 10,
	friction = 1000,
	horizontalScrollDisabled = true,
	hideBackground = true,
    listener = scrollListener,
}
local function UnloadAll()
	cPathText:removeSelf()
	upText:removeSelf()
	for i=1,#levelsTable do
		levelsTable[i]:removeSelf()
		levelsTable[i].Tmask:removeSelf()
		levelsTable[i].icon:removeSelf()
	end
	for i=1,#levelsTable do
		table.remove(levelsTable)
	end
	UTmask:removeSelf()
	BKmask:removeSelf()
	
	playBtn:removeSelf()
	editBtn:removeSelf()
	backBtn:removeSelf()
end
local function LoadFiles(path)
	local hcoef = 0.1
	local UTcoef = 0.06
	local tileAlpha = 0.75
	local tdistCoef = 0.12
	local mdistCoef = 0.1
	local fontSize = display.contentWidth/20
	cPathText = display.newText(currentPath, 0, 0, native.systemFont, fontSize*0.8)
	cPathText.x = display.contentWidth/2
	upText = display.newText("...", 20, 50, native.systemFont, fontSize)
	upText.anchorX = 0.5
	upText.anchorY = 0.5
	upText.x = display.contentHeight*mdistCoef
	
	BKmask = display.newRect(display.contentWidth*mdistCoef,0 ,display.contentWidth,display.contentWidth*hcoef)
	BKmask.y = display.contentHeight*UTcoef + BKmask.height/2 
	upText.y = BKmask.y
	BKmask:setFillColor(88,88,88)
	BKmask.alpha = tileAlpha
	BKmask:addEventListener( "touch", touchUp )
	
	scrollView:insert( BKmask )
	scrollView:insert( upText )
	
	backBtn = widget.newButton{
		defaultFile="backButton.png",
		overFile="backButtonOver.png",
		width = display.contentWidth*0.1, height= display.contentWidth*0.1,
		onRelease = backToMenu	-- event listener function
	}
	backBtn.x = backBtn.width/2
	backBtn.y = display.contentHeight - backBtn.width/2 
--	group:insert( upText )
	local a = 1
	local fileOrLevel
	print("Loading:",path)
	--DEBUG.text = "Loading:"..path
	for file in lfs.dir(path) do
		--file is the current file or directory name
		print( "Found file: " .. file )
		if file ~= "." and file ~= ".." then
			levelsTable[a] = display.newText(string.gsub( file, ".lvl", ""), 20, 0, system.nativeFont, fontSize)
			levelsTable[a].anchorX = 0.5
			levelsTable[a].anchorY = 0.5
			
			levelsTable[a].Tmask = display.newRect(display.contentWidth*mdistCoef,0,display.contentWidth,display.contentWidth*hcoef)
			levelsTable[a].Tmask.anchorX = 0.5
			levelsTable[a].Tmask.anchorY = 0.5
			
			levelsTable[a].Tmask.x = display.contentWidth*mdistCoef
			levelsTable[a].Tmask.y = BKmask.y+a*display.contentWidth*hcoef+levelsTable[a].Tmask.height/2
			levelsTable[a].Tmask.alpha = tileAlpha
			levelsTable[a].Tmask.file = file

			levelsTable[a].x = display.contentWidth*tdistCoef
			levelsTable[a].y = levelsTable[a].Tmask.y
			
			if string.find( file, ".lvl" ) then 
				levelsTable[a].icon = display.newImageRect("file.png",display.contentWidth*hcoef,display.contentWidth*hcoef)
				levelsTable[a].Tmask:addEventListener( "touch", touchL )
			else 
				levelsTable[a].icon = display.newImageRect("folder.png",display.contentWidth*hcoef,display.contentWidth*hcoef) 
				levelsTable[a].Tmask:addEventListener( "touch", touchF )
			end
			levelsTable[a].icon.x = levelsTable[a].icon.width/2
			levelsTable[a].icon.y = levelsTable[a].y
			
			if( a%2 == 1)then
				levelsTable[a].Tmask:setFillColor(255,107,79)
			else
				levelsTable[a].Tmask:setFillColor(0,204,255)
			end
			scrollView:insert( levelsTable[a].Tmask )
			scrollView:insert( levelsTable[a].icon )
			scrollView:insert( levelsTable[a] )
			a = a + 1
		end
	end
	playBtn = widget.newButton{
		defaultFile="playButton.png",
		overFile="playButtonOver.png",
		width = display.contentWidth*hcoef, height = display.contentWidth*hcoef,
		onRelease = onPlayBtnPress	-- event listener function
	}
	editBtn = widget.newButton{
		defaultFile="editButton.png",
		overFile="editButtonOver.png",
		width = display.contentWidth*hcoef, height = display.contentWidth*hcoef,
		onRelease = onEditBtnPress	-- event listener function
	}
	scrollView:insert(playBtn)
	scrollView:insert(editBtn)
	group:insert( scrollView )
	
	playBtn.isVisible = false
	editBtn.isVisible = false
	
	cPathText.y = display.contentHeight*UTcoef/2
	UTmask = display.newRect(0,0,display.contentWidth,display.contentHeight*UTcoef)
	UTmask:setFillColor(128,128,128)
	UTmask.alpha = tileAlpha
	
	group:insert( UTmask )
	group:insert( backBtn )
	group:insert( cPathText )
	
	scrollView:scrollTo("top",{time=0})
end
function touchL( event )
	if event.phase == "began" then
		playBtn.isVisible = true
		editBtn.isVisible = true
		print(event.target)
		playBtn.y = event.target.y
		playBtn.x = event.target.width - playBtn.width
		editBtn.y = event.target.y
		editBtn.x = event.target.width - editBtn.width*2
		selectedFile = event.target.file
	end
	return true
end
function touchF( event )
	playBtn.isVisible = false
	editBtn.isVisible = false
	if event.phase == "began" then
		local tmp = currentPath..event.target.file.."/"
		local PTMP = system.pathForFile("",system.DocumentsDirectory)
		--PTMP = PTMP:sub(1,PTMP:len()-1)..tmp
		PTMP = PTMP..tmp
		DEBUG.text = "Attempting:"..PTMP
		--if PTMP:len()>0 then
			currentPath = tmp
			cPathText.text = currentPath
			cFolderLen[1] = cFolderLen[1] + 1
			cFolderLen[cFolderLen[1]] = event.target.file:len() + 1
			-- go to newLevel scene
			print("Going to next directory:",PTMP)
			DEBUG.text = "Going to next directory:"..PTMP
			
			UnloadAll()
			LoadFiles(PTMP)
		--else
		--	print("Error changing directory")
		--end
	end
	return true
end
function touchUp( event )
	if cFolderLen[1] ~= 1 then 
		if event.phase == "began" then
			print( "currentPath: " .. currentPath )
			local tmp = currentPath:sub( 1, currentPath:len() - cFolderLen[cFolderLen[1]] )
			local PTMP = system.pathForFile("",system.DocumentsDirectory)..tmp
			--if PTMP:sub(#PTMP,#PTMP+1) == "/" then
			--	PTMP = PTMP:sub(1,#PTMP)
			--end
			print( "tmp: " .. PTMP )
			DEBUG.text = "attempting:"..PTMP
			--if system.pathForFile( "",system.pathForFile("",system.DocumentsDirectory)..tmp) then
				currentPath = tmp
				cPathText.text = currentPath
				cFolderLen[1] = cFolderLen[1] - 1
				--table.remove(cFolderLen)
				-- go to newLevel scene
				print("Going to previous directory")
				DEBUG.text = "Going to previous directory:"..PTMP
				UnloadAll()
				LoadFiles(PTMP)
			--else
				--print("Error changing directory")
			--end
		end
	end
	return true
end


-- Called when the scene's view does not exist
function scene:createScene( event )
	DEBUG = display.newText("Debug",0,0,display.contentWidth,display.contentHeight, native.systemFont, 32)
	DEBUG:setTextColor(255,0,0)
	DEBUG.x = display.contentWidth/2
	DEBUG.y = display.contentHeight/2
	
	--hide debug
	--DEBUG.isVisible = false
	print("creating scene...")
	group = self.view
	group:insert(DEBUG)
	currentPath = "/"
	-- display a background image
end
-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	MENU_ANIMATION_RUNNING = false
	BEFORE_ENGINE_SCENE = "levels"
	group = self.view
	DEBUG.text = system.pathForFile( "", system.DocumentsDirectory )
	
	LoadFiles(system.pathForFile( "", system.DocumentsDirectory )..currentPath)
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	group = self.view
	UnloadAll()
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
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