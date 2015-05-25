-- requires 
local storyboard = require ("storyboard")
local scene = storyboard.newScene()
local function goBack()
	print("RESETTING GAME!")
	--storyboard.removeScene("reset")
	storyboard.gotoScene("engine","fade",100)
end
-- background
function scene:createScene(event)
end
function scene:enterScene(event)
	timer.performWithDelay(500,goBack,1)
end
function scene:exitScene(event)
end
function scene:destroyScene(event)
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













