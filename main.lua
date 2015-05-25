-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )
display.setDefault( "background", 255, 255, 255 )
-- AppIng loading screen
-- local dim = display.contentWidth/2
-- local base  = display.newImageRect("base.png",dim*1.34,dim*1.34*0.7);
-- local rotor = display.newImageRect("rotor.png",dim,dim);
-- rotor.x = display.contentWidth/2*0.88
-- rotor.y = display.contentHeight/2
-- base.x  = rotor.x*1.17
-- base.y = rotor.y
-- rotate the logo
-- include the Corona "storyboard" module
local storyboard = require "storyboard"
ScoreRecorder = require "scoreStore"
ScoreRecorder.init()
-- global controller variables
fdspd = 180
GoToWhatScene = "menu"
GameEndReason = ""
CurrentLevel = ""
CurrentLevelType = "" -- storyline / custom / network 
LEVEL_LIST = ""
BEFORE_ENGINE_SCENE = "chapterBrowser"
-- chapterBrowser controllers
CURRENT_CHAPTER = 1
-- engine controllers
ENG_RLD = nil
RUNTIME_LISTENER_ON = false
NO_RETRY = false
NO_NEXT  = false
-- sound controller
AJnoMusic = false
AJnoFxSnd = false
-- game skin selector
print("Setting SKIN to correct pack")
-- default setting
SELECTED_SKIN_PACK = ""
SKIN_BASE_DIR = system.ResourceDirectory
-- test skin
--SELECTED_SKIN_PACK = "skins/omnom/"
--SKIN_BASE_DIR = system.DocumentsDirectory
-- end
local waitTillMenu = 100; --put back to 100 for one second delay
local function RotateAndLoad( event )
    rotor:rotate(5)
	waitTillMenu = waitTillMenu - 1
	if waitTillMenu == 0 then
		-- load menu screen
		timer.cancel( event.source )
		rotor:removeSelf()
		rotor = nil
		base:removeSelf()
		base = nil
		storyboard.gotoScene( "menu" )
	end
end
--timer.performWithDelay( 10, RotateAndLoad , 0)
storyboard.gotoScene( "menu" )