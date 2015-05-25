-----------------------------------------------------------------------------------------
-- ENGINE.lua
--
-- optimize table accessing
-- ALL ANIMATIONS OWNED BY OBJECTS THAT ARE NOT STORED WITH NO_REL PROPERTY ARE BEING UPDATED
-- TOGETHER WITH THEIR PARENTS, THIS MAY BECOME A PERFORMANCE ISSUE
--
-- if an object does not have density then it does not have a physics body
-- owned objects don't have physics bodies ( create complex ph-bodies using joints )
-- all animations must be managed with using the animation system
-- all joints must be managed using the joint system
-- all owned objects must be managed using the owned object system
-- all display objects must be managed using the objects system
-----------------------------------------------------------------------------------------
-- IMPORTS
-----------------------------------------------------------------------------------------
local storyboard = require( "storyboard" )
local widget = require "widget"
local fps = require("fpsmonitor") -- debug
local showLoad = require("loadScreen")
require "io"
require "math"
require "system"
system.activate( "multitouch" )
-----------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------
local scene = storyboard.newScene()
local group
local onScreenSensor = nil;
local levelData = nil;
local isOnScreen = {};
local instructions = nil;
local jointBuffer = nil;
local playerCache = nil
local playerImage = nil
local topLeftCache = nil
local bottomRightCache = nil
---------------------------------------------------------------------------------------------
-- PHYSICS ENGINE HANG/REINSTATE SYSTEM VARS
---------------------------------------------------------------------------------------------
local RemoveOnce = false
local reinstated = false 
local ZoomRecover = false 
-----------------------------------------------------------------------------------------
-- CAMERA SYSTEM VARS
-----------------------------------------------------------------------------------------
local minY = 3000000000
local maxY = -minY
local maxX = maxY
local minX = minY
local centerX = display.contentWidth/2;
local centerY = display.contentHeight/2;
local cameraReady = false
local ROTATION_AMPLIFYER = 2
local ZOOM_AMPLIFYER = 1
local MAX_TURN_AND_ZOOM = 5
local amZooming = false
local amRotating = false
local lastZoomAm = 0;
local zoomAm = 1
local NrTriggers = 0 -- debug
---------------------------------------------------------------------------------------------------
-- TOUCH HANDLING SYSTEM
---------------------------------------------------------------------------------------------------
local MAX_TAP_TOLERANCE = 5
local TapNotValid = 0
local zXanchor = 0
local zYanchor = 0
local tangle = 0
local lastTarget = nil
local firstDist = 0
local lastAngle = nil;
local angleDiff = 0
local AllowArrow = false;
local allowZoom = false;
local PushAway = false
-----------------------------------------------------------------------------------------
-- TAP MODE SWITCH SYSTEM
-----------------------------------------------------------------------------------------
local selector
local Activated = false
----------------------------------------------------------------------------------------
-- SCORE BAR SYSTEM -- analyse what hapens at reset
----------------------------------------------------------------------------------------
local stars = {}
local flame
local flameScore
local vacuum
local vacuumScore
local gold
local goldScore
local statusBar
--------------------------------------------------------------------------------------------------------
-- CHEMICAL INTERACTION SYSTEM
--------------------------------------------------------------------------------------------------------
local AsterosToResize = {}
local ATRindex = 0
--------------------------------------------------------------------------------------
-- INTERACTION SYSTEM
--------------------------------------------------------------------------------------
local FreeToAttach = false
--------------------------------------------------------------------------
-- PAUSE MENU SYSTEM
--------------------------------------------------------------------------
pauseMenu = display.newGroup()
--------------------------------------------------------------------------
-- GAME CREATE CLEAN SYSTEM
--------------------------------------------------------------------------
local EndAnimation = nil;
---------------------------------------------------------------------------------------------
-- MAIN TIMELINE SYSTEM VARS
---------------------------------------------------------------------------------------------
-- essential engine vars
print("Game engine starts...")
local TickCount = 0
local GameEnded = false
-- debug values
local nrObjects = 0
local nrJoints = 0
local nrOwnedObjects = 0
local nrAnimations = 0
---Player parementers
local FullImpulse = 0.3
local TelekinesisForce = 1000
local TelekinesisRange = 10.0
----------------------- 
local BlastNr = 0 -- for blast
local ROTATION_PACE = 10 -- the higher the slowe it will rotate
-----------------------------------------
local PLAYER_SIZE_COEFF = 0.2;
-----------------------------------------
local TapActionSelector = "jump" -- conjureExplosion or conjureImplosion
nrStars  = 0
nrFlames = 0
nrVacums = 0
nrGold = 0
local ActionTrinketCost = 3
local ActionMagnitude = 5.0
-----------------------------------------
local DebugLabel = nil -- debug
-- include Corona's "physics" library
local physics = require "physics"
-- setup the physics
physics.start()
physics.pause()
physics.setGravity(0,0)
--physics.setDrawMode("hybrid")
--------------------------------------------
-- forward declarations and other locals
local background = display.newImageRect("2px.png" , display.contentWidth*1.1, display.contentHeight*1.2)
background:setFillColor(0,0,0)
background.x = display.contentWidth  / 2
background.y = display.contentHeight / 2
background.alpha = BKG_ALPHA
-------------------------------------------------
local GameFrozen = true
local pauseBtn
local Capturer = nil
local GoTo = "menu"
-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------
--------------
-- Engine Coefs Init
--------------
function InitEngine()
	print("Initialising Game engine...")
	GameEndReason = nil
	
	TickCount = 0
	nrJoints = 0
	FullImpulse = 0.3
	TelekinesisForce = 1000
	TelekinesisRange = 10.0
	BlastNr = 0 -- for blast
	ROTATION_PACE = 10 -- the higher the slowe it will rotate
	PLAYER_SIZE_COEFF = 0.2;
	TapActionSelector = "jump" -- conjureExplosion or conjureImplosion
	nrStars  = 0
	nrFlames = 0
	nrVacums = 0
	nrGold = 0
	ActionTrinketCost = 3
	ActionMagnitude = 5.0
	GameFrozen = true
	Capturer = nil
	GoTo = "menu"
	RemoveOnce = false
	reinstated = false -- for phy halt/re
	ZoomRecover = false -- for the phy halt/re
	minY = 3000000000
	maxY = -minY
	maxX = maxY
	minX = minY
	cameraReady = false
	ROTATION_AMPLIFYER = 2
	ZOOM_AMPLIFYER = 1
	MAX_TURN_AND_ZOOM = 5
	amZooming = false
	amRotating = false
	lastZoomAm = 0;
	zoomAm = 1
	NrTriggers = 0 -- debug
	
	MAX_TAP_TOLERANCE = 5
	TapNotValid = 0	
	zXanchor = 0
	zYanchor = 0
	tangle = 0	
	lastTarget = nil
	firstDist = 0
	lastAngle = nil;
	angleDiff = 0
	AllowArrow = false;
	allowZoom = false;
	PushAway = false

	Activated = false
	
	AsterosToResize = {}
	ATRindex = 0
	
	FreeToAttach = false
	
	EndAnimation = nil;
	GameEnded = false
end
-----------------------------------------------------------------------------------------
-- GENERAL SYSTEMS
-----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- PHYSICS ENGINE HANG/REINSTATE SYSTEM ( Solely because Corona can't scale physics bodies)
---------------------------------------------------------------------------------------------
function ClearForZoom()
	physics.pause()
end
function RecoverAfterZoom()
	ZoomRecover = false
	physics.start()
end

function AddPhToBody(obj)
	if obj["density"] == nil then --this object is purely decorative
		print("No ph added to:",obj["image"].name)
		return true
	end
	--print("reinstating body:",tonumber(obj["density"]),tonumber(obj["friction"]),tonumber(obj["bounce"]),tonumber(obj["image"].width/2))
	if obj["image"].name:find("Trinket") then
		physics.addBody( obj["image"], "dynamic" ,{ isSensor = true, radius = tonumber(obj["image"].width/2) } )
	else
		if(obj["image"].name:find("player"))then
			physics.addBody( obj["image"], obj["bodyType"] ,{ density = tonumber(obj["density"]), friction = tonumber(obj["friction"]), bounce = tonumber(obj["bounce"]), radius = tonumber(obj["image"].width*0.45) } )
		else
			physics.addBody( obj["image"], obj["bodyType"] ,{ density = tonumber(obj["density"]), friction = tonumber(obj["friction"]), bounce = tonumber(obj["bounce"]), radius = tonumber(obj["image"].width/2) } )
		end
	end
end
function removePhBodies( key )
	print("removing ph bodies")
	if levelData[key]["owns"] and levelData[key]["owns"]["field"] then
		physics.removeBody(levelData[key]["owns"]["field"]["image"])
	end
	physics.removeBody(levelData[key]["image"])
end
function mendPositions( key )
	for key,obj in pairs(levelData) do
		obj["image"].x=obj["mend_x"];
		obj["image"].y=obj["mend_y"];
		--local k = display.newLine(obj["image"].x,obj["image"].y-obj["image"].height/2,obj["image"].x,obj["image"].y+obj["image"].height/2)
		--local l = display.newLine(obj["image"].x-obj["image"].width/2,obj["image"].y,obj["image"].x+obj["image"].width/2,obj["image"].y)
	end
end
function reinstatePhBody( key ) -- this causes the objects to move
	ldk = levelData[key]
	if ldk["image"].isVisible == true then
		print("reinstating for key:",key)
		ldk["mend_x"]=ldk["image"].x;
		ldk["mend_y"]=ldk["image"].y;
		if ldk["density"] then -- having density means having a ph body
			AddPhToBody(ldk)
			if ldk["xvel"] then
				ldk["image"]:setLinearVelocity(ldk["xvel"],ldk["yvel"])
				ldk["image"].angularVelocity = ldk["angleVel"];
				ldk["xvel"] = nil
				ldk["yvel"] = nil
			end
		end
	end
	-- reinstate player joint
	if key:find("player") and playerCache["detached"] == false then 
		AttachPlayer(playerCache["jcoinWith"],false)
	end
	if ldk["image"].isVisible == true then
		-- if the object has a field then reinstate it
		if ldk["owns"] and ldk["owns"]["field"] then
			physics.addBody( ldk["owns"]["field"]["image"], "static", { isSensor = true, radius = ldk["field"].width/2 } )
		end
		-- all joints must be reinstated
		if ldk["joints"] then
			for k,v in pairs(ldk["joints"]) do
				if ldk["joints"][k] then
					createJoint(k,ldk["joints"][k]["type"],key,ldk["joints"][k]["child"],ldk["joints"][k]["args"])
					updateJoint(key,i,false)
				end
			end
		end
	end
	--ZoomRecover = true
	--timer.performWithDelay(10,mendPositions,1);
end

function reinstatePhBodies( ) -- this causes the objects to move
	
	reinstated = true;
	for key,obj in pairs(levelData) do
		if obj["image"].isVisible == true then
			print("reinstating for key:",key)
			obj["mend_x"]=obj["image"].x;
			obj["mend_y"]=obj["image"].y;
			if obj["density"] then -- having density means having a ph body			
				AddPhToBody(obj)
				if obj["xvel"] then
					obj["image"]:setLinearVelocity(obj["xvel"],obj["yvel"])
					obj["image"].angularVelocity = obj["angleVel"];
					obj["xvel"] = nil
					obj["yvel"] = nil
				end
			end
		end
	end
	
	-- reinstate player joint
	if playerCache["detached"] == false and playerCache["joinWith"] then
		 AttachPlayer(playerCache["joinWith"],false)
	end
	
	for key,value in pairs(levelData) do
		if value["image"].isVisible == true then
			-- if the object has a field then reinstate it
			if owns(key,"field") then
				physics.addBody( value["owns"]["field"]["image"], "static", { isSensor = true, radius = value["owns"]["field"]["image"].width/2 } )
			end
			-- all joints must be reinstated
			if value["joints"] then
				for k,v in pairs(value["joints"]) do
					if value["joints"][k] then
						createJoint(k,value["joints"][k]["type"],key,value["joints"][k]["child"],value["joints"][k]["args"])
						updateJoint(key,i,true)
					end
				end
			end
		end
	end
	ZoomRecover = true
	timer.performWithDelay(10,mendPositions,1);
end
-----------------------------------------------------------------------------------------
-- CAMERA SYSTEM
-----------------------------------------------------------------------------------------

function initCamera()
	minY = 3000000000
	maxY = -minY
	maxX = maxY
	minX = minY
	cameraReady = false
	amZooming = false
	amRotating = false
end
function playerOffScreen()
	if playerImage then
		if playerImage.x > (display.contentWidth+playerImage.width) or playerImage.x < -playerImage.width then
			return true
		elseif playerImage.y > (display.contentHeight+playerImage.height) or playerImage.y < -playerImage.height then
			return true
		end
	end
	return false
end
function moveCamera(ddx,ddy,auto_moved)
	-- ddx         how much to move on oX
	-- ddy         how much to move on oY
	-- auto_moved  true if moved by enterFrame, false if moved by User
	--			   if moved by user the camera must not be allowed to exceed level boundaries
	-- update camera position in relation to level boundaries
	if ( centerX - ddx > bottomRightCache.x or centerX - ddx < topLeftCache.x or centerY - ddy > bottomRightCache.y or centerY - ddy < topLeftCache.y ) then
		--print("Camerax,CameraY",CameraX,CameraY)
		if auto_moved and playerOffScreen() then
			GameEndReason = "Stranded in space!"
		end
		return
	end
	
	-- move the actual objects
	for key,value in pairs(levelData) do
		if( value["image"] and value["image"].isVisible == true and value["image"].x ) then
			value["image"].x = value["image"].x + ddx
			value["image"].y = value["image"].y + ddy
		end
		updateObject(key)
	end
end

function rotateCamera(da)
	print("Rotating by:",math.deg(da))
	local cx = display.contentWidth/2;
	local cy = display.contentHeight/2;
	for key,value in pairs(levelData) do
		if( value["image"] and value["image"].isVisible == true and value["image"].x ) then
			local dx=value["image"].x-cx
			local dy=value["image"].y-cy;
			radius = math.sqrt((dx)^2+(dy)^2)
			local iangle = math.atan2(dy,dx)
			local cangle = iangle+da
			value["image"].x = cx + radius*math.cos(cangle)
			value["image"].y = cy + radius*math.sin(cangle)
			value["image"].rotation = value["image"].rotation + math.deg(da)
			if value["image"].getLinearVelocity then -- do the physics changes only if the object has physical props
				local vx=0
				local vy=0;
				if amZooming then
					vx = value["xvel"]
					vy = value["yvel"]
				else
					vx,vy = value["image"]:getLinearVelocity() 
					value["image"]:setLinearVelocity(0,0,value["image"].x,value["image"].y)
				end
				if ( vx ~= 0 or vy ~= 0 ) and vx and vy then
					cangle = math.atan2(vy,vx)
					cangle = cangle + da
					radius = math.sqrt(vx^2+vy^2)
					vx = radius*math.cos(cangle)
					vy = radius*math.sin(cangle)
					--if amZooming then
					value["xvel"] = vx 
					value["yvel"] = vy
					--else
					--	value["image"]:setLinearVelocity(vx,vy,value["image"].x,value["image"].y) 
					--end
				end
			end
		end
	end
end

function zoomObject(ox,oy,coef,key,reinstate )
	local distX = 0.0
	local distY = 0.0
	local angle = 0.0
	local radius = 0.0
	local oldW = 0;
	local removed = false
	--general obj zoom
	local obj = levelData[key]
	oldW = obj["image"].width
	obj["image"].width  = obj["image"].width * coef
	obj["image"].height = obj["image"].height * coef 
	
	if obj["radius"] then
		obj["radius"] = obj["radius"] * coef 
	end
	if obj["density"] then
		print("zoom id:",key)
		obj["density"] = obj["density"] * (1/coef)
		if obj["xvel"] == nil then
			local vx,vy = obj["image"]:getLinearVelocity()
			obj["xvel"] = vx
			obj["yvel"] = vy
			obj["angleVel"] = obj["image"].angularVelocity;
		end
		if obj["xvel"] then
			obj["xvel"] = obj["xvel"] * coef 
			obj["yvel"] = obj["yvel"] * coef
		end
		-- remove all physics
		if RemoveOnce then
			removePhBodies( key )
			removed = true
		end
	end	
	-- re position according to distance from center and how much zoom
	distX = obj["image"].x - ox
	distY = obj["image"].y - oy
	angle = math.atan2(distY,distX)
	radius = math.sqrt(distX^2+distY^2)
	radius = (radius * obj["image"].width) / oldW 
	obj["image"].x = ox + radius*math.cos(angle) 
	obj["image"].y = oy + radius*math.sin(angle)
	
	-- add physics back
	if reinstate then
		if removed == false and obj["density"] then -- only remove ph body and reinstate if the object has ph body
			removePhBodies( key )
			removed = true
		end
		if removed == true then
			reinstatePhBody(key);
		end
	end
end

function zoomCamera( coef )
	print("Attempting zoom:",coef)
	if( playerCache and coef ~= 0) then
	print("ZOOM: player is present")
	if( playerImage.width*coef > display.contentWidth*0.01 and playerImage.width*coef < display.contentWidth/3) then 
	print("ZOOM: dimensions acceptable for zoom")
	NrTriggers = NrTriggers + 1
	reinstated = false
	amZooming = true
	
	local distX = 0.0
	local distY = 0.0
	local angle = 0.0
	local radius = 0.0
	
	if RemoveOnce then
		ClearForZoom()
	end
	
	TelekinesisForce = TelekinesisForce * coef
	FullImpulse = FullImpulse * coef
	-- zoom player hook
	if playerCache["detached"] == false then
		DetachPlayer()
	end

	local oldW = 0
	--resize all objects
	for key,value in pairs(levelData) do
		if value["image"].isVisible == true then
			zoomObject(background.x,background.y,coef,key,false);
		end
	end
	end
	end
	RemoveOnce = false
	print("DONE zooming!")
end

function RecalcBoundaries(key)
	-------------------------------------------
	--- calculate level boundaries
	-------------------------------------------
	local lkIMG = levelData[key]["image"]
	if key ~= "player" then
		if( lkIMG.x + lkIMG.width > maxX ) then
			maxX = ( lkIMG.x + lkIMG.width )*1.2
		end
		if( lkIMG.x - lkIMG.width < minX ) then
			minX = ( lkIMG.x - lkIMG.width )*1.2
		end
		if( lkIMG.y + lkIMG.height > maxY ) then
			maxY = ( lkIMG.y + lkIMG.height )*1.2
		end
		if( lkIMG.y - lkIMG.height < minY ) then
			minY = ( lkIMG.y - lkIMG.height )*1.2
		end	
	end
	--print("maxx minx maxy miny",maxX,minX,maxY,minY)
	-------------------------------------------
	--- done setting level boundaries
	-------------------------------------------	
end
-----------------------------------------------------------------------------------------------
-- TOUCH TRACKING SYSTEM
-----------------------------------------------------------------------------------------------
local touches = {}

function initTouchTrack()
	touches = {}
end

function getNrTouches()
	local nr = 0
	for key,value in pairs(touches) do
		nr = nr + 1
	end
	return nr
end

function RegisterTouch(event)
	if( getNrTouches()<2) then
		touches[event.id] = {}
		if( getNrTouches() == 1 ) then
			touches[event.id]["zoomRoot"] = true
		end
		touches[event.id].x = event.x
		touches[event.id].y = event.y
		return true
	end
	return false
end

function UpdateTouch(event)
	if(touches[event.id])then
		touches[event.id].x = event.x
		touches[event.id].y = event.y
		return true
	end
	return false
end

function UnRegisterTouch(event)
	if( touches[event.id] ) then
		touches[event.id] = nil
		return true
	end
	return false
end

function ClearAllTouches()
	for k,v in pairs(touches) do
		touches[k] = nil
	end
end

function getTouchAngle()
	local a1 = nil
	local a2 = nil
	local nrt = 0
	for key,value in pairs(touches) do
		nrt = nrt + 1
		if a1 ~= nil and a2 == nil then
			a2 = key
		end
		if a1 == nil then
			a1 = key
		end
	end
	if a1 ~= nil and a2 ~= nil then
		return math.atan2(touches[a1].y-touches[a2].y,touches[a1].x-touches[a2].x)
	end
	return nil
end

function getTouchDist()
	local dx = 0
	local dy = 0
	local nr = 2
	for key,value in pairs(touches) do
		if nr == 0 then
			dx = math.sqrt(dx^2+dy^2)
			break;
		end
		if nr == 2 then
			dx = value.x
			dy = value.y
		end
		if nr == 1 then
			dx = dx - value.x
			dy = dy - value.y
		end
		nr = nr - 1
	end
	return dx
end

---------------------------------------------------------------------------------------------
-- OBJECT MANAGEMENT SYSTEM
---------------------------------------------------------------------------------------------
function GetImgRoot(img)
	local pos = img:find(".png")
	local ret = ""
	local i = 1
	while i<pos do
		ret = ret..img:sub(i,i)
		i = i+1
	end
	return ret
end
function createObject(key,props)
	nrObjects = nrObjects + 1 -- debug
	--TODO delete next 2 lines after all systems reay
	if levelData[key] == nil then
		levelData[key] = {}
	end
	local ldk = levelData[key]
	for k,v in pairs(props) do
		ldk[k] = v
	end
	ldk["owns"] = {} -- all objects stored here will be updated according to a relationswhip with the parent object
	ldk["Nowns"] = {} -- all objects stored here must be updated automatically ( no iteration is performed over them by the systems )
	ldk["gravityControl"] = {}
	ldk["image"] = display.newImageRect(SELECTED_SKIN_PACK..ldk["imgname"],SKIN_BASE_DIR, tonumber(ldk["width"]), tonumber(ldk["height"]) )
	local ldkIMG = ldk["image"]
	ldkIMG.isVisible = true;
	ldkIMG.width  = ldk["width"]
	ldkIMG.height = ldk["height"]
	ldkIMG.name = key		
	ldkIMG.x = tonumber(ldk["x"])
	ldkIMG.y = tonumber(ldk["y"])
	ldkIMG.rotation = tonumber(ldk["rotation"])
	ldkIMG.root = true
	group:insert(ldkIMG)
				
	local bodyType = "dynamic"
	if ldk["bodyType"] == nil then
		ldk["bodyType"] = bodyType
	end
	
	if ldk["gravity"] and tonumber(ldk["gravity"]) > 1 then --and ldk["bodyType"] == "static" then
		ldk["repell"] = false
		if ldk["gravityForce"] and tonumber(ldk["gravityForce"]) < 0 then
			ldk["repell"] = true
		end
		local fld = display.newImageRect( "fld.png",ldk["gravity"] * ldkIMG.width,ldk["gravity"] * ldkIMG.width) 
		fld.x = ldkIMG.x
		fld.y = ldkIMG.y
		fld.name  = key
		physics.addBody( fld, "static", { isSensor = true, radius = fld.width/2 } )
		fld.collision = GravityCollision
		fld:addEventListener("collision",fld)
		addToOwned(key,fld,false,{key = "field",distance_rel = 0,rotation_rel = 0,width_rel = ldk["gravity"],height_rel = ldk["gravity"],wait = -1, ialpha = 0.3});
		group:insert(fld)	
	end
	
	if key:find("enemy") then
		--local loadedAnim = AttemptToLoadAnimations(key,SELECTED_SKIN_PACK..GetImgRoot(ldk["imgname"]))
		if ldk["actionType"] ~= "ever-charging" then
			local fld = display.newImageRect("fld.png",ldk["range"] * ldkIMG.width,ldk["range"] * ldkIMG.width)
			fld.x = ldkIMG.x
			fld.y = ldkIMG.y
			fld.name  = key
			addToOwned(key,fld,false,{key = "field",width_rel = ldk["range"],height_rel = ldk["range"],wait = -1, ialpha = 0.3});
			group:insert(fld)
		end
		if loadedAnim then
			ldkIMG.alpha = 0
			SwitchAnimation(key,"static")
		end
	end
	if key:find("player") then
		ldkIMG.alpha = 0
	end
	if key:find("exit") then
		ldk["absorb"] = true
	end
	AddPhToBody(ldk)
	if(ldk["torque"] ~= nil) then
		ldkIMG:applyTorque( tonumber(ldk["torque"]) )
	end
	if key:find("ast") or key:find("boo") then
		ldkIMG:addEventListener("touch",HandleAsteroTap)
	end
	ldk["visibility"] = ldkIMG.alpha
	
	if key:find("enemy") then
		--debug
		local hat = display.newImage("hat.png") -- debug
		local props = { key = "hat",distance_rel = 1.2 , rotation_rel = -90, width_rel = 0.8, height_rel = 0.8, angle_rel = 1 } -- debug
		addToOwned(key,hat,true,props) -- debug
		group:insert(hat)
		-- end debug
	end
	--testing
	--ldkIMG.angularDamping = 5
	--group:insert(levelData[key]["assets"])	
end

function wakeObject(key) -- max optimized
-- wake makes an object visible again ( to facilitate fast replay )
-- it uses a property that the owned objects have:
-- initialVisibility that tells this function how to set each owned object's visibility ( default will be true )
-- also the visibility property for the parent object tells this function how transparent is the parent object

-- all properties must be reset so that efects of the last game are not visible
	local ldk  = levelData[key]
	local limg = ldk["image"]
	--print("Waking object:",key,"x y w h",ldk["x"],ldk["y"],ldk["width"],ldk["height"])
	limg.x = ldk["x"]
	limg.y = ldk["y"]
	limg.width = ldk["width"]
	limg.height = ldk["height"]
	if ldk["density"] then
		if ldk["image"].isVisible == false or ldk["image"].setLinearVelocity == nil then
			AddPhToBody(ldk)
		end
		limg:setLinearVelocity(0,0)
		limg:applyTorque(0)
	end
	limg.isVisible = true
	
	if ldk["visibility"] then
		ldk.alpha = levelData[key]["visibility"]
	end
	
	if ldk["owns"] then
		for k,v in pairs(ldk["owns"]) do
			print("Owned:",v["key"],"initialVisibility",v["initialVisibility"])
			if v["initialVisibility"] ~= nil then
				v["image"].isVisible = v["initialVisibility"] 
			else
				v["image"].isVisible = true
			end
		end
	else
		ldk["owns"] = {}
	end
	-- GET RID OF ANNY LEFTOVER FLAGS FOR THE MAIN TIMELINE
	if ldk["toRemove"] ~= nil then
		ldk["toRemove"] = nil
	end
	if ldk["absorbBy"] ~= nil then
		ldk["absorbBy"] = nil
	end
	if ldk["underTelekinesis"] ~= nil then
		ldk["absorbBy"] = nil
	end
	if ldk["gravityControl"] ~= nil then
		for Gparent,val in pairs(ldk["gravityControl"]) do
			ldk["gravityControl"][Gparent] = nil
		end
	end
	-- RESET HEALTH TO INITIAL VALUE
end

function updateObject(key) -- max optimized
	-- this function makes sure that all the owned objects at the right position and right size
	-- in relation to the parent object
	-- these relations must be specified using
	-- height_rel how high in relation to the parent height is the object
	-- width_rel how wide in relation to the parent width is the object 
	-- distance_rel and rotation_rel a polar coordinate style positioning system for the object
	--     distance_rel what percentage of the parent's radius ( width/2 ) is the radius for the coords
	--     rotation_rel at what angle is the child in relation to the parent's reference point
	-- angle_rel what is the relation between the rotation of the parent and the rotation of the child ( in relation to it's own reference point )
	-- no_rel if you don't want the owned object to be iterated over for repositioning ( it will also be put in a different container => Nowned )
	--			all other objects are put in owned
	
	-- no_xy_rel if you don't want the x and y touched
	-- enter and exit modes are offered for elements that do not remain on the screen
	-- for now just fade is available
	-- a faderate and fadeto ( final alpha value ) must be provided
	
	-- all owned objects must have a wait property: if < 0 it stays on the screen forever, if > 0 it stays for wait calls of this function
	local owns = levelData[key]["owns"]
	local KIMG = levelData[key]["image"]
	if owns then
		for k,v in pairs(owns) do
			if v["image"] and v["image"].isVisible then
				--resize any owned objects
				VIMG = v["image"]
				if v["no_rel"] == nil then -- if no_rel is set the the properties remain untouched
					if v["direct_rel"] == true then -- fast bypass of relation evaluation
						VIMG.width = KIMG.width
						VIMG.height = KIMG.height
						VIMG.x = KIMG.x   
						VIMG.y = KIMG.y
						VIMG.rotation = KIMG.rotation
					else
						if v["width_rel"] then
							VIMG.width = KIMG.width * v["width_rel"]
						end
						if v["height_rel"] then
							VIMG.height = KIMG.height * v["height_rel"]
						end
						if v["distance_rel"] and v["rotation_rel"] then
							local radius = (KIMG.width/2)*v["distance_rel"]
							VIMG.x = KIMG.x + radius*math.cos(math.rad(KIMG.rotation + v["rotation_rel"]))  
							VIMG.y = KIMG.y + radius*math.sin(math.rad(KIMG.rotation + v["rotation_rel"]))
						else
							if v["no_xy_rel"] == nil then
								VIMG.x = KIMG.x   
								VIMG.y = KIMG.y
							end
						end
						if v["angle_rel"] then
							VIMG.rotation = KIMG.rotation * v["angle_rel"]
						end
					end
				end
				--enter mode
				if v["entermode"] == "fade" then
					if VIMG.alpha < v["fadeto"] then
						if VIMG.alpha + v["faderate"] < v["fadeto"] then
							VIMG.alpha = VIMG.alpha + v["faderate"]
							print("Lowering alpha")
						else
							VIMG.alpha = v["fadeto"]
						end
					end
					if VIMG.alpha == v["fadeto"] then
						v["entermode"] = nil
					end
				end
				--wait
				if v["wait"] > 0 and v["entermode"] == nil then
					v["wait"] = v["wait"] - 1
				end
				--exit mode
				if v["wait"] == 0 then
					if v["exitmode"] == "fade" then
						if VIMG.alpha > 0 then
							if VIMG.alpha - v["faderate"] > 0 then
								VIMG.alpha = VIMG.alpha - v["faderate"]
								print("Lowering alpha")
							else
								VIMG.alpha = 0
							end
							print("alpha:",VIMG.alpha,"higher:",(VIMG.alpha > 0))
						end
					else
						VIMG.alpha = 0
					end
				end
				-- removing unused owned objects from memory
				if v["wait"] == 0 and VIMG.alpha == 0 then
					owns[k]["image"].isVisible = false
					owns[k]["image"]:removeSelf()
					owns[k]["image"] = nil
					owns[k] = nil
				end
			end
		end
	end
end

function removeObject(key,complete) -- optimized
	--debug
	if complete then
		nrObjects = nrObjects - 1
	end
	--debug
	
	if levelData[key] == nil then
		return
	end
	local lk = levelData[key]
	--remove out joints
	print("deleting:",key)
	if lk["joints"] ~= nil then
		removeJoints(key)
	end
	--remove animations
	if lk["animations"] then
		removeAnimations(key,complete)
	end
	
	-- removing owned objects
	if lk["owns"] then
		for k,v in pairs(lk["owns"]) do
			if v["image"] and v["image"].isVisible == true then
				print("removed owned item from:",key)
				v["image"].isVisible = false
				if complete then
					v["image"]:removeSelf()
					v = nil
				end
			end
		end
	end
	-- removing the parent object
	lk["image"].isVisible = false
	removePhBodies(key)
	if complete then
		print("Deleting image:",key)
		lk["image"]:removeSelf()
		lk["image"] = nil
		levelData[key] = nil
	end
end
---------------------------------------------------------------------------------------------
-- OWNED OBJECTS SYSTEM
-- needs a hide object show object has object
---------------------------------------------------------------------------------------------
function owns(key,obj)
	if levelData[key] and levelData[key]["image"] and levelData[key]["image"].isVisible == true and levelData[key]["owns"] and levelData[key]["owns"][obj] then
		return true
	end
	return false
end
function addToOwned(key,obj,strict,args) -- optimized
	-- 'key' is the key for the name of the owned object ( obj )
	--  obj is the owned object
	--  strict = false allows the key to be the same with an already existing key ( it appends a . to the key to make it unique )
	--  args are the arguments describing the behaviour of the added object
	
	-- adding decorative images to game objects
	-- these images are owned by the game objects and therefore move and scale
	-- along with their owners
	--print("Add to owned call: ",key,args["key"],args["entermode"])
	local status = nil
	obj.isVisible = true
	if levelData[key]["owns"] == nil then -- if there is no owned objects list then create one
		levelData[key]["owns"] = {}
	end
	if levelData[key]["Nowns"] == nil then -- if there is no owned objects list then create one
		levelData[key]["Nowns"] = {}
	end
	
	local lko = nil
	if args["no_rel"] ~= nil then
		lko = levelData[key]["Nowns"]
	else
		lko = levelData[key]["owns"]	
	end
	
	if args["key"] == nil then
		args["key"] = "doe"
	end
	if args["ialpha"] then
		obj.alpha = args["ialpha"]
	end
	
	if args["entermode"] ~= nil and args["entermode"] == "fade" then
		if args["faderate"] == nil then 
			args["faderate"] = "0.01" 
		end
		if args["fadeto"] == nil then
			args["fadeto"] = obj.alpha
		end
		if args["wait"] == nil then
			args["wait"] = 1
		end
		--print("Have set",key,"to entermode: fade")
		obj.alpha = 0;
	end	
	
	if args["wait"] == nil then -- object that stays there 
		args["wait"] = -1
		args["entermode"] = "none"
		args["exitmode"]  = "none" 
	end
	
	if args["fillColor"] and args["fillColor"]["r"] and args["fillColor"]["g"] and args["fillColor"]["b"] then
		obj:setFillColor(args["fillColor"]["r"],args["fillColor"]["g"],args["fillColor"]["b"])
	end
	
	-- make sure key is unique and strict is respected
	if lko[args["key"]] then
		if strict == false then -- strict means only one owned element of a certain key can exist
			while lko[args["key"]] do -- append . to the key that is not unique to make it unique
				args["key"] = args["key"].."."
			end
		end
	end
	
	nrOwnedObjects = nrOwnedObjects + 1-- debug
	if args["initialVisibility"] ~= nil then
		obj.isVisible = args["initialVisibility"]
	end
	-- if an object with the same key exists then override it else create new vector
	if lko[args["key"]] ~= nil then
		status = "override"
		for k,v in pairs(lko[args["key"]]) do
			if k == "image" then
				lko[args["key"]][k]:removeSelf()
				nrOwnedObjects = nrOwnedObjects - 1
			end
			lko[args["key"]][k] = nil
		end
	else
		status = "new"
		lko[args["key"]] = {}
	end
	
	lko[args["key"]]["image"] = obj;
	for k,v in pairs(args) do
		--print("copying owned object properties:",k,v);
		lko[args["key"]][k] = v
	end	
	return status
end
function removeFromOwned(owner,object)
	if levelData[owner]["owns"] and levelData[owner]["owns"][object] and levelData[owner]["owns"][object]["image"] then
		nrOwnedObjects = nrOwnedObjects - 1 -- debug
		levelData[owner]["owns"][object]["image"]:removeSelf()
		levelData[owner]["owns"][object]["image"] = nil
		levelData[owner]["owns"][object] = nil
	end
end
---------------------------------------------------------------------------------------------
-- OWNED ANIMATIONS SYSTEM
-- needs heavy testing
---------------------------------------------------------------------------------------------
-- one of the custom listeners
SwitchAnimBack = function(e)
	if (e.phase == "ended") then
		print("SwitchAnimBack called for:",e.target.name)
		if e.target.name:find("player") then
			if hasJoint("player","sitJoint") then
				SwitchAnimation("player","player")
			else
				SwitchAnimation("player","PlayerFlyingTele")
			end
		else
			SwitchAnimation(e.target.name,levelData[e.target.name]["fallBackAnimation"])
		end
	end
end

function hasAnimation(key,animKey)
	if levelData[key] ~= nil and levelData[key]["animations"] ~= nil and levelData[key]["animations"][animKey] ~= nil then
		return true
	end
	return false
end

function showAnimation(key,animKey) -- adapt to access the right storage
	if hasAnimation(key,animKey) then
		print("***Showing animation:",animKey,key)
		local container = "owns"
		if levelData[key]["animations"][animKey].no_rel ~= nil then
			container = "Nowns"
		end
		
		local cache = levelData[key][container][animKey]["image"]
		if cache.isVisible == false then
			local listener = levelData[key][container][animKey]["listener"]
			if listener ~= nil then
				print("Attaching listener to animation",animKey,"owned by:",key)
				cache:addEventListener("sprite",listener)
			end
			cache:play()
			cache.isVisible = true
		end
	end
end

function hideAnimation(key,animKey)
	if hasAnimation(key,animKey) then
		local container = "owns"
		if levelData[key]["animations"][animKey].no_rel ~= nil then
			container = "Nowns"
		end
		
		local cache = levelData[key][container][animKey]["image"]
		local listener = levelData[key][container][animKey]["listener"]
		if listener ~= nil then
			cache:removeEventListener("sprite",listener)
		end
		cache:pause()
		cache.isVisible = false
	end
end

function pauseAnimation(key,animKey)
	if hasAnimation(key,animKey) then
		local container = "owns"
		if levelData[key]["animations"][animKey].no_rel ~= nil then
			container = "Nowns"
		end
		
		local cache = levelData[key][container][animKey]["image"]
		cache:pause()
	end
end

function pauseAnimations(key)
	Lcache = levelData[key]
	if not Lcache then
		return
	end
	if Lcache["animations"] then
		for akey,value in pairs(Lcache["animations"]) do
			pauseAnimation(key,akey)
		end		
	end
end

function pauseAllAnimations()
	for key,value in pairs(levelData) do
		pauseAnimations(key)
	end
end

function resumeAnimation(key,animKey)
	if hasAnimation(key,animKey) then
		local container = "owns"
		if levelData[key]["animations"][animKey].no_rel ~= nil then
			container = "Nowns"
		end
		
		local cache = levelData[key][container][animKey]["image"]
		if cache.isVisible == true then
			cache:play()
		end
	end
end

function resumeAnimations(key)
	Lcache = levelData[key]
	if not Lcache then
		return
	end
	if Lcache["animations"] then
		for akey,value in pairs(Lcache["animations"]) do
			resumeAnimation(key,akey)
		end		
	end
end

function resumeAllAnimations()
	print("RESTARTIG ALL ANIM")
	for key,value in pairs(levelData) do
		resumeAnimations(key)
	end
end

function SwitchAnimation(key,animKey)
	if animKey and ( hasAnimation(key,animKey) or animKey == "null" )then
		local anr_cache = levelData[key]["animation_running"]
		if( anr_cache ~= nil ) then
			hideAnimation(key,anr_cache)
		end
		if animKey ~= "null" then
			levelData[key]["fallBackAnimation"] = anr_cache
			anr_cache = animKey
			showAnimation(key,animKey)
		end
	end
end

function attachAnimation(key,animKey,animParams,finishListener)
	-- example anim param
	-- anim params content
	-- line 1: name of sprite sheet file. example telelink.png
	-- line 2: sprite sheet parameters { width=1024, height=64, numFrames=8, sheetContentWidth=1024, sheetContentHeight=512 }
	-- line 3: animation sequencing data {name = "normalRun", start=1, count=8, time=800}
	-- line 4: owned object properties {direct_rel}
	-- line 5: FSM data}
	-- levelData[key]["animations"] will hold the list of all animations associated with this object
	-- the animations are actually stored in owned objects just like any other decorative element
	-- the last parameter is a reference to a listener function for animations that end
	print("ATTACHING ANIMATION:",key,animKey)
	if levelData[key]["animations"] == nil then
		levelData[key]["animations"] = {}
	end
	local lka = levelData[key]["animations"]   
	if lka[animKey] == nil then
		local imgName = animParams[1]
		local sheetParam = animParams[2] 
		local sequenceData = animParams[3]
		local teleSheet = graphics.newImageSheet(SELECTED_SKIN_PACK..imgName,SKIN_BASE_DIR, sheetParam )
		if teleSheet == nil then
			return nil
		end
		animation = display.newSprite( teleSheet, sequenceData)
		animation.name = key
		animation.anim = animKey
		lka[animKey] = {};
		lka[animKey]["no_rel"] = animParams[4]["no_rel"]
		animParams[4]["key"] = animKey;
		if( animParams[5] and animParams[5]["listen"] == true and animParams[3]["loopCount"] ~= nil ) then
			animParams[4]["listener"] = finishListener	
		end
		local status = addToOwned(key,animation,true,animParams[4])
		if status ~= "override" then -- debug
			nrAnimations = nrAnimations + 1
		else
			print("#ANIMATION OVERRIDE!",key,animKey)
		end
		return animation;
	end
	return nil
end

function removeAnimation(key,animKey,clear)
	if hasAnimation(key,animKey) then
		hideAnimation(key,animKey)
		if clear then
			nrAnimations = nrAnimations - 1 -- debug
			levelData[key]["animations"][animKey] = nil;
			removeFromOwned(key,animKey)
		end
	end
end 

function removeAnimations(key,clear)
	if levelData[key] and levelData[key]["image"] and levelData[key]["animations"] ~= nil and levelData[key]["image"].isVisible == true then
		local cache = levelData[key]["animations"]
		for ani,v in pairs(cache) do
			print("Removing animation:",ani,"master:",key)
			removeAnimation(key,ani,clear)
		end
		levelData[key]["animation_running"] = nil
	end
end

function removeAllAnimations(clear)
	for key,value in pairs(levelData) do
		removeAnimations(key,clear)
	end
end

---------------------------------------------------------------------------------------------
-- JOINTS SYSTEM 
-- supports: pivot
--	     	 elsatic,
--           gravitational (gravitational joints don't have associated images) 
--           tele ( telekinetic link actually it's just a touch joint with an image associated
---------------------------------------------------------------------------------------------
function hasJoint(owner,joint)
	if levelData[owner] ~= nil and levelData[owner]["joints"] ~= nil and levelData[owner]["joints"][joint] ~= nil then
		return true
	end
	return false
end
function createJoint(name,tp,parent,child,args) -- optimized -- this can be used for reinstating as well
	-- use args to specify box2D properties for gravitational and tele links ( touch links )
	-- and use repell = true if you want to make a repellent field in stead of gravitational field
	-- use hasImage = true flag to specify that the joint already has an associated image loaded into the owned objects system
	-- 		if you set this flag then must specify loadedImage = the name of the owned object
	--											    imageWidth  is optional 
	--												imageHeight is optional
	-- use isAnimation = true flag if you want the createJoint function to start the animation 
	if levelData[parent] == nil or levelData[parent]["image"] == nil or levelData[parent]["image"].isVisible == false then
		return
	end
	if levelData[parent]["joints"] == nil then -- is parent does not have joint
		levelData[parent]["joints"] = {}
	end
	local cache = nil
	if hasJoint(parent,name) then
		cache = levelData[parent]["joints"][name]["joint"]
		if cache ~= nil and cache.removeSelf ~= nil then
			cache:removeSelf()
		end		
		levelData[parent]["joints"][name]["joint"] = nil
		cache = nil
	else
		levelData[parent]["joints"][name] = {};
		nrJoints = nrJoints + 1 -- debug
	end
	cache = levelData[parent]["joints"][name]
	cache["type"] = tp;
	cache["child"] = child;
	
	if args then
		local args_cahce
		cache["args"] = {}
		args_cache = cache["args"]
		for k,v in pairs(args) do
			args_cache[k] = v
		end
	end
	-- property telling the code that the joint already has an image associated
	-- can also be animation
	if args == nil or args["hasImage"] == nil then
		cache["hasImage"] = "default";
	else
		if args and args["hasImage"] then
			if args["hasImage"] == "noimage" then
				args["hasImage"] = nil
				cache["hasImage"] = nil
			else
				local obj = nil
				if args["loadedImage"] then -- if image or an animation is already loaded
					if levelData[parent]["owns"] ~= nil and levelData[parent]["owns"][args["loadedImage"]] ~= nil then
						obj = levelData[parent]["owns"][args["loadedImage"]]["image"]
					elseif levelData[parent]["Nowns"] and levelData[parent]["Nowns"][args["loadedImage"]] ~= nil then
						obj = levelData[parent]["Nowns"][args["loadedImage"]]["image"]
					end
				else  -- else it's an image and must be loaded
					obj = display.newImage(args["loadedImage"])
					if obj then
						if args["imageWidth"] then
							obj.width = args["imageWidth"]
						end
						if args["imageHeight"] then
							obj.height = args["imageHeight"]
						end
					end
				end
				cache["hasImage"] = obj
				cache["image"] = obj
				if obj then
					obj.isVisible = true
					if args["isAnimation"] == true then
						obj:play()
					end
				end
			end
		end
	end
	
	if     tp == "elastic" then
		cache["joint"] = physics.newJoint(tp,levelData[parent]["image"],levelData[child]["image"],levelData[parent]["image"].x,levelData[parent]["image"].y,levelData[child]["image"].x,levelData[child]["image"].y)
	elseif tp == "pivot" then
		cache["joint"] = physics.newJoint(tp,levelData[parent]["image"],levelData[child]["image"],levelData[parent]["image"].x,levelData[parent]["image"].y)
	elseif tp == "gravitational" then
		cache["hasImage"] = nil
		print("Creating gravitational joint")
		cache["joint"] = physics.newJoint( "touch", levelData[parent]["image"], levelData[parent]["image"].x, levelData[parent]["image"].y )
		local force = 1 
		cache["joint"].maxForce = force * levelData[child]["image"].width 
		cache["joint"].frequency = 0.3
		cache["joint"].dampingRatio = 0.0
	elseif tp == "tele" then
		print("Creating tele joint")
		local force = 1 
		cache["joint"] = physics.newJoint( "touch", levelData[parent]["image"], levelData[parent]["image"].x, levelData[parent]["image"].y )	
		--levelData[parent]["joints"][name]["joint"].maxForce = force * levelData[parent]["image"].width 
		cache["joint"].frequency = 0.3
		cache["joint"].dampingRatio = 0.0
		if(args) then
			if args["maxForce"] then
				cache["joint"].maxForce = args["maxForce"] * levelData[parent]["image"].width
			end
			if args["frequency"] then
				cache["joint"].frequency = args["frequency"]
			end
			if args["dampingRatio"] then
				cache["joint"].dampingRatio = args["dampingRatio"]
			end
		end
	end
end

function removeJoint(parent,name) -- max optimized
	if levelData[parent] and levelData[parent]["image"] and levelData[parent]["image"].isVisible == true then
		if hasJoint(parent,name) then
			-- deal with actual joint
			PJN_cache = levelData[parent]["joints"][name] 
			if PJN_cache["joint"] ~= nil then -- remove the joint itself
				if PJN_cache["joint"].removeSelf ~= nil then
					PJN_cache["joint"]:removeSelf()
				end
				PJN_cache["joint"] = nil
			end
			if PJN_cache["image"] ~= nil then -- remove the joint image
				if PJN_cache["hasImage"] and PJN_cache["hasImage"] ~= "default"  then
					if PJN_cache["args"] and PJN_cache["args"]["isAnimation"] == true then
						PJN_cache["image"]:pause()
					end
					PJN_cache["image"].isVisible = false
				else
					PJN_cache["image"]:removeSelf()
					PJN_cache["image"] = nil
				end
			end
			-- remove joint record
			nrJoints = nrJoints - 1 --debug
			levelData[parent]["joints"][name] = nil
			PJN_cache = nil
			print("REMOVED JOINT:",parent,name)
		end		
	end
end

function removeJoints(parent) -- max optimized
	if levelData[parent] and levelData[parent]["image"] and levelData[parent]["image"].isVisible and levelData[parent]["joints"] then
		local cache = levelData[parent]["joints"]
		for key,value in pairs(cache) do
			removeJoint(parent,key)
		end
	end
end

function removeAllJoints()
	for key,value in pairs(levelData) do
		removeJoints(key)
	end
end

function updateJoint(name,parent,isbusy) -- max optimized
	-- if engine is locked in zooming action the make sure not to perfom any operation on the actual
	-- joint because they do not exist
	if isbusy == nil then
		isbusy = false
	end
	if levelData[parent] == nil or levelData[parent]["image"] == nil or levelData[parent]["image"].isVisible == false or levelData[parent]["joints"] == nil or levelData[parent]["joints"][name] == nil then
		return
	end
	local PIMGcache = levelData[parent]["image"]
	local PJN_cache = levelData[parent]["joints"][name]
	local other = levelData[levelData[parent]["joints"][name]["child"]]
	if( other == nil or other["image"] == nil or other["image"].isVisible == false or PJN_cache["joint"] == nil ) then
		-- if the other end of the joint does not exist, delete joint
		removeJoint(parent,name)
		return
	end
	other = other["image"]
	-- handle joints that need constant updating
	if PJN_cache["type"] == "gravitational" or PJN_cache["type"] == "tele" then 
		if isbusy == false then
			-- this joint needs a taget to be set
			if( PJN_cache["args"] and PJN_cache["args"]["repell"] == true ) then
				local rx = other.x + (PIMGcache.x - other.x)*2
				local ry = other.y + (PIMGcache.y - other.y)*2
				PJN_cache["joint"]:setTarget(rx,ry)
			else
				PJN_cache["joint"]:setTarget(other.x,other.y)
			end
		end
	end
	-- handle joint images
	if PJN_cache["hasImage"] then
		local PJNI_cache = PJN_cache["image"]
		local dsx = other.x - PIMGcache.x 
		local dsy = other.y - PIMGcache.y
		local angle = math.atan2(dsy,dsx)
		local wii = math.sqrt(dsx^2+dsy^2)
		local wcoef = 0.25
		local hee = PIMGcache.height*wcoef
			
		if PJNI_cache == nil then
			PJN_cache["hasImage"] = "default"
			if other.width*wcoef < hee then
				hee = other.width*wcoef
			end
			print("creating joint image")
			PJN_cache["image"] = display.newImage("defaultLink.png")
			PJNI_cache = PJN_cache["image"]
			PJNI_cache.width = wii
			PJNI_cache.height = hee
			PJNI_cache.alpha = 0.3
			group:insert(PJNI_cache)
		end
		if wii == 0 then
			wii = 0.1
		end
		
		PJNI_cache.width = wii
		PJNI_cache.height = hee
		PJNI_cache.rotation = math.deg(angle)
		PJNI_cache.x = PIMGcache.x+dsx/2 
		PJNI_cache.y = PIMGcache.y+dsy/2
	end
end

function updateJoints(key,isbusy)  -- max optimized
	local cache = levelData[key]["joints"]
	if cache then
		for k,v in pairs(cache) do
			updateJoint(k,key,isbusy)
		end
	end
end
---------------------------------------------------------------------------------------------
-- LEVEL LOADER SYSTEM
---------------------------------------------------------------------------------------------
function LoadLevel(reload)
	print("ENG_RLD:",reload)
	if (reload == nil) then
		--level parsing
		local path = system.pathForFile( CurrentLevel, system.ResourceDirectory )
		if path == nil then
			path = CurrentLevel
		end
		local levelF,reason = io.open(path,"r")
		print("reading level:",CurrentLevel)
		local nesting_level = 0
		local createNew = false
		local parents_list = {}
		if levelF == nil then
			return
		end
		for line in levelF:lines() do
			line = line:gsub("^%s*(.-)%s*$", "%1")
			line = line:gsub(" ","")
			local c = line:sub(0,1)
			if c == '#' then
				print("#comment ignored")
			else
				if createNew then
					parents_list[nesting_level] = line
					nesting_level = nesting_level + 1
					levelData[line] = {} -- created a new record
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
	end
	-- actual loading
	print("Setting up objects...")
	levelData["player"]["attached"] = false
	for key,value in pairs(levelData) do
			print("Key:",key)
		if key:find("Trinket") then
			AddTrinket(key) -- create object and owned animation system when ready
		elseif value["imgname"] then
			if reload then
				wakeObject(key)
			else
				createObject(key,value)
			end
			RecalcBoundaries(key)
		end
		
		if reload == nil then  
			-- unpack the code
			if key:find("timedOperation") then
				print("codebit detected:")
				local nr = 1
				local code = {}
				local nextSep = 0 
				while value["code"]:len() > 0 do
					nextSep = value["code"]:find(';')
					code[nr] = value["code"]:sub(0,nextSep-1)
					value["code"] = value["code"]:sub(nextSep+1,value["code"]:len())
					print("insruction",nr,code[nr])
					nr = nr + 1
				end
				instructions[key] = {}
				instructions[key] = value
				instructions[key]["code"] = code
				levelData[key] = nil
				print("instr:",instructions[key]["code"][1])
			end
		end
	end
	--create joints
	local toiterate = nil
	if reload ~= nil then
		toiterate = jointBuffer
	else
		toiterate = levelData
	end
	
	for key,value in pairs(toiterate) do
		if key:find("joint") then
			if toiterate[key]["left"] and toiterate[key]["right"] and toiterate[key]["type"] then
				local left  = toiterate[key]["left"]
				local right = toiterate[key]["right"]
				createJoint(key,toiterate[key]["type"],left,right)
				updateJoint(key,left)
			end
			if reload == nil then
				jointBuffer[key] = value
				levelData[key] = nil
			end
		end
	end
	--attach the player to the starting obj and cache the player entry
	if reload == nil then
		playerCache = levelData["player"]
		playerImage = playerCache["image"]
	end
	playerImage:toFront()
	if playerCache["startObj"] then
		AttachPlayer(levelData[playerCache["startObj"]],true)
	end
	-- load 4 corners enclosing the level that will determine when the player has exited the level zone
	loadLevelBounds(reload)
end
function loadLevelBounds(reload)
	if reload == nil then
		createObject("topleft",{imgname="planet1.png",x=0,y=0,width=15,height=15})
		createObject("botleft",{imgname="planet1.png",x=0,y=0,width=15,height=15})
		createObject("botright",{imgname="planet1.png",x=0,y=0,width=15,height=15})
		createObject("topright",{imgname="planet1.png",x=0,y=0,width=15,height=15})
		-- cache for fast access
		topLeftCache = levelData["topleft"]["image"]
		bottomRightCache = levelData["botright"]["image"]
	end
	levelData["topleft"]["image"].x=minX
	levelData["topleft"]["image"].y=minY
	
	levelData["botleft"]["image"].x = minX
	levelData["botleft"]["image"].y = maxY
	
	levelData["botright"]["image"].x = maxX
	levelData["botright"]["image"].y = maxY
	
	levelData["topright"]["image"].x = maxX
	levelData["topright"]["image"].y = minY
end
-- specific function
function AttemptToLoadAnimations(key,root)
	local imgCache = levelData[key]["image"]
	local pa1 = attachAnimation(key,"action",{root.."action.png",
	{ width=imgCache.width, height=imgCache.height, numFrames=4, sheetContentWidth=imgCache.width, sheetContentHeight=imgCache.width*4 },
	{name = "normalRun", start=1, count=4, time=400},
	{initialVisibility = false,direct_rel = true},{}});
	
	if pa1 then
		group:insert(pa1)
	else
		print("Failed to load ACTION animation for ",key)
	end
	
	local pa2 = attachAnimation(key,"move",{root.."move.png",
	{ width=imgCache.width, height=imgCache.height, numFrames=4, sheetContentWidth=imgCache.width, sheetContentHeight=imgCache.width*4 },
	{name = "normalRun", start=1, count=4, time=400},
	{initialVisibility = false,direct_rel = true},{}});
	
	if pa2 then
		group:insert(pa2)
	else
		print("Failed to load MOVE animation for ",key)
	end
	
	local pa3 = attachAnimation(key,"static",{root.."static.png",
	{ width=imgCache.width, height=imgCache.height, numFrames=4, sheetContentWidth=imgCache.width, sheetContentHeight=imgCache.width*4 },
	{name = "normalRun", start=1, count=4, time=400},
	{initialVisibility = false,direct_rel = true},{}});
	
	if pa3 then
		group:insert(pa3)
	else
		print("Failed to load STATIC animation for ",key)
		return false
	end
		
	levelData[key]["fallBackAnimation"] = "static"
	print("Added Animations to",key)
	return true
end	
---------------------------------------------------------------------------------------------------
-- More specific systems
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- TOUCH HANDLING SYSTEM
---------------------------------------------------------------------------------------------------
function BeginTouch(e)
	RemoveOnce = true
	if RegisterTouch(e) and not amZooming then--register this unique tap
		amRotating = false
		if amZooming then --the previous zoom has not ended
			reinstatePhBodies()
		end
		if(getNrTouches()>1) then
			firstDist = getTouchDist()
			allowZoom = true
		end
		amZooming  = false
		zXanchor   = e.x
		zYanchor   = e.y
		TapNotValid = 0
		lastAngle = nil
		angleDiff = 0
	end
end
function MoveTouch(e)
	
	if UpdateTouch(e) then
		if (getNrTouches()>1) then
			if getNrTouches()==2 and allowZoom then
				zoomAm = zoomAm*((firstDist/getTouchDist())*ZOOM_AMPLIFYER)
			end
			if math.deg(angleDiff) > MAX_TURN_AND_ZOOM and amZooming then
				amRotating = true
			end
			firstDist = getTouchDist()
		else
			if lastTarget then
				TapNotValid = math.sqrt((zXanchor-e.x)^2+(zYanchor-e.y)^2)
				tangle = math.atan2(e.y-lastTarget.y,e.x-lastTarget.x)
			else
				TapNotValid = TapNotValid + math.sqrt((zXanchor-e.x)^2+(zYanchor-e.y)^2)
				cameraReady = false
				moveCamera((e.x-zXanchor),(e.y-zYanchor),false)
				zXanchor = e.x
				zYanchor = e.y
			end
			if(AllowArrow)then
				moveArrow(e.x,e.y)
			end
		end
	end
end

function EndTouch(e)
	if UnRegisterTouch(e) then
		if TapNotValid < MAX_TAP_TOLERANCE then
			TapNotValid = 0
		end
		local force = 0
		if getNrTouches() < 1 then
			if amZooming == false then
				--asteroid
				if(AllowArrow)then
					AllowArrow = false
					force = endArrow(e)
					if TapNotValid < MAX_TAP_TOLERANCE then
						TapNotValid = 0
					end
				end
				if hasJoint("player","sitJoint") then
					if TapNotValid == 0 then -- a tap outside any asteroid
						OnTap(e)
					else
						if(lastTarget and force>0) then -- a drag originated on an asteroid
							TelekinesisPush(lastTarget,tangle,force)
						end
					end
				else -- mid flight tap/drag
					if TapNotValid == 0 then
						if cameraReady == false then 
							print("Camera set to ready")
							cameraReady = true
						end
					end
					if hasJoint("player","telelink") then
						TelekinesisUnHook()
					else
						if lastTarget then
							TelekinesisHook(lastTarget)
						end
					end
				end
			end
			lastTarget = nil
			if amZooming then
				amZooming = false;
				reinstatePhBodies()
			end
			if(AllowArrow)then
				AllowArrow = false
				force = endArrow(e)
				if TapNotValid < MAX_TAP_TOLERANCE then
					TapNotValid = 0
				end
			end
		end
	end
end

function OnTap( event )
	print("#ON TAP CALLED")
	if hasJoint("player","telelink") then
		TelekinesisUnHook()
	end
	if cameraReady == false then
		print("Camera set to ready")
		cameraReady = true
		if(playerImage.x<0 or playerImage.y<0 or playerImage.x>display.contentWidth or playerImage.y>display.contentHeight) then
			return
		end
	end
	if hasJoint("player","sitJoint") then
		if( TapActionSelector == "jump") then
			DetachPlayer()
			print("Applying impulse:",FullImpulse*playerImage.width)
			local dx = (event.x - playerImage.x)*1.0
			local dy = (event.y - playerImage.y)*1.0
			local angle = math.atan2( dy, dx )
			playerCache["heading"]   = angle
			playerCache["impulseX"]  = FullImpulse*playerImage.width*math.cos(angle)
			playerCache["impulseY"]  = FullImpulse*playerImage.width*math.sin(angle)
			playerCache["MX"] = event.x
			playerCache["MY"] = event.y
			playerCache["allowAnim"] = nil
			playerImage.rotation = math.deg(playerCache["heading"])+90
			SwitchAnimation("player","PlayerFlying")
			PushAway = true
			playerCache["detached"] = true;
			elseif TapActionSelector == "conjureExplosion" then
			local mag = playerImage.width*ActionMagnitude
			if nrFlames >= ActionTrinketCost then
				nrFlames = nrFlames - ActionTrinketCost
				--animate number decrese
				CreateBlast(event.x,event.y,mag,mag,1)
				setNrFlames(nrFlames)
			end
		elseif TapActionSelector == "conjureImplosion" then
			local mag = playerImage.width*ActionMagnitude
			if nrVacums >= ActionTrinketCost then
				nrVacums = nrVacums - ActionTrinketCost
				--animate number decrese
				CreateBlast(event.x,event.y,mag,mag,-1)
				setNrVacuums(nrVacums)
			end
		end
	end
end

function HandleAsteroTap(e)
	print("HandleAsteroTap:",e.phase)
	if GameEndReason then
		return true
	end
	if (e.phase == "began") then
		BeginTouch(e)
		lastTarget  = e.target;
		print("Nr touches:",getNrTouches())
		if hasJoint("player","sitJoint") and getNrTouches() == 1 then --only allow arrow dragging if the nr of fingers on the screen is 1
			if( levelData[e.target.name]["bodyType"] == "dynamic" and levelData[e.target.name]["underTelekinesis"] == nil) then
				AllowArrow = true
				initialiseArrow(e)
			end
		end
	end
	if (e.phase == "moved")then --and lastTarget) then
		MoveTouch(e)
	end
	if (e.phase == "ended") then
		EndTouch(e)
	end
	return true -- unfortunately, this will not propogate down if false is returned
end

function HandleGeneralTouch(e)
	if (e.phase == "began") then
		BeginTouch(e)
	end
	if (e.phase == "moved") then
		MoveTouch(e)
	end
	if (e.phase == "ended") then
		--impulse and tele
		EndTouch(e)
	end
	return true
end
-----------------------------------------------------------------------------------------
-- TAP MODE SWITCH SYSTEM
-----------------------------------------------------------------------------------------
function SwitchTapMode(e)
	if e.phase ~= "began" then
		local ret = Activated
		if e.phase == "ended" then
			Activated = false;
		end
		return ret;
	end
	Activated = true;
	print("tap mode on:",e.target.name)
	if(e.target.name == "flame") then
		selector.isVisible = true
		selector.x = flame.x + flame.width/2
		selector.y = flame.y - flame.height/2
		TapActionSelector = "conjureExplosion"
	elseif(e.target.name == "vacuum") then
		selector.isVisible = true
		selector.x = vacuum.x + vacuum.width/2
		selector.y = vacuum.y - vacuum.height/2
		TapActionSelector = "conjureImplosion"
	else
		--debug
		reinstatePhBodies()
		ClearAllTouches()	
			range = display.newImageRect("fld.png",playerImage.width * TelekinesisRange*2,playerImage.width * TelekinesisRange*2) 
			--display.newCircle(playerImage.x,playerImage.y,playerImage.width * TelekinesisRange)
			--also ad a nice bordering image
			addToOwned("player",range,false,{key = "rangeShow",entermode = "fade",exitmode = "fade",wait = 60, ialpha = 0.3,fillColor ={r=230,g=0,b=255}});
			group:insert(range)
	
		selector.isVisible = false
		TapActionSelector = "jump"
	end
	return true
end
----------------------------------------------------------------------------------------
-- SCORE BAR SYSTEM
----------------------------------------------------------------------------------------

function createStatusBar(showFV)
	local w = display.contentWidth
	local icsize = w/9
	local h = icsize
	local spacing = 0;
	if icsize > h then
		icsize = h
		spacing = (w-6*icsize)/5.0
	end
	statusBar = display.newRect(0, 0, w, h)
	statusBar.strokewidth = 1
	statusBar:setFillColor(128,128,128)
	statusBar:setStrokeColor(128,128,128)
	statusBar.alpha=0.5
--  Star rating part, can be modified to show normal and dimmed stars	
	stars[1] = display.newImageRect(SELECTED_SKIN_PACK.."staticstar.png",SKIN_BASE_DIR, icsize, icsize)
	stars[1].anchorX = 0.0
	stars[1].anchorY = 1.0
	
	stars[1].x = 0
	stars[1].y = h
	stars[1].isVisible = false
	
	stars[2] = display.newImageRect(SELECTED_SKIN_PACK.."staticstar.png",SKIN_BASE_DIR, icsize, icsize)
	stars[2].anchorX = 0.0
	stars[2].anchorY = 1.0
	
	stars[2].x = icsize
	stars[2].y = stars[1].y
	stars[2].isVisible = false
	
	stars[3] = display.newImageRect(SELECTED_SKIN_PACK.."staticstar.png",SKIN_BASE_DIR, icsize, icsize)
	stars[3].anchorX = 0.0
	stars[3].anchorY = 1.0
	
	stars[3].x = icsize*2
	stars[3].y = stars[1].y
	stars[3].isVisible = false
	
	starSlot1 = display.newImageRect(SELECTED_SKIN_PACK.."EmptyStar.png",SKIN_BASE_DIR, icsize, icsize)
	starSlot1.x = stars[1].x+icsize/2;
	starSlot1.y = h-icsize/2;
	
	starSlot2 = display.newImageRect(SELECTED_SKIN_PACK.."EmptyStar.png",SKIN_BASE_DIR, icsize, icsize)
	starSlot2.x = stars[2].x+icsize/2;
	starSlot2.y = starSlot1.y;
	
	starSlot3 = display.newImageRect(SELECTED_SKIN_PACK.."EmptyStar.png",SKIN_BASE_DIR, icsize, icsize)
	starSlot3.x = stars[3].x+icsize/2;
	starSlot3.y = starSlot1.y;
	
--  Vacuum and flames (no instructions given, thus it only has pictures with text next to them
	
	flame = display.newImageRect(SELECTED_SKIN_PACK.."flame.png",SKIN_BASE_DIR, icsize, icsize)
	flame.anchorX = 0.0
	flame.anchorY = 1.0
	
	flame.x = icsize*3
	flame.y = stars[1].y
	flame.name = "flame"
	flame.alpha=0.5
	
	flameScore = display.newText(tostring(nrFlames),icsize, icsize, native.systemFont, 32)
	flameScore.anchorX = 0.0
	flameScore.anchorY = 1.0
	
	flameScore.x = icsize*4
	flameScore.y = stars[1].y
	flameScore.name = "flame"
	
	vacuum = display.newImageRect(SELECTED_SKIN_PACK.."vacuum.png",SKIN_BASE_DIR, icsize, icsize)
	vacuum.anchorX = 0.0
	vacuum.anchorY = 1.0
	
	vacuum.x = icsize*5
	vacuum.y = stars[1].y
	vacuum.name = "vacuum"
	vacuum.alpha=0.5
	
	vacuumScore = display.newText(tostring(nrVacums), icsize, icsize, native.systemFont, 32)
	vacuumScore.anchorX = 0.0
	vacuumScore.anchorY = 1.0
	
	vacuumScore.x = icsize*6
	vacuumScore.y = stars[1].y
	vacuumScore.name = "vacuum"
	
	gold = display.newImageRect(SELECTED_SKIN_PACK.."vacuum.png",SKIN_BASE_DIR, icsize, icsize)
	gold.anchorX = 0.0
	gold.anchorY = 1.0
	
	gold.x = icsize*7
	gold.y = stars[1].y
	gold.name = "gold"
	gold.alpha=0.5
	
	goldScore = display.newText(tostring(nrGold), icsize, icsize, native.systemFont, 32)
	goldScore.anchorX = 0.0
	goldScore.anchorY = 1.0
	
	goldScore.x = icsize*8
	goldScore.y = stars[1].y
	goldScore.name = "gold"
	
	selector = display.newImageRect(SELECTED_SKIN_PACK.."selector.png",SKIN_BASE_DIR,icsize*3,icsize*3)
	selector.x = 0
	selector.y = 0
	selector.isVisible = false
	selector.alpha=0.5
	
	if showFV == false then
		flame.isVisible = false
		flameScore.isVisible = false
		vacuum.isVisible = false
		vacuumScore.isVisible = false
	end
	
	group:insert(statusBar)
	group:insert(starSlot1)
	group:insert(starSlot2)
	group:insert(starSlot3)
	group:insert(stars[1])
	group:insert(stars[2])
	group:insert(stars[3])
	group:insert(selector)
	group:insert(flame)
	group:insert(flameScore)
	group:insert(vacuum)
	group:insert(vacuumScore)
	group:insert(gold)
	group:insert(goldScore)
end
function AddStatusBarListeners()
	flame:addEventListener("touch",SwitchTapMode)
	flameScore:addEventListener("touch",SwitchTapMode)
	vacuum:addEventListener("touch",SwitchTapMode)
	vacuumScore:addEventListener("touch",SwitchTapMode)
	statusBar:addEventListener("touch",SwitchTapMode)
end
function ClearStatusBarListeners()
	flame:removeEventListener("touch",SwitchTapMode)
	flameScore:removeEventListener("touch",SwitchTapMode)
	vacuum:removeEventListener("touch",SwitchTapMode)
	vacuumScore:removeEventListener("touch",SwitchTapMode)
	statusBar:removeEventListener("touch",SwitchTapMode)
end
function setNrStars(nrs)
	if nrs > 3 then
		return
	end
	if nrs <=3 and nrs>=0 then
		nrStars = nrs
		for i=1,nrStars do
			stars[i].isVisible = true
		end
	end
end
function setNrFlames(nr)
	if nr > 999 then
		return
	end
	if(nr<0) then
		flame.isVisible = false
		flameScore.isVisible = false
	else
		flame.isVisible = true
		flameScore.isVisible = true
		flameScore.text = tostring(nr)
	end
end
function setNrVacuums(nr)
	if nr > 999 then
		return
	end
	if(nr<0) then
		vacuum.isVisible = false
		vacuumScore.isVisible = false
	else
		vacuum.isVisible = true
		vacuumScore.isVisible = true
		vacuumScore.text = tostring(nr)
	end
end
function setNrGold(nr)
	if nr > 9999 then
		return
	end
	if(nr<0) then
		gold.isVisible = false
		goldScore.isVisible = false
	else
		gold.isVisible = true
		goldScore.isVisible = true
		goldScore.text = tostring(nr)
	end
end

function AddTrinket(key)
	local sheetParam = { width=80, height=80, numFrames=71, sheetContentWidth=2000, sheetContentHeight=240} 
	local sequenceData = {name = "normalRun", start=1, count=71, time=1200,loopDirection = "forward"}
	local ldk = levelData[key] 
	print("adding trinket",key)
	ldk["image"] = display.newRect(tonumber(ldk["x"]),tonumber(ldk["y"]),ldk["width"],ldk["height"])
	local ldki = ldk["image"]
	ldki.x = ldk["x"]
	ldki.y = ldk["y"]
	ldki.name = key
	ldk["density"] = 0
	ldki.alpha = 0
	physics.addBody( ldki, "static", { isSensor = true, radius = ldki.width/2 } )
	group:insert(ldki)
	local sa = nil
	local ea = nil;
	--[[if key:find("star") then
		sa = attachAnimation(key,"stay",{  "star.png",
									{ width=500, height=500, numFrames=4, sheetContentWidth=500, sheetContentHeight=2000},
									{ name = "normalRun", start=1, count=4, time=500,loopDirection = "bounce"},
									{ initialVisibility = false,direct_rel = true}});
		
		ea = attachAnimation(key,"exit",{  "star.png",
									{ width=500, height=500, numFrames=4, sheetContentWidth=500, sheetContentHeight=2000},
									{ name = "normalRun", start=1, count=4, time=500,loopCount=1,loopDirection = "forward"},
									{ initialVisibility = false,direct_rel = true},{listen=true}},ClearExitAnimation);
	elseif key:find("flame") then
		sa = attachAnimation(key,"stay",{  "star.png",
									{ width=500, height=500, numFrames=4, sheetContentWidth=500, sheetContentHeight=2000},
									{ name = "normalRun", start=1, count=4, time=500,loopDirection = "bounce"},
									{ initialVisibility = false,direct_rel = true}});
		
		ea = attachAnimation(key,"exit",{  "star.png",
									{ width=500, height=500, numFrames=4, sheetContentWidth=500, sheetContentHeight=2000},
									{ name = "normalRun", start=1, count=4, time=500,loopCount=1,loopDirection = "forward"},
									{ initialVisibility = false,direct_rel = true},{listen=true}},ClearExitAnimation);
	elseif key:find("vacuum") then
		sa = attachAnimation(key,"stay",{  "star_old.png",
									{ width=500, height=500, numFrames=4, sheetContentWidth=500, sheetContentHeight=2000},
									{ name = "normalRun", start=1, count=4, time=500,loopDirection = "bounce"},
									{ initialVisibility = false,direct_rel = true}});
		
		ea = attachAnimation(key,"exit",{  "star_old.png",
									{ width=500, height=500, numFrames=4, sheetContentWidth=500, sheetContentHeight=2000},
									{ name = "normalRun", start=1, count=4, time=500,loopCount=1,loopDirection = "forward"},
									{ initialVisibility = false,direct_rel = true},{listen=true}},ClearExitAnimation);
	elseif key:find("gold") then
		sa = attachAnimation(key,"stay",{  "coinAnimation.png",
									{ width=500, height=500, numFrames=4, sheetContentWidth=500, sheetContentHeight=2000},
									{ name = "normalRun", start=1, count=4, time=500,loopDirection = "backward"},
									{ initialVisibility = false,direct_rel = true}});
		
		ea = attachAnimation(key,"exit",{  "coinAnimation.png",
									{ width=500, height=500, numFrames=4, sheetContentWidth=500, sheetContentHeight=2000},
									{ name = "normalRun", start=1, count=4, time=500,loopCount=1,loopDirection = "backward"},
									{ initialVisibility = false,direct_rel = true},{listen=true}},ClearExitAnimation);
	end]]--
	if sa and ea then
		group:insert(sa)
		group:insert(ea)
		SwitchAnimation(key,"stay")
	end
end
--------------------------------------------------------------------------------
-- TELEKINETIC ARROW SYSTEM -- MIKES ARROW CODE
--------------------------------------------------------------------------------
local arrow
local rect
local arrow_srs
local arrow_len = 0
local last_x = 0
local last_y = 0
function initArrowSystem(reload)
	if reload == nil  then
		arrow = display.newImageRect(SELECTED_SKIN_PACK..'arrow_tip.png',SKIN_BASE_DIR,50,50)
		rect = display.newRect(0,0,15,15)
		group:insert(rect)
		group:insert(arrow)
	end
	arrow.x = 0
	arrow.y = 0
	arrow_len = 0
	arrow:setFillColor(0, 0, 255)
	arrow.isVisible = false
	rect:setFillColor(0, 0, 255)
	rect.isVisible = false
	last_x = 0
	last_y = 0
end
function initialiseArrow(event)
	arrow_srs = event.target
	rect.isVisible = true
	arrow.isVisible = true
	
	arrow:setFillColor(0, 0, 255)
	arrow.x = arrow_srs.x
	arrow.y = arrow_srs.y
	
	rect:setFillColor(0, 0, 255)
	rect.x = arrow_srs.x
	rect.y = arrow_srs.y
	
	last_x = arrow_srs.x
	last_y = arrow_srs.y
	rect:toFront()
	arrow:toFront()
end
function endArrow(event)
	AllowArrow = false
	arrow.isVisible = false
	rect.width = 0.001 -- not possible with 0
	rect.isVisible = false
	if(arrow_srs.x == nil) then
		return 0
	end
	return arrow_len
end
function moveArrow(x,y)
		if(arrow_srs.x == nil) then
			endArrow(event)
			return
		end
		rect.isVisible = true
		arrow.isVisible = true
	
		local dis_x = - arrow_srs.x + x
		local dis_y = - arrow_srs.y + y
		arrow_len = math.sqrt(math.pow(dis_x,2) + math.pow(dis_y,2))
		local angle = math.atan2(dis_y,dis_x)
		
		if arrow_len > 0 then
			if (arrow_len > TelekinesisForce) then
				arrow_len = TelekinesisForce
			end
			rect:setFillColor((255/TelekinesisForce) * (arrow_len), 0, (255/TelekinesisForce) * (TelekinesisForce - arrow_len))
			rect.rotation = math.deg(angle)
			rect.isVisivle = true
			rect.width = arrow_len
			rect.x = arrow_srs.x + arrow_len*math.cos(angle)/2
			rect.y = arrow_srs.y + arrow_len*math.sin(angle)/2

			arrow:setFillColor((255/TelekinesisForce) * (arrow_len), 0, (255/TelekinesisForce) * (TelekinesisForce - arrow_len))
			arrow.rotation = math.deg(angle + (88.75 / (2*math.pi)))
			arrow.isVisivle = true
			arrow.x = arrow_srs.x + arrow_len*math.cos(angle)
			arrow.y = arrow_srs.y + arrow_len*math.sin(angle)
		end
		last_x = x
		last_y = y
end
-----------------------------------------------------------------------------------------------------------
-- ACTOR HEALTH SYSTEM
-----------------------------------------------------------------------------------------------------------
function DecreaseEnemyHealth(key,amount)
	if levelData[key]== nil then
		return
	end
	local ldk = levelData[key]
	--debug
	if  ldk["health"] == nil then
		ldk["health"] = 100;
	end
	-- end debug
	if amount == nil then
		return
	end
	print("Enemy health:",ldk["health"]," decreasing by:",amount);
	if( ldk["health"] ) then
		ldk["health"] = ldk["health"] - amount; 
		if(ldk["health"] <= 0) then--remove enemy
			ldk["toRemove"] = true
			--removeObject(key,false);
		end
	end
end
-------------------------------------------------------------------------------------------------------------
-- BLAST SYSTEM
-------------------------------------------------------------------------------------------------------------
ClearAnimation = function(e) -- auto cleaner function ( listens for animation end and cleans animation ) TESTED
	if e.phase == "ended" then
		removeObject(e.target.name,true)
	end
end

function GetAsteroidsInRange(x,y,range)
	local lst = {}
	local index = 1
	for key,value in pairs(levelData) do
		if value["density"] ~= nil and value["image"] and value["image"].isVisible then
			local dist = math.sqrt((x - value["image"].x)^2 + (y - value["image"].y)^2)
			if dist < range then
				print("Adding",key,"to list or exploded")
				lst[index] = value
				index = index + 1
			end
		end
	end
	return lst
end

function AddBlastAnimation(Magnitude,Dir,xx,yy)
	Magnitude = Magnitude/2
	if(Dir>0) then
		print("Blast of magnitude",Magnitude)
		local blastID = {"blast",BlastNr}
		blastID = table.concat(blastID)
		BlastNr = BlastNr+1
		
		createObject(blastID,{imgname="2px.png",x=xx,y=yy,width=2,height=2})
		local ea = attachAnimation(blastID,"animation",{"explosion.png",
										    { width=64, height=64, numFrames=24, sheetContentWidth=320, sheetContentHeight=320 },
										    { name = "normalRun", start=1, count=24, time=400,loopCount = 1},
										    { initialVisibility = false, width_rel = Magnitude,height_rel = Magnitude},
										    { listen=true}},ClearAnimation)
		if ea then
			group:insert(ea)
			showAnimation(blastID,"animation")
		end
	else
		print("Blast of magnitude",Magnitude)
		local blastID = {"blast",BlastNr}
		blastID = table.concat(blastID)
		BlastNr = BlastNr+1

		createObject(blastID,{imgname="2px.png",x=xx,y=yy,width=2,height=2})
		local ea = attachAnimation(blastID,"animation",{"implosion.png",
										    { width=64, height=64, numFrames=24, sheetContentWidth=320, sheetContentHeight=320 },
										    { name = "normalRun", start=1, count=24, time=400,loopCount = 1},
										    { initialVisibility = false, width_rel = Magnitude,height_rel = Magnitude},
										    { listen=true}},ClearAnimation)
		if ea then
			group:insert(ea)
			showAnimation(blastID,"animation")
		end
	end
end

function CreateBlast(origX,origY,Range,Magnitude,Dir)
	AddBlastAnimation(Range,Dir,origX,origY)
	list = GetAsteroidsInRange(origX,origY,Range)
	print("List len:",#list)
	for i=1,#list do
		--if( list[i]["image"] ) then
			local angle = math.atan2( list[i]["image"].y - origY , list[i]["image"].x - origX )
			local intensity = 1 - math.sqrt( (origX-list[i]["image"].x)^2 + (origY-list[i]["image"].y)^2 ) / Range
			local impX = intensity * Magnitude * math.cos( angle )
			local impY = intensity * Magnitude * math.sin( angle )
			if( Dir < 0) then
				impX = -impX
				impY = -impY
			end
			print("Creating BLAST for",list[i]["image"].name,i)
			list[i]["image"]:applyLinearImpulse(impX,impY,list[i]["image"].x,list[i]["image"].y)
			if(list[i]["image"].name:find("enemy"))then
				if Magnitude<0 then
					Magnitude = -Magnitude
				end
				DecreaseEnemyHealth(list[i]["image"].name,intensity*Magnitude);
			end
		--end
	end
end

-------------------------------------------------------------------------------------
-- ENEMY TELEKINESIS HOOK SYSTEM
-------------------------------------------------------------------------------------
function EnemyHook(parent)
	if not hasJoint("player",parent) then
		createJoint(parent,"tele","player",parent,{ hasImage=true,
			                                        loadedImage=parent,
												    isAnimation = true, -- i want the createjoint to play the animation
												    frequency=0.4,
												    dampingRation=0.0 })
		SwitchAnimation(parent,"action")
	end
end
function EnemyUnHook(parent)
	if hasJoint("player",parent) then
		removeJoint("player",parent)
		SwitchAnimation(parent,"static")
	end
end
function UnhookAllEnemies()
	for key,val in pairs(levelData) do
		if(key:find("enemy") and val["actionType"] == "dragger") then
			EnemyUnHook(key)
		end
	end
end
-------------------------------------------------------------------------------------
-- PLAYER TELEKINESIS HOOK SYSTEM
-------------------------------------------------------------------------------------
function TelekinesisHook(obj)
	if not hasJoint("player","telelink") and obj then
		local dist = math.sqrt((playerImage.x-obj.x)^2 + (playerImage.y-obj.y)^2)
		if dist <= playerImage.width * TelekinesisRange then
			createJoint("telelink","tele","player",obj.name,{ hasImage=true,
			                                                loadedImage="telelink",
															isAnimation = true, -- i want the createjoint to play the animation
															frequency=0.4,
															dampingRation=0.0})
			SwitchAnimation("player","PlayerFlyingTele")
		else
			range = display.newImageRect("fld.png",playerImage.width * TelekinesisRange*2,playerImage.width * TelekinesisRange*2)
			addToOwned("player",range,true,{key = "rangeShow",entermode = "fade",exitmode = "fade",wait = 60, ialpha = 0.3, fillColor ={r=230,g=0,b=255} });
			group:insert(range)
		end
	end
end
function TelekinesisUnHook()
	if hasJoint("player","telelink") then
		print("removing joint","player","telelink")
		removeJoint("player","telelink")
		SwitchAnimation("player","PlayerFlying")
	end
end
function TelekinesisPush(object,angle,force)
	if (object) then
		if levelData[object.name]~= nil and levelData[object.name]["image"] and levelData[object.name]["image"].isVisible and levelData[object.name]["underTelekinesis"] == nil then
			--create animation
			print("Moving with telekinesis:",math.deg(angle))
			levelData[object.name]["underTelekinesis"] = true
			object:applyLinearImpulse(force * math.cos(angle),force * math.sin(angle),object.x,object.y)
			SwitchAnimation("player","PlayerStandingTele")
		end
	else
		print("TelekinesisPush failed because object was void")
	end
end
-----------------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------------
function KeepPlayerCloseToAsteroid(ast)
	local angle = math.atan2(playerImage.y - ast.y , playerImage.x - ast.x)
	local radius = tonumber(ast.width/2) + tonumber(playerImage.width/2);
	local dist = math.sqrt(( playerImage.x - ast.x )^2 + ( playerImage.y - ast.y )^2 )
	local weldX = ast.x + math.floor(radius * math.cos(angle))
	local weldY = ast.y + math.floor(radius * math.sin(angle))
	print("dist",dist)
	playerImage.x = weldX
	playerImage.y = weldY
end
function ABSangle(angle)
	if angle>0 then
		return angle
	end
	return math.pi + angle;
end
--------------------------------------------------------------------------------------------------
-- PLAYER ATTACH DETACH SYSTEM
--------------------------------------------------------------------------------------------------
function AttachPlayer(object,removeCrnt)
	print("#Attaching...")
	if object == nil then
		print("CRITICAL ERROR:Attach player failed! This is not supposed to happen!");
		return;
	end
	
	local sameAstero = false
	if( object == playerCache["joinWith"] ) then
		sameAstero = true
	end
	
	playerCache["joinTarget"] = nil
	playerCache["joinWith"] = object
	if removeCrnt then
		playerImage:setLinearVelocity(0,0)
	end

	local mouseHeading = nil
	print("Mouse issue:",playerCache["MX"],playerCache["MY"])
	if(playerCache["MX"] == nil ) then
		sameAstero = false
	else
		mouseHeading = math.atan2(playerCache["MY"] - object["image"].y , playerCache["MX"] - object["image"].x)
	end
	
	local angle = math.atan2(playerImage.y - object["image"].y , playerImage.x - object["image"].x)
	local radius = (tonumber(object["image"].width/2) + tonumber((playerImage.width*0.9)/2));
	local dist = math.sqrt(( playerImage.x - object["image"].x )^2 + ( playerImage.y - object["image"].y )^2 )
	
	local sgn = 1
	print("Attaching: same astero?",sameAstero)
	-- when attaching to the same asteroid move the player a certain amout of degrees on the 
	-- length of the circle
	if( sameAstero ) then
		-- f(x,y) = tan(angle)(x-x1)+y1-y = 0
		-- local sng = math.tan(angle)*(playerCache["MX"] - playerImage.x) + playerImage.y - playerCache["MY"]   
		
		-- (b.x - a.x)*(c.y - a.y) - (b.y - a.y)*(c.x - a.x)  a line point 1, b line point 2, c point to check against
		local signY = playerImage.y - playerCache["MY"] 
		local signX = playerImage.x - playerCache["MX"]
		if signX > 0 then
			signX = 1
		end
		if signX < 0 then
			signX = -1
		end
		if signY > 0 then
			signY = 1
		end
		if signY < 0 then
			signY = -1
		end
		
		local sgn = signX * signY
		if signX == 0 or signY == 0 then
			if signX ~= 0 then
				sgn = signX
			end
			if signY ~= 0 then
				sgn = signY
			end
		end
		-- scale number of degrees depending on asteroid size
		local ang = 45 * playerImage.width / object["image"].width;
		if ang > 45 then
			ang = 45
		end
		--angle = angle + sgn*math.rad(ang) -- in stead of an angle for all asteroids give a circle arc
	end
	
	local weldX = object["image"].x + math.floor(radius * math.cos(angle))
	local weldY = object["image"].y + math.floor(radius * math.sin(angle))
	playerImage.x = weldX
	playerImage.y = weldY
	
	playerCache["weldX"] = object["image"].x + math.floor((radius+2) * math.cos(angle))
	playerCache["weldY"] = object["image"].y + math.floor((radius+2) * math.sin(angle))
	playerCache["heading"] = math.rad(math.deg(angle+math.rad(90))%360)
	
	dist = math.sqrt(( playerImage.x - object["image"].x )^2 + ( playerImage.y - object["image"].y )^2 )
	print("new dist",dist,"r",radius)
	local percentage = playerImage.width/2/dist
	playerCache["weldX"] = playerImage.x + ( playerImage.x - object["image"].x )*percentage
	playerCache["weldY"] = playerImage.y + ( playerImage.y - object["image"].y )*percentage
	if(	removeCrnt and hasJoint("player","sitJoint")) then
		removeJoint("player","sitJoint")
	end
	
	playerCache["rotPace"] = (math.deg(playerCache["heading"]) - playerImage.rotation) / ROTATION_PACE   
	print("Heading:",math.deg(playerCache["heading"]),"Current:",playerImage.rotation,"pace:",playerCache["rotPace"])
	print("PLAYER REATTACH")
	createJoint("sitJoint","pivot","player",object["image"].name,{hasImage="noimage"})
	playerCache["allowAnim"] = true
	SwitchAnimation("player","player")
	playerCache["detached"] = false;
	if hasJoint("player","telelink") then
		TelekinesisUnHook()
	end
end
function DetachPlayer()
	if hasJoint("player","sitJoint") then
		removeJoint("player","sitJoint")
		playerCache["detached"] = true;
		print("Player detached")
	end
end
-------------------------------------------------------------------------------------------
-- ACTION ENEMY SYSTEM
-------------------------------------------------------------------------------------------
local lastx = 0
local lasty = 0
local deltax = 0
local deltay = 0
-- enemy action function
function ActionEnemy(enemyID)
	local enemyIMG = levelData[enemyID]["image"]
	local enemyRoot = levelData[enemyID]
	if enemyIMG.isVisible == false then
		return
	end
	
	local angle = math.atan2( playerImage.y - enemyIMG.y, playerImage.x - enemyIMG.x )
	local GoForce = enemyRoot["GoForce"]
	if GoForce ~= nil then
		GoForce = GoForce * enemyIMG.width
	end
	
	local dist = math.sqrt((enemyIMG.x - playerImage.x)^2 + (enemyIMG.y - playerImage.y)^2) - playerImage.width/2
	if enemyRoot["actionType"] == "static" then
		-- generate projectile or maybe not
	elseif enemyRoot["actionType"] == "dumb-charging" then
		-- see if player is in range and charge straight ahead
		if(dist <= enemyRoot["range"]*enemyIMG.width/2) then
			enemyIMG:applyForce(GoForce*math.cos(angle),GoForce*math.sin(angle),enemyIMG.x,enemyIMG.y)
			if enemyRoot["owns"] and enemyRoot["owns"]["field"] and enemyRoot["owns"]["field"]["image"] then
				enemyRoot["owns"]["field"]["image"].isVisible = false
			end
			enemyRoot["CODEdeactivated"] = true
			SwitchAnimation(enemyID,"move")
		else
			if enemyRoot["owns"] and enemyRoot["owns"]["field"] and enemyRoot["owns"]["field"]["image"].isVisible == false then
				enemyRoot["owns"]["field"]["image"].isVisible = true
				enemyIMG:setLinearVelocity( 0 , 0 )
			end
			enemyRoot["CODEdeactivated"] = nil
			SwitchAnimation(enemyID,"static")
		end
	elseif enemyRoot["actionType"] == "ever-charging" then
		-- go towards player
		SwitchAnimation(enemyID,"move")
		enemyIMG:applyForce(GoForce*math.cos(angle),GoForce*math.sin(angle),enemyIMG.x,enemyIMG.y)
	elseif enemyRoot["actionType"] == "dragger" then
		if(dist <= enemyRoot["range"]*enemyIMG.width/2) then
			if not hasJoint("player","sitJoint") and playerCache["rotPace"] == nil then
				EnemyHook(enemyID)
			else
				if hasJoint("player",enemyID) then
					EnemyUnHook(enemyID,false)
				end
			end
			enemyRoot["CODEdeactivated"] = true
		else
			if hasJoint("player",enemyID) then
				EnemyUnHook(enemyID,false)
			end
			enemyRoot["CODEdeactivated"] = nil
		end
	end
end
--------------------------------------------------------------------------------------------------------
-- CHEMICAL INTERACTION SYSTEM
--------------------------------------------------------------------------------------------------------
function ChemicalReaction(obj1,obj2)
	if obj1["image"].name:find("ast") or obj1["image"].name:find("enemy") or obj1["image"].name:find("planet") or obj1["image"].name:find("sun") then
		if obj2["image"].name:find("ast") or obj2["image"].name:find("enemy") or obj2["image"].name:find("planet") or obj2["image"].name:find("sun") then
			local magnitude = 0 
			if obj1["explosiveness"] then
				magnitude = magnitude + obj1["explosiveness"]*obj1["image"].width 
			end
			if obj2["explosiveness"] then
				magnitude = magnitude + obj2["explosiveness"]*obj2["image"].width
			end
			if magnitude == 0 then
				return
			end
			local sign = magnitude
			if( magnitude ~= 0) then
				print("creating blast:mag::",magnitude);
				if(magnitude<0) then
					magnitude = -magnitude
				end
				local range = magnitude
				local cx,cy = (obj1["image"].x+obj2["image"].x)/2,(obj1["image"].y+obj2["image"].y)/2;
				print("Creating Blast");
				if(obj1["image"].name:find("ast")) then
					local resistance = obj1["image"].width*obj1["density"]/10;
					print("Magnitude:",magnitude,"Resistance:",resistance,(1 - magnitude/resistance))
					if( resistance > magnitude ) then
						AsterosToResize[string.format("%d",ATRindex)] = {obj1["image"].name,(1 - magnitude/resistance)}
						ATRindex = ATRindex + 1
					else					
						obj1["toRemove"] = true
					end
				end
				if(obj2["image"].name:find("ast")) then
					local resistance = obj2["image"].width*obj2["density"]/10;
					print("Magnitude:",magnitude,"Resistance:",resistance,(1 - magnitude/resistance))
					if( resistance > magnitude ) then
						AsterosToResize[string.format("%d",ATRindex)] = {obj2["image"].name,(1 - magnitude/resistance)}
						ATRindex = ATRindex + 1
					else					
						obj2["toRemove"] = true
					end
				end
				if range < obj1["image"].width+obj2["image"].width then
					range = obj1["image"].width+obj2["image"].width;
				end
				CreateBlast(cx,cy,magnitude,magnitude,sign)
			end
		end
	end
end
--------------------------------------------------------------------------------------
-- INTERACTION SYSTEM
--------------------------------------------------------------------------------------
function PlayerCollision(event)
	print("Player Collision,",event.phase)
	if event.phase == "began" then
	if playerCache["deactivated"] then
		return
	end
	if event.other.name == nil then
		return
	end
	if event.other.name:find("ast") and event.other.root then
		print("Player collision with astero:",event.other.name,"field",levelData[event.other.name]["owns"]["field"])
		vx,vy = playerImage:getLinearVelocity()
		playerCache["impulseX"] = vx
		playerCache["impulseY"] = vy
		playerImage:setLinearVelocity(0,0)
		playerCache["joinTarget"] = event.other.name
		print("CollisionTarget:",event.other.name)
		FreeToAttach = true
	end
	if event.other.name:find("enemy") then
		playerImage:setLinearVelocity(0,0)
		print("GAME ENDED: LOOSE!")
		if( GameEndReason == nil) then
			Capturer = event.other.name
			GameEndReason = "Got captured!"
			--let the enter frame do the job
		end
	end
	if event.other.name:find("planet") and event.other.root then
		playerImage:setLinearVelocity(0,0)
		playerCache["absorbBy"] = event.other.name 
		if hasJoint("player","sitJoint") then
			removeJoint("player","sitJoint")
		end
		--GameEndReason = "Crashed!"
	end
	if event.other.name:find("sun") and event.other.root then
		playerImage:setLinearVelocity(0,0)
		GameEndReason = "Crashed!"
	end
	if event.other.name:find("Trinket") then
		print("Switching animation:",event.other.name)
		SwitchAnimation(event.other.name,"exit")
		print("Trinket collision exchange done")
		if event.other.name:find("star") then
			nrStars = nrStars+1
			setNrStars(nrStars)
			-- animate star add
		end
		if event.other.name:find("flame") then
			nrFlames = nrFlames+1
			setNrFlames(nrFlames)
			-- animate flame add
		end
		if event.other.name:find("vacum") then
			nrVacums = nrVacums+1
			setNrVacuums(nrVacums)
			-- animate vacum add
		end
		if event.other.name:find("gold") then
			nrGold = nrGold + 1
		end
	end
	end
end

function GravityCollision( self, event )
	if( self.name == event.other.name or levelData[event.other.name] == nil or levelData[event.other.name]["gravityControl"] == nil) then
		return
	end
	print("Gravitation interaction",event.phase,self.name,event.other.name)
	--if levelData[event.other.name]["bodyType"] and levelData[event.other.name]["bodyType"] == "dynamic" then 
		if ( event.phase == "began" and levelData[event.other.name]["gravityControl"][self.name] == nil ) then
			print("Setting up joint for gravity pull")
			levelData[event.other.name]["gravityControl"][self.name] = 1
			-- debug
			local dx = levelData[event.other.name]["image"].x - levelData[self.name]["image"].x
			local dy = levelData[event.other.name]["image"].y - levelData[self.name]["image"].y
			local range = math.sqrt(dx^2+dy^2)
			local angle = math.atan2(dy,dx)
			local force = display.newImage("2px.png")
			force.anchorX = 0.0
			force.anchorY = 0.0
	
			force.rotation = math.deg(angle)
			print("adding force to",key)
			addToOwned(self.name,force,false,{key = "bla",distance_rel = 0, rotation_rel=0})
			group:insert(force)
		end
		if ( event.phase == "ended" ) then
			--assume removeJoint checks for existance
			removeJoint(event.other.name,self.name)
		end
	--end
end

function GeneralInteraction(event)
	if levelData[event.object1.name]["underTelekinesis"] then
		levelData[event.object1.name]["underTelekinesis"] = nil
	end
	if levelData[event.object2.name]["underTelekinesis"] then
		levelData[event.object2.name]["underTelekinesis"] = nil
	end
	if levelData[event.object1.name]["absorb"] then
		levelData[event.object2.name]["absorbBy"] = event.object1.name 
		levelData[event.object2.name]["image"].isSensor = true
		if(event.object2.name:find("enemy"))then
			levelData[event.object2.name]["ALLdeactivated"] = true
		end
		if(event.object2.name:find("player")) then
			if hasJoint("player","telelink") then
				TelekinesisUnHook()
			end
			if hasJoint("player","sitJoint") then
				DetachPlayer()
			end
		end
	end
	if levelData[event.object2.name]["absorb"] then
		levelData[event.object1.name]["absorbBy"] = event.object2.name 
		levelData[event.object1.name]["image"].isSensor = true
		if(event.object1.name:find("enemy"))then
			levelData[event.object1.name]["ALLdeactivated"] = true
		end
		if(event.object1.name:find("player")) then
			if hasJoint("player","telelink") then
				TelekinesisUnHook()
			end
			if hasJoint("player","sitJoint") then
				DetachPlayer()
			end
		end
	end
	if event.object1.name:find("ast") or event.object2.name:find("ast") then
		--two asteroids have collided
		--calculate chemical reaction and do stuff
		ChemicalReaction(levelData[event.object1.name],levelData[event.object2.name])
		if event.object1.name:find("enemy") then
			--print("Event.force",event.force);
			DecreaseEnemyHealth(event.object1.name,event.force/10);
		elseif event.object2.name:find("enemy") then
			--print("Event.force",event.force);
			DecreaseEnemyHealth(event.object2.name,event.force/10);
		end
	end
	if event.object1.name:find("planet") and event.object2.name:find("enemy") then
		levelData[event.object2.name]["image"]:setLinearVelocity(0,0)
		levelData[event.object2.name]["absorbBy"] = event.object1.name 
		--GameEndReason = "Crashed!"
	end
	if event.object2.name:find("planet") and event.object1.name:find("enemy") then
		levelData[event.object1.name]["image"]:setLinearVelocity(0,0)
		levelData[event.object1.name]["absorbBy"] = event.object2.name 
		--GameEndReason = "Crashed!"
	end
end
--------------------------------------------------------------------------
-- PAUSE MENU SYSTEM
--------------------------------------------------------------------------
function UnFreezeGame()
	if GameFrozen then
		print("Unfreezing Game")
		physics.start()
		background:addEventListener( "touch", HandleGeneralTouch )
		Runtime:addEventListener("postCollision", GeneralInteraction)
		GameFrozen = false
		resumeAllAnimations()
	end
end
function FreezeGame()
	if not GameFrozen then
		print("Freezing Game!")
		physics.pause()
		background:removeEventListener("touch", HandleGeneralTouch )
		Runtime:removeEventListener("postCollision", GeneralInteraction)
		GameFrozen = true
		pauseAllAnimations()
	end
end
function TriggerPauseMenu()
	if pauseMenu.isVisible then
		pauseMenu.isVisible = false
		pauseBtn.isVisible = true
		pauseMenu:toFront()
	else
		FreezeGame()
		pauseBtn.isVisible = false
		--maybe animate
		pauseMenu.isVisible = true
		if NO_RETRY then
			retryButton.isVisible = false
		end
	end
	return true
end
function CreatePauseMenu()
	local sizeCoef = 0.15
	local backButton = widget.newButton{
		defaultFile="backButton.png",
		overFile="backButtonOver.png",
		width = display.contentWidth*sizeCoef, height = display.contentWidth*sizeCoef,
		onRelease = onBackBtnPress	-- event listener function
	}
	local playButton = widget.newButton{
		defaultFile="playButton.png",
		overFile="playButtonOver.png",
		width = display.contentWidth*sizeCoef, height = display.contentWidth*sizeCoef,
		onRelease = onPlayBtnPress	-- event listener function
	}
	local retryButton = widget.newButton{
		defaultFile = "retryButton.png",
		overFile = "retryButtonOver.png",
		width = playButton.width,
		height = playButton.height,
		onRelease = onRetryBtnPress,
	}
	
	playButton.x = display.contentWidth/2
	playButton.y = display.contentHeight/2
	
	retryButton.x = playButton.x+playButton.width+retryButton.width/2
	retryButton.y = playButton.y
	
	backButton.x = playButton.x - playButton.width - backButton.width/2
	backButton.y = playButton.y
	
	pauseMenu:insert(backButton)
	pauseMenu:insert(retryButton)
	pauseMenu:insert(playButton)
	pauseMenu.isVisible = false
	group:insert(pauseMenu)
end
------------------------------------------------------------------------------
-- MAIN TIMELINE
------------------------------------------------------------------------------
function IsInsideAsteroid()
	local bestD = display.contentWidth*display.contentHeight
	local bestK = "ast0"
	local px = playerImage.x
	local py = playerImage.y
	for key,value in pairs(levelData) do
		if key:find("ast") and value["image"] and value["image"].isVisible == true then
			local dist = math.sqrt((px-value["image"].x)^2 + (py-value["image"].y)^2)
			if  bestD > dist then
				bestK = key
				bestD = dist
			end
		end
	end
	return levelData[bestK]
end
function ManageOnScreenList(event)
	print("Player Collision,",event.phase)
	if event.phase == "began" then
		isOnScreen[event.other.name] = true;
		resumeAnimations(event.other.name)
	elseif event.phase == "ended" then
		if isOnScreen[event.other.name] then
			pauseAnimations(event.other.name)
			isOnScreen[event.other.name] = nil;
		end
	end
end
local fullRun = false
function frameEnter(event)
	--debug
	--DebugLabel.text = "NrOBJ:"..nrObjects.."\nNrJoints:"..nrJoints.."\nNrOwnedOBJ:"..nrOwnedObjects.."\nNrAnimations:"..nrAnimations
	--update_forces()
	--
	fps.tick()
	-- zoom routine
	if zoomAm ~= 1 and zoomAm then
		-- camera rotation routine
		if lastAngle == nil then
			lastAngle = getTouchAngle()
			angleDiff = 0
		else
			print("LAST ANGLE:",math.deg(lastAngle))
			local angleNow = getTouchAngle()
			if angleNow then
				angleDiff = angleDiff + (angleNow - lastAngle)
				rotateCamera((angleNow - lastAngle)*ROTATION_AMPLIFYER)
			end
			lastAngle = angleNow 
		end
		if amRotating == false then
			lastZoomAm = zoomAm;
			zoomCamera(1/zoomAm)
			zoomAm = 1
		end
	end
	-- resize asteroids after explosion
	for a,b in pairs(AsterosToResize) do
		print("Resizing astero:",b[1])
		zoomObject(levelData[b[1]]["image"].x,levelData[b[1]]["image"].y,b[2],b[1],true)
		AsterosToResize[a] = nil
	end
	
	TickCount = TickCount + 1
	
	if GameEndReason then
		print("Ending from Frame Enter")
		EndGame()
		return
	end
	-- arrow source updating
	if AllowArrow then
		moveArrow(last_x,last_y)
	end
	-- if tap mode selected then rotate if for effect
	if selector.isVisible then
		selector:rotate(5)
	end
	-- if there is no player then abort frame
	if playerCache == nil then
		return
	else
		-- rotate player into place as he lands on the asteroid
		if playerCache["rotPace"] and playerCache["detached"] == false then
			playerImage:rotate(playerCache["rotPace"])
			playerImage.rotation = playerImage.rotation%360
			if(math.abs(playerImage.rotation - math.deg(playerCache["heading"])) <= 360/ROTATION_PACE) then
				print("Welding player")
				playerImage.rotation = math.deg(playerCache["heading"])
				playerCache["rotPace"] = nil
				--playerCache["joint2"] = physics.newJoint( "pivot",playerCache["joinWith"]["image"],playerImage, playerCache["weldX"],playerCache["weldY"] )
			end
		else
			if(playerCache["joinWith"] and playerCache["joinWith"]["image"])then
				local angle = math.atan2(playerImage.y - playerCache["joinWith"]["image"].y,playerImage.x - playerCache["joinWith"]["image"].x)
				playerImage.rotation = math.deg(angle)+90
			end
		end
	end
	-- recover after zoom
	if ZoomRecover then
		RecoverAfterZoom()
	end
	-- if player must jump then so be it
	if PushAway then
		PushAway = false
		print("Pushing player away form asteroid")
		playerImage:applyLinearImpulse( playerCache["impulseX"], playerCache["impulseY"], playerImage.x, playerImage.y )
	end
	
	-- move camera with palyer
	if cameraReady then--and ( fullRun or math.abs(playerImage.x - background.x)>display.contentWidth/4 or math.abs(playerImage.y - background.y) > display.contentHeight/3 ) then
		local Dx = background.x - playerImage.x
		local Dy = background.y - playerImage.y
		local dist = math.sqrt(Dx^2+Dy^2)
		--local csf = 15-- math.sqrt((playerImage.x - background.x)^2+(playerImage.y - background.y))/2 --10
		if Dx or Dy then
			moveCamera(Dx/15,Dy/15,true)
		end
		deltax = lastx - playerImage.x
		deltay = lasty - playerImage.y
		lastx = playerImage.x
		lasty = playerImage.y
		if math.sqrt((playerImage.x - background.x)^2+(playerImage.y - background.y)) <= (playerImage.width/10) then -- 1 then
			fullRun = false
		else
			fullRun = true
		end
	end
	-- if not zooming, meaning that all objects have physics bodies
	-- during zoom no objects have physics bodies
	if(amZooming == false) then
		--decor.animate()
		if FreeToAttach then
			FreeToAttach = false
			local asteroid
			if playerCache["joinTarget"] == nil then
				asteroid = IsInsideAsteroid()
			else
				asteroid = levelData[playerCache["joinTarget"]]
			end
			if(asteroid)then
				local isDistinct = true
				if( playerCache["joinWith"]["image"] ) then
					print("attachign player:",playerCache["joinWith"],playerCache["joinWith"]["image"])
					print("Identity check:",playerCache["joinWith"]["image"].name , asteroid["image"].name)
					if( playerCache["joinWith"]["image"].name == asteroid["image"].name ) then
						isDistinct = false
					end
				end
				AttachPlayer(asteroid,true)
				print("isDistinct:",isDistinct)
				if isDistinct then
					asteroid["image"]:applyLinearImpulse(playerCache["impulseX"]/10,playerCache["impulseY"]/10,asteroid["image"].x,asteroid["image"].y)
				end
			end
		end
		-- in level code executor
		for key,value in pairs(instructions) do
			if (value["CODEdeactivated"] == nil and (value["nrExecutions"] == nil or tonumber(value["nrExecutions"]) ~= 0 )) then
				if TickCount % tonumber(value["period"]) == 0 then
					if value["codePointer"] == nil then
						value["codePointer"] = 1
					end
					ExecuteCode(key)
					value["codePointer"] = value["codePointer"] + 1
					if value["codePointer"] > #value["code"] then
						value["codePointer"] = 1
					end
				end
				-- decrease the number of times this operation has to be performed
				if value["nrExecutions"] then
					if tonumber(value["nrExecutions"]) > 0 then
						value["nrExecutions"] = tonumber(value["nrExecutions"]) - 1
					end
					-- optional
					-- unload code when finished executing
					if tonumber(value["nrExecutions"]) == 0 then
						instructions[key] = nil
					end
				end
			end
		end
	end
	-- debug let's measure the time taken to go through the code updater
	-- core updater
	local start = system.getTimer()
	-- only update elements that are visible
	for key,value in pairs(isOnScreen) do
		updateObject(key)
		if levelData[key]["joints"] then
			updateJoints(key,amZooming)
		end
	end
	-- go to general updater
	for key,value in pairs(levelData) do
		--if key:find("blast") then -- debug
		--	print("PROCESSING BLAST:",key)
		--end	
		-- update game shapes
		if value["image"] and value["image"].isVisible then
			-- update any owned objects
			-- update level boundaries
			if key ~= "player" and key ~= "botleft" and key ~= "topleft" and key ~= "botright" and key ~= "topright"  then
				-- min
				if topLeftCache.x > value["image"].x - value["image"].width  then -- minx has changed => change accordingly
					topLeftCache.x = value["image"].x - value["image"].width 
					levelData["botleft"]["image"].x = topLeftCache.x
					--print("rebound minX",topLeftCache.x)
				end
				if topLeftCache.y > value["image"].y - value["image"].height then
					topLeftCache.y = value["image"].y - value["image"].height
					levelData["topright"]["image"].y = topLeftCache.y
					--print("rebound minY",topLeftCache.y)
				end
				-- max
				if bottomRightCache.x < value["image"].x + value["image"].width  then
					bottomRightCache.x = value["image"].x + value["image"].width
					levelData["topright"]["image"].x = bottomRightCache.x
					--print("rebound maxX",bottomRightCache.x)
				end
				if bottomRightCache.y < value["image"].y + value["image"].height then
					bottomRightCache.y = value["image"].y + value["image"].height
					levelData["botleft"]["image"].y = topLeftCache.y
					--print("rebound maxY",bottomRightCache.y)
				end
			end
			-- summon periodic animtions
			if value["periodicAnimation"] and value["allowAnim"] then
				if( TickCount%value["periodicAnimation"]["period"] == 0 ) then
					--SwitchAnimation(key,value["periodicAnimation"]["anims"][value["periodicAnimation"]["jumpTo"]])
					if(value["periodicAnimation"]["randomize"])then
						local rand =  math.floor(math.random() * value["periodicAnimation"]["randomize"])
						if(rand>0)then
							value["periodicAnimation"]["period"] = rand
						end
					end
				end
			end
			if amZooming == false then
				-- gravitational links creation
				if value["gravityControl"] then
					for Gparent,val in pairs(value["gravityControl"]) do
						if(levelData[Gparent] and levelData[Gparent]["image"]) then
							if val then
								local params = {}
								params["repell"] = levelData[Gparent]["repell"]
								if levelData[Gparent]["gravityForce"] ~= nil then
									params["maxForce"] = levelData[Gparent]["gravityForce"]
								end
								createJoint(Gparent,"gravitational",key,Gparent,params)
							end
							value["gravityControl"][Gparent] = nil
						end
					end
				end
				--check if any forces must be applied
				if value["force_times"] and value["force_angle"] then
					if tonumber(value["force_times"]) ~= 0 then
						local force
						if tonumber(value["force_times"]) > 0 then
							value["force_times"] = value["force_times"] - 1
						end
						if value["force"] and tonumber(value["force"]) > 0 then
							force = value["force"]*value["image"].width
							local angle = math.rad(value["force_angle"]+value["image"].rotation)
							value["image"]:applyForce(force*math.cos(angle),force*math.sin(angle),value["image"].x,value["image"].y)
						end
						if value["impulse"] and tonumber(value["impulse"]) > 0 then
							local angle = math.rad(value["force_angle"]+value["image"].rotation)
							force = value["impulse"]*value["image"].width
							value["image"]:applyLinearImpulse(force*math.cos(angle),force*math.sin(angle),value["image"].x,value["image"].y)
						end
						-- adjust angle of force for the next appliance so that the movement is orbital
						-- must have force_orbital set to true to make orbital force
						if value["force_orbital"]~= nil and value["joints"]  then
							local vx,vy = value["image"]:getLinearVelocity()
							if vx~= 0 and vy~=0 then
								value["force_angle"] = math.deg(math.atan2(vy,vx))
							end
						end
					end
				end
				--Action each enemy
				if key:find("enemy") and value["Alldeactivated"] == nil and playerCache then
					ActionEnemy(key)
				end
				-- check absorbing
				if value["absorbBy"] then
					local absorbCoef = 5
					local dampCoef = 0.96
					
					if(value["absorbBy"]:find("planet"))then
						absorbCoef = 1;
						--dampCoef = 0.08
					end
					
					value["image"]:setLinearVelocity(0,0)
					value["deactivated"] = true
					local difx = value["image"].x - levelData[value["absorbBy"]]["image"].x
					local dify = value["image"].y - levelData[value["absorbBy"]]["image"].y
					local angle = math.atan2(dify,difx)
					local angle = angle + math.rad(absorbCoef)
					local radius = math.sqrt(difx^2 + dify^2)
					local oldWidth = value["image"].width
					value["image"].width = value["image"].width * dampCoef
					value["image"].height = value["image"].height * dampCoef
				    radius = (radius * value["image"].width)/oldWidth
					if(value["absorbBy"]:find("planet"))then
						radius = (value["image"].width+levelData[value["absorbBy"]]["image"].width)/2*dampCoef
					end
					value["image"].x = levelData[value["absorbBy"]]["image"].x + radius * math.cos(angle)
					value["image"].y = levelData[value["absorbBy"]]["image"].y + radius * math.sin(angle)
					if( value["image"].width < 2 or value["image"].height < 2 ) then
						if key:find("ast") then
							if playerCache["joinWith"] == value then -- if player is attached while asteroid is sucked
								DetachPlayer()
								-- add coding to the engine to push the player inside the home
								instructions["timedOperation#PushToFinish"] = {}
								instructions["timedOperation#PushToFinish"]["nrExecutions"] = -1
								instructions["timedOperation#PushToFinish"]["period"] = 1
								instructions["timedOperation#PushToFinish"]["codePointer"] = 1
								instructions["timedOperation#PushToFinish"]["code"] ={'follow>exit>player>"1";'}
								-- 
							end
						end
						if key:find("player") then
							if value["absorbBy"]:find("exit") then
								GameEndReason = "Finished!" 
							else
								if value["absorbBy"]:find("planet") then
									GameEndReason = "Crashed!";
								else
									GameEndReason = "Absorbed into nothingness!"
								end
							end
							print("Absorbtion ended the game!")
							EndGame()
							return
						else
							print("removing absorbed item")
							value["toRemove"] = true
						end
					end
				end
				-- check who gets deleted 
				-- !!! KEEP THIS THE LAST IF IN THE FOR OTHERWISE PROBLEMS ARISE IF OBJECT IS DELETED AND ATTEMPTS TO ACCES IT ARE MADE AFTERWARDS
				if value then
					if value["toRemove"] then
						print("REMV:",playerCache["joinWith"], value)
						if( playerCache["detached"] == false and playerCache["joinWith"] == value ) then
							DetachPlayer()
						end
						removeObject(key,false)
					end
				end
			end
		end
	end
	local END = system.getTimer()
	DebugLabel.text = "Core Updater Time:"..(END - start)
	-- end of core updater
end
---------------------------------------------------------------------------
-- STORYBOARD NAVIGATION SYSTEM
---------------------------------------------------------------------------
-- Called when the scene's view does not exist:
function onBackBtnPress()
	GameEndReason = "quit"
	--UnFreezeGame()
	EndGame()
	return true
end
function onPlayBtnPress()
	UnFreezeGame()
	TriggerPauseMenu()
	return true
end
function onRetryBtnPress()
	TriggerPauseMenu()
	GameEndReason = "retry"
	--UnFreezeGame()
	EndGame()
	return true
end
--------------------------------------------------------------------------
-- GAME CREATE CLEAN SYSTEM
--------------------------------------------------------------------------
function ExitStageUponAnimation(e)
	if(e.phase == "ended") then
		removeObject(e.target.name)
		storyboard.gotoScene(GoToWhatScene,"fade",fdspd)
		--storyboard.removeScene("engine")
	end
end
function AddListeners()
	playerImage:addEventListener("collision",PlayerCollision)
	for key,value in pairs(levelData) do
		if value["owns"] and value["owns"]["field"] then
			value["owns"]["field"]["image"]:addEventListener("collision",value["owns"]["field"]["image"])
		end
		if key:find("ast") or key:find("boo") then
			value["image"]:addEventListener("touch",HandleAsteroTap)
		end
	end
end
function ClearListeners()
	playerImage:removeEventListener("collision",PlayerCollision)
	for key,value in pairs(levelData) do
		if value["owns"] and value["owns"]["field"] then
			value["owns"]["field"]["image"]:removeEventListener("collision",value["owns"]["field"]["image"])
		end
		if key:find("ast") or key:find("boo") then
			value["image"]:removeEventListener("touch",HandleAsteroTap)
		end
	end
end

function backToMenu()
	GameEndReason = "quit"
	return true
end
function DeleteCapturerAndPrey()
	print("DELETIG CAPTURER AND PREY")
	if Capturer then
		removeObject(Capturer)
	end
	SwitchAnimation("player","null")
	playerImage.alpha = 0
end
function EndGame()
	if(GameEnded == true) then
		return
	end
	GameEnded = true
	print("Game ending...")
	TelekinesisUnHook()
	UnhookAllEnemies()
	FreezeGame()
	ClearStatusBarListeners()
	ClearListeners()
	removeAllJoints()
	Runtime:removeEventListener("enterFrame",frameEnter)
	print("Game Ended:",GameEndReason)
	DebugLabel.text = "GameEndReason:"..GameEndReason;
	local prev_NXT_state = NO_NEXT
	NO_NEXT = true
	local endAnimCache = nil
	if GameEndReason == "Got captured!" then
		--animate catch
		timer.performWithDelay(20,DeleteCapturerAndPrey,1)
		
		local scaleX = (playerImage.width+levelData[Capturer]["image"].width)*2.5/200
		local scaleY = (playerImage.height+levelData[Capturer]["image"].height)*2.5/200
		EndAnimation = "endAnim:magicDust"
		endAnimCache = playerCache["Nowns"][EndAnimation]["image"]
		endAnimCache:scale(scaleX,scaleY)
		--endAnimCache.width = (playerImage.width+levelData[Capturer]["image"].width)*2.5
		--endAnimCache.height = (playerImage.height+levelData[Capturer]["image"].height)*2.5
		endAnimCache.x = (playerImage.x+levelData[Capturer]["image"].x)/2
		endAnimCache.y = (playerImage.y+levelData[Capturer]["image"].y)/2
		showAnimation("player",EndAnimation)
		GoToWhatScene = "endinganimator"
	end
	if GameEndReason == "Stranded in space!" then
		--animate stranded
		GoToWhatScene = "endinganimator"
	end
	if GameEndReason == "Absorbed into nothingness!" then
		--animate sucked
		GoToWhatScene = "endinganimator"
	end
	if GameEndReason == "Crashed!" then
		--animate crushed
		--[[EndAnimation = "crash"
		timer.performWithDelay(50,DeleteCapturerAndPrey,1)
		playerCache["end_anim"]["crash"].width = playerImage.width
		playerCache["end_anim"]["crash"].width = playerImage.height
		playerCache["end_anim"]["crash"].x = playerImage.x
		playerCache["end_anim"]["crash"].y = playerImage.y
		playerCache["end_anim"]["crash"].rotation = playerImage.rotation
		playerCache["end_anim"]["crash"].isVisible = true
		playerCache["end_anim"]["crash"]:play()
		playerCache["end_anim"]["crash"]:addEventListener("sprite",ExitStageUponAnimation)
		]]--
		GoToWhatScene = "endinganimator"
	end
	if GameEndReason == "Finished!" then
		NO_NEXT = prev_NXT_state
		--animate won
		GoToWhatScene = "endinganimator"
	end
	if GameEndReason == "quit" then
		storyboard.removeScene("engine")
		GoToWhatScene = BEFORE_ENGINE_SCENE
	end
	if GameEndReason == "retry" then
		GoToWhatScene = "reset"
	end
	if EndAnimation == nil then
		print("Going to end Scene... selector:",selector)
		DebugLabel.text = "Moving to the next frame:"..GoToWhatScene
		storyboard.gotoScene(GoToWhatScene,"fade",fdspd)
		--storyboard.removeScene("engine")
	end
end

ClearExitAnimation = function(e)
	if e.phase == "ended" then
		print("ENDED ANIMATION:",e.target.name)
		removeObject(e.target.name,false)
	end
end

local function setupScene()
	InitEngine()
	
	local sizeCoef = 0.1
	print("creating scene")
	if ENG_RLD == nil then
		group:insert(background)
	end
	
	LoadLevel(ENG_RLD);
	initCamera()
	AddListeners()
	
	if ENG_RLD == nil then
		
	lastx = playerImage.x
	lasty = playerImage.y
	-- setup the player animation for the telekinesis rope
	local PlayerTeleLink = attachAnimation("player","telelink",{"telelink.png",
	{ width=1024, height=64, numFrames=8, sheetContentWidth=1024, sheetContentHeight=512 },
	{name = "normalRun", start=1, count=8, time=800},
	{initialVisibility = false,no_rel = true}});
	group:insert(PlayerTeleLink)
	
	-- load enemy animations
	for key,value in pairs(levelData) do
		if(key:find("enemy") and value["actionType"] == "dragger") then -- for all tele draggers add animation
			local EnemyTeleLink = attachAnimation("player",key,{"telelink.png",
			{ width=1024, height=64, numFrames=8, sheetContentWidth=1024, sheetContentHeight=512 },
			{name = "normalRun", start=1, count=8, time=800},
			{initialVisibility = false,no_rel = true}});
			group:insert(EnemyTeleLink)
		end
	end
	
	--debug
	DebugLabel = display.newText("Debug",0,0,native.systemFont,30)
	DebugLabel:setTextColor(255,255,255)
	DebugLabel.x = display.contentWidth*0.1
	DebugLabel.y = display.contentHeight/2
	
	-- do this smartly
	for key,val in pairs(levelData) do
		if val["image"] then
			val["image"]:toFront()
		end
	end
	for key,val in pairs(levelData) do
		if key:find("tutorial") and val["image"] then
			val["image"]:toFront()
		end
	end
	
	playerImage:toFront()
	playerImage.alpah = 0
	playerCache["fallBackAnimation"] = "player";
	
	local pa1 = attachAnimation("player","player",{"player.png",
	{ width=107, height=127, numFrames=1, sheetContentWidth=107, sheetContentHeight=127},
	{name = "normalRun", start=1, count=1, time=200,loopDirection = "forward"},
	{initialVisibility = false,direct_rel = true},{}});
	
	local pa2 =attachAnimation("player","PlayerStandingTele",{"PlayerStandingTele.png",
	{ width=107, height=127, numFrames=4, sheetContentWidth=107, sheetContentHeight=509}, 
	{ name = "normalRun", start=1, count=4, time=200,loopCount = 3},
	{initialVisibility=false,direct_rel=true},{listen=true}},SwitchAnimBack);
	
	local pa3 = attachAnimation("player","PlayerFlyingTele",{"PlayerStandingTele.png",
	{ width=107, height=127, numFrames=4, sheetContentWidth=107, sheetContentHeight=509}, 
	{name = "normalRun", start=1, count=4, time=200},
	{initialVisibility=false,direct_rel=true}});
	
	local pa4 =attachAnimation("player","PlayerFlying",{"PlayerFlyAnimation.png",
	{ width=107, height=127, numFrames=4, sheetContentWidth=107, sheetContentHeight=509}, 
	{name = "normalRun", start=1, count=4, time=200},
	{initialVisibility=false,direct_rel=true}});
	
	local pa5 = attachAnimation("player","PlayerStanding",{"PlayerStandingAnimation.png",
	{ width=107, height=127, numFrames=4, sheetContentWidth=107, sheetContentHeight=509}, 
	{name = "normalRun", start=1, count=4, time=200,loopDirection = "bounce",loopCount = 1},
	{initialVisibility=false,direct_rel=true},{listen=true}},SwitchAnimBack);
	
	playerCache["periodicAnimation"] = {}
	playerCache["periodicAnimation"]["anims"] = {"blink","wink","wave"}
	playerCache["periodicAnimation"]["period"] = 180
	playerCache["periodicAnimation"]["randomize"] = 1000
	playerCache["periodicAnimation"]["jumpTo"] = 3
	
	local ipa1 = attachAnimation("player","blink",{"PlayerStandingAnimation.png",
	{ width=107, height=127, numFrames=4, sheetContentWidth=107, sheetContentHeight=509}, 
	{name = "normalRun", start=1, count=4, time=200,loopDirection = "bounce",loopCount = 1},
	{initialVisibility=false,direct_rel=true},{listen=true}},SwitchAnimBack);
	
	local ipa2 = attachAnimation("player","wink",{"PlayerStandingAnimation.png",
	{ width=107, height=127, numFrames=4, sheetContentWidth=107, sheetContentHeight=509}, 
	{name = "normalRun", start=1, count=4, time=200,loopDirection = "bounce",loopCount = 1},
	{initialVisibility=false,direct_rel=true},{listen=true}},SwitchAnimBack);
	
	local ipa3 = attachAnimation("player","wave",{"PlayerStandingAnimation.png",
	{ width=107, height=127, numFrames=4, sheetContentWidth=107, sheetContentHeight=509}, 
	{name = "normalRun", start=1, count=4, time=200,loopDirection = "bounce",loopCount = 1},
	{initialVisibility=false,direct_rel=true},{listen=true}},SwitchAnimBack);
	
	--ending animations
	local ea1 = attachAnimation("player","endAnim:magicDust",{"magicDust.png",
	{ width=250, height=128, numFrames=12, sheetContentWidth=768, sheetContentHeight=512 }, 
	{name = "normalRun", start=1, count=12, time=300,loopCount = 1},
	{initialVisibility=false,no_rel=true},{listen = true}},ExitStageUponAnimation);
	
	local ea2 = attachAnimation("player","endAnim:crushed",{"crushedAnimation.png",
	{ width=50, height=50, numFrames=4, sheetContentWidth=50, sheetContentHeight=50*4 }, 
	{name = "normalRun", start=1, count=4, time=100,loopCount = 1},
	{initialVisibility=false,no_rel=true},{listen = true}},ExitStageUponAnimation);
	
	group:insert(pa1)
	group:insert(pa2)
	group:insert(pa3)
	group:insert(pa4)
	group:insert(pa5)
	
	group:insert(ipa1)
	group:insert(ipa2)
	group:insert(ipa3)
	CreatePauseMenu()
	-- debug
	levelData["starTrinket1"] = {}
	levelData["starTrinket1"]["x"] = display.contentWidth/10
	levelData["starTrinket1"]["y"] = display.contentWidth/2
	levelData["starTrinket1"]["width"] = 50
	levelData["starTrinket1"]["height"] = 50
	
	levelData["goldTrinket1"] = {}
	levelData["goldTrinket1"]["x"] = display.contentWidth/2
	levelData["goldTrinket1"]["y"] = display.contentWidth/2
	levelData["goldTrinket1"]["width"] = 50
	levelData["goldTrinket1"]["height"] = 50
	
	levelData["vacuumTrinket1"] = {}
	levelData["vacuumTrinket1"]["x"] = display.contentWidth/4
	levelData["vacuumTrinket1"]["y"] = display.contentWidth/4
	levelData["vacuumTrinket1"]["width"] = 50
	levelData["vacuumTrinket1"]["height"] = 50
	
	AddTrinket("starTrinket1")
	AddTrinket("goldTrinket1")
	AddTrinket("vacuumTrinket1")
	createStatusBar(ENG_RLD)
	
	nrFlames = 999 --debug
	nrVacums = 999 --debug
	nrGold = 9999   --debug
	setNrVacuums(nrVacums) -- debug
	setNrFlames(nrFlames) -- debug
	setNrGold(nrGold) -- debug
	local hat = display.newImage("hat.png") -- debug
	local props = { key = "hat",distance_rel = 1.2 , rotation_rel = -90, width_rel = 0.8, height_rel = 0.8, angle_rel = 1 } -- debug
	addToOwned("player",hat,true,props) -- debug
	group:insert(hat)-- debug
	--local mus = display.newImage("moustache.png") -- debug
	--local ratio = mus.height/mus.width 
	--local props2 = { key = "moustache",distance_rel = -0.3 , rotation_rel = -90, width_rel = 0.4, height_rel = 0.4*ratio, angle_rel = 1 } -- debug
	--addToOwned("player",mus,true,props2) -- debug
	
	group:insert(ea1)
	group:insert(ea2)
	end
	AddStatusBarListeners()
	cameraReady = true
	SwitchAnimation("player","player")
	initArrowSystem(ENG_RLD)
	if(playerImage.width/display.contentWidth > PLAYER_SIZE_COEFF )then
		zoomCamera(playerImage.width/display.contentWidth - PLAYER_SIZE_COEFF)
	end
	group:insert(DebugLabel)

	Runtime:addEventListener("enterFrame",frameEnter);

end
function scene:createScene( event )
	group = self.view
	levelData = {}
	instructions = {}
	jointBuffer = {}
	showLoad.init()
	showLoad.trigger(display.contentWidth/2,display.contentHeight/2)
	-- setup the on screen detector
	physics.addBody( background, "static" ,{ isSensor = true});
	background:addEventListener("collision",ManageOnScreenList);
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	-- setup the collision sensor that will direct what objects are updated
	
	--
	setupScene()
	local sizeCoef = 0.1
	showLoad.clear()
	pauseBtn = widget.newButton{
		defaultFile="pauseButton.png",
		overFile="pauseButton.png",
		width = display.contentWidth*sizeCoef, height = display.contentWidth*sizeCoef,
		onRelease = TriggerPauseMenu	-- event listener function
	}
	pauseBtn.x = pauseBtn.width/2
	pauseBtn.y = display.contentHeight - pauseBtn.width/2
	group:insert(pauseBtn)
	UnFreezeGame()
	Runtime:addEventListener("enterFrame",frameEnter)
	RUNTIME_LISTENER_ON = true
	physics.start()

	-- debug 
	--test_forces()	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	if levelData ~= nil then
		print("Exiting scene...")
		removeAnimations(false)
		ENG_RLD = true;
		pauseBtn:removeEventListener("tap",backToMenu)
		if RUNTIME_LISTENER_ON == true then
			Runtime:removeEventListener("enterFrame",frameEnter)
			RUNTIME_LISTENER_ON = false
		end
		physics.pause()
	end
end
-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	if RUNTIME_LISTENER_ON == true then
		Runtime:removeEventListener("enterFrame",frameEnter)
		RUNTIME_LISTENER_ON = false
	end
	background:removeEventListener("collision",ManageOnScreenList);
	print("Destroying scene...")
	ENG_RLD = nil;
	physics.stop()
	package.loaded[physics] = nil
	physics = nil

	--warning only lave this scene after it has been removed
	--storyboard.gotoScene(GoToWhatScene,"fade",fdspd)
end
---------------------------------------------------------------------------------------------
-- CODE EXECUTOR SYSTEM
---------------------------------------------------------------------------------------------
function ExecuteCode(key)
	--print("Executing code...")
	if instructions[key] then
			--made sure both objects exist
			local cp = instructions[key]["codePointer"]
			local jump = 0
			local cindex = 1
			print("executing instructions for:",key,instructions[key],instructions[key]["code"],instructions[key]["code"][cp])
			local code = instructions[key]["code"][cp]:sub(0,instructions[key]["code"][cp]:len()) 
			local allInstr = {}
			local args = {}
			local sep = 0
			local isep = 0
			while code:len() > 0 do
				sep = code:find('>')
				isep = code:find(',')
				if isep == nil then
					isep = code:len()
				end
				
				if sep then
					if sep <= isep then
						args[#args+1] = code:sub(0,sep-1)
						code = code:sub(sep+1,code:len())
					else
						args[#args+1] = code:sub(0,isep-1)
						code = code:sub(isep+1,code:len())
					end
				else
					if code:sub(isep,isep) == ";" or code:sub(isep,isep) == "," then --code:find(",") or code:find(";") then -- this may be optimized not to use find and use isep instead
						args[#args+1] = code:sub(0,code:len()-1)
					else
						args[#args+1] = code:sub(0,code:len())
					end
					code = "";
				end
				print("instruction component:",args[#args])
			
				if sep == nil or sep > isep then
					print("cindex",cindex,"alli",(#allInstr+1))
					if cindex == (#allInstr+1) then
						allInstr[cindex] = args
						print("executing...")
						local jump = Exec(args) -- args[1] = cmd / args[2 - ... ] the arguments
						print("Jump:",jump)
						cindex = cindex + jump
						if jump >= 0 then
							cindex = cindex + 1
						end
						args = {}
						if cindex < 0 then
							return
						end
					else
						allInstr[#allInstr+1] = args
						print("skipped...")
					end
				end
			end
		args = nil
		allInstr = nil
	end
end

function MakeVariable(scope,name)
	local base = nil
	local token
	print("attempting to create variable",name,"at scope",scope)
	while scope:len() > 0 do
		local final = true
		local pos = scope:len()
		for i =1,scope:len() do
			if scope:sub(i,i) == "." then
				final = false
				pos = i
				break
			end
		end
		if final then
			pos = pos + 1
		end
		token = scope:sub(0,pos-1)
		scope = scope:sub(pos+1,scope:len())
		print("token",token)
		if base ~= nil then
			print ("not null base",base[token])
			if base[token] == nil then
				print("nesting token:",token)
				base[token] = {}
			end
			if not final then
				base = base[token]
			else
				break;
			end
		end
		if base == nil then
			print("looking for scope:",token,"len",token:len())
			base = levelData[token]
			if base == nil then
				print("could not find scope:",token,levelData[token])
				--base[token] = {}
				return false
			end
		end
	end
	
	if base[token] == nil then
		print("nesting token:",token)
		base[token] = {}
	end		
	if base[token][name] == nil then
		base[token][name] = "0"
		print("Creating variable",name,"at key",token,base[token],base[token][name])
	end
	return true;
end
function AccessVariable(path)
	if path:sub(1,1) == '"' then --this is a literal
		return {value = path:sub(2,path:len()-1)},"value"
	else
		local nester = nil
		local depth = 0;
		while path:len() > 0 do
			local final = true
			local pos = path:len()
			for i =1,path:len() do
				if path:sub(i,i) == "." then
					final = false
					pos = i
					break
				end
			end
			if final then
				pos = pos + 1
			end
			local token = path:sub(0,pos-1)
			path = path:sub(pos+1,path:len())
			if depth == 0 then
				if final then
					return levelData,token;
				end
				nester = levelData[token]
			else
				--print("reiterate:",path)
				if final then
					--print("Returning at this point:",nester,token,nester[token])
					return nester,token;
				else
					nester = nester[token]
				end
			end
			if nester == nil then
				return nil;
			end
			depth = depth + 1
		end
	end
end
function Exec(args) -- refactor to accomodate acces to any variable
	if args[1] == "def" and #args==3 then -- not working
		--           scope  / variable name
		MakeVariable(args[2],args[3])
	end
	if args[1] == "set" and #args==3 then -- checked
		local pointer,k = AccessVariable(args[2])
		if pointer and k then
			pointer[k] = args[3]
		end
	end
	if args[1] == "add" and #args==4 then -- checked 
		local ptr1,k1 = AccessVariable(args[2])
		local ptr2,k2 = AccessVariable(args[3])
		local ptr3,k3 = AccessVariable(args[4])
		if ptr1 == nil or ptr2 == nil or ptr3 == nil or ptr1[k1] == nil or ptr2[k2] == nil or ptr3[k3] == nil then
			print("add ACCESS ERROR:",ptr1,k1,ptr2,k3,ptr3,k3)
			return 0
		end
		ptr1[k1] = tonumber(ptr2[k2]) + tonumber(ptr3[k3])
	end
	if args[1] == "sub" and #args==4 then -- checked
		local ptr1,k1 = AccessVariable(args[2])
		local ptr2,k2 = AccessVariable(args[3])
		local ptr3,k3 = AccessVariable(args[4])
		if ptr1 == nil or ptr2 == nil or ptr3 == nil or ptr1[k1] == nil or ptr2[k2] == nil or ptr3[k3] == nil then
			print("sub ACCESS ERROR:",ptr1,k1,ptr2,k3,ptr3,k3)
			print("sub:",ptr1[k1],ptr2[k2],ptr3[k3])
			return 0
		end
		print("sub:",ptr1[k1],ptr2[k2],ptr3[k3])
		ptr1[k1] = tonumber(ptr2[k2]) - tonumber(ptr3[k3])
	end
	if args[1] == "mul" and #args==4 then -- checked
		local ptr1,k1 = AccessVariable(args[2])
		local ptr2,k2 = AccessVariable(args[3])
		local ptr3,k3 = AccessVariable(args[4])
		if ptr1 == nil or ptr2 == nil or ptr3 == nil or ptr1[k1] == nil or ptr2[k2] == nil or ptr3[k3] == nil then
			print("mul ACCESS ERROR:",ptr1,k1,ptr2,k3,ptr3,k3)
			print("sub:",ptr1[k1],ptr2[k2],ptr3[k3])
			return 0
		end
		ptr1[k1] = tonumber(ptr2[k2]) * tonumber(ptr3[k3])
	end
	if args[1] == "div" and #args==4 then -- checked
		local ptr1,k1 = AccessVariable(args[2])
		local ptr2,k2 = AccessVariable(args[3])
		local ptr3,k3 = AccessVariable(args[4])
		if ptr1 == nil or ptr2 == nil or ptr3 == nil or ptr1[k1] == nil or ptr2[k2] == nil or ptr3[k3] == nil then
			print("div ACCESS ERROR:",ptr1,k1,ptr2,k3,ptr3,k3)
			return 0
		end

		if ptr3[k3] ~= 0 then
			ptr1[k1] = tonumber(ptr2[k2]) / tonumber(ptr3[k3])
		else
			print("Exec error:DIVISION BY ZERO!")
		end
	end
	if args[1] == "mod" and #args==4 then -- checked 
		local ptr1,k1 = AccessVariable(args[2])
		local ptr2,k2 = AccessVariable(args[3])
		local ptr3,k3 = AccessVariable(args[4])
		if ptr1 == nil or ptr2 == nil or ptr3 == nil or ptr1[k1] == nil or ptr2[k2] == nil or ptr3[k3] == nil then
			print("mod ACCESS ERROR:",ptr1[k1],ptr2[k2],ptr3[k3])
			return 0
		end
		ptr1[k1] = tonumber(ptr2[k2]) % tonumber(ptr3[k3])
	end
	if args[1] == "pwr" and #args==4 then -- checked
		local ptr1,k1 = AccessVariable(args[2])
		local ptr2,k2 = AccessVariable(args[3])
		local ptr3,k3 = AccessVariable(args[4])
		if ptr1 == nil or ptr2 == nil or ptr3 == nil or ptr1[k1] == nil or ptr2[k2] == nil or ptr3[k3] == nil then
			print("pwr ACCESS ERROR:",ptr1[k1],ptr2[k2],ptr3[k3])
			return 0
		end
		ptr1[k1] = tonumber(ptr2[k2]) ^ tonumber(ptr3[k3])
	end
	if args[1] == "sqrt" and #args==3 then -- dubious behaviour, todo fix
		local ptr1,k1 = AccessVariable(args[2])
		local ptr2,k2 = AccessVariable(args[3])
		if ptr1 == nil or ptr2 == nil or ptr1[k1] == nil or ptr2[k2] == nil then
			print("sqrt ACCESS ERROR:",ptr1[k1],ptr2[k2])
			return 0
		end
		if tonumber(ptr2[k2]) < 0 then
			return 0
		end
		ptr1[k1] = math.sqrt(tonumber(ptr2[k2]))
	end
	-- complex instructions ( almost like CISC )
	if args[1] == "SetVelocity" and #args==4 then -- checked SetVelocity / target / vx / vy
		local ptr1,k1 = AccessVariable(args[2])
		local ptr2,k2 = AccessVariable(args[3])
		local ptr3,k3 = AccessVariable(args[4])
		if ptr1 == nil or ptr2 == nil or ptr3 == nil or ptr1[k1] == nil or ptr2[k2] == nil or ptr3[k3] == nil then
			print("SetVelocity ACCESS ERROR:",ptr1,ptr2,ptr3)
			return 0
		end
		ptr1[k1]["image"]:setLinearVelocity(tonumber(ptr2[k2]),tonumber(ptr3[k3]))
	end
	if args[1] == "follow" then
		local followed,kd = AccessVariable(args[2])
		local follower,kr = AccessVariable(args[3])
		local speed,ks = AccessVariable(args[4])
		if follower and followed and speed and followed[kd] and follower[kr] and speed[ks] then
			follower = follower[kr]["image"];
			followed = followed[kd]["image"];
			speed = speed[ks]
			speed = follower.width * speed
			local angle = math.atan2(followed.y - follower.y,followed.x - follower.x)
			follower:applyForce(speed*math.cos(angle),speed*math.sin(angle),follower.x,follower.y)
		end		
	end
	if args[1] == "followPlayer" then -- checked followPlayer / force / list of followers
		local force,kf = AccessVariable(args[2])
		for i = 3,#args do
			local ptr,k = AccessVariable(args[i])
			local angle = math.atan2(playerImage.y-ptr[k]["image"].y,playerImage.x-ptr[k]["image"].x)  
			local FRS = ptr[k]["image"].width * force[kf]
			print("following player",force[kf])
			ptr[k]["image"]:applyForce(force[kf]*math.cos(angle),force[kf]*math.sin(angle),ptr[k]["image"].x,ptr[k]["image"].y)
		end
	end
	--more operations to come
	--essential flow control instructions
	if args[1] == "isGreater" and #args==4 then
		local ptr1,k1 = AccessVariable(args[2]);
		local ptr2,k2 = AccessVariable(args[3]);
		local ptr3,k3 = AccessVariable(args[4]);
		if ptr1 == nil or ptr2 == nil or ptr3 == nil or ptr1[k1] == nil or ptr2[k2] == nil or ptr3[k3] == nil then
			print("isGreater ACCESS ERROR:",ptr1,ptr2,ptr3)
			return 0
		end
		ptr1[k1] = (tonumber(ptr2[k2]) > tonumber(ptr3[k3]))
		print("is",tonumber(ptr2[k2]),"greater than",tonumber(ptr3[k3]),":",ptr1[k1])
	end
	if args[1] == "isSmaller" and #args==4 then
		local ptr1,k1 = AccessVariable(args[2]);
		local ptr2,k2 = AccessVariable(args[3]);
		local ptr3,k3 = AccessVariable(args[4]);
		if ptr1 == nil or ptr2 == nil or ptr3 == nil or ptr1[k1] == nil or ptr2[k2] == nil or ptr3[k3] == nil then
			print("isSmaller ACCESS ERROR:",ptr1,ptr2,ptr3)
			return 0
		end
		ptr1[k1] = (tonumber(ptr2[k2]) < tonumber(ptr3[k3]))
	end
	if args[1] == "isEqual" and #args==4 then
		local ptr1,k1 = AccessVariable(args[2]);
		local ptr2,k2 = AccessVariable(args[3]);
		local ptr3,k3 = AccessVariable(args[4]);
		if ptr1 == nil or ptr2 == nil or ptr3 == nil or ptr1[k1] == nil or ptr2[k2] == nil or ptr3[k3] == nil then
			print("isEqual ACCESS ERROR:",ptr1,ptr2,ptr3)
			return 0
		end
		ptr1[k1] = (ptr2[k2] == ptr3[k3])
	end
	if args[1] == "not" and #args==3 then -- checked
		local ptr1,k1 = AccessVariable(args[2]);
		local ptr2,k2 = AccessVariable(args[3]);
		if ptr1 == nil or ptr2 == nil or ptr1[k1] == nil or ptr2[k2] == nil then
			print("not ACCESS ERROR:",ptr1,ptr2)
			return 0
		end
		if type(ptr2[k2]) ~= "boolean" then
			print("ERROR:Can't invert a non boolean data type")
			return 0
		end
		ptr1[k1] = not ptr2[k2] 
	end
	if args[1] == "and" and #args==4 then
		local ptr1,k1 = AccessVariable(args[2]);
		local ptr2,k2 = AccessVariable(args[3]);
		local ptr3,k3 = AccessVariable(args[4]);
		if ptr1 == nil or ptr2 == nil or ptr3 == nil or ptr1[k1] == nil or ptr2[k2] == nil or ptr3[k3] == nil then
			print("and ACCESS ERROR:",ptr1,ptr2,ptr3)
			return 0
		end
		ptr1[k1] = (tonumber(ptr2[k2]) and tonumber(ptr3[k3]))
	end
	if args[1] == "or" and #args==4 then
		local ptr1,k1 = AccessVariable(args[2]);
		local ptr2,k2 = AccessVariable(args[3]);
		local ptr3,k3 = AccessVariable(args[4]);
		if ptr1 == nil or ptr2 == nil or ptr3 == nil or ptr1[k1] == nil or ptr2[k2] == nil or ptr3[k3] == nil then
			print("or ACCESS ERROR:",ptr1,ptr2,ptr3)
			return 0
		end
		ptr1[k1] = (tonumber(ptr2[k2]) and tonumber(ptr3[k3]))
	end
	if args[1] == "jumpTrue" and #args==3 then
		local check,k = AccessVariable(args[2]);
		print("jumpt",check,k,check[k])
		if check and k and type (check[k]) == "boolean" and check[k] == true  then
			local val,key = AccessVariable(args[3]);
			if key and val and val[key] then
				return tonumber(val[key]);
			end
		end
	end
	if args[1] == "jumpFalse" and #args==3 then -- checked
		local check,k = AccessVariable(args[2]);
		if check and k and type (check[k]) == "boolean" and check[k] == false then
			local val,key = AccessVariable(args[3]);
			if key and val and val[key] then
				print("jump am",val[key]);
				return tonumber(val[key]);
			end
		end
	end
	return 0;
end
-------------------------------------------------------
-------------------------- debug functions
------------------------------------------------------

function test_forces()
	for key,value in pairs(levelData) do
		if value["image"].getLinearVelocity ~= nil then
		local vx,vy = value["image"]:getLinearVelocity()
		local range = math.sqrt(vx^2+vy^2)
		local angle = math.atan2(vy,vx)
		local force = display.newImage("2px.png")
		force.anchorX = 0.0
		force.anchorY = 0.0
	
		force.rotation = math.deg(angle)
		print("adding force to",key)
		addToOwned(key,force,false,{key = "force",no_xy_rel=true,height_rel = 0.02})
		group:insert(force)
		end
	end
end
function update_forces()
		for key,value in pairs(levelData) do
			if value["image"].isVisible == true and value["owns"]["force"] then
				if value["image"].getLinearVelocity ~= nil then
				local vx,vy = value["image"]:getLinearVelocity()
				local range = math.sqrt(vx^2+vy^2)
				local angle = math.atan2(vy,vx)
				value["owns"]["force"]["image"].x = value["image"].x + range*math.cos(angle)/2
				value["owns"]["force"]["image"].y = value["image"].y + range*math.sin(angle)/2
				value["owns"]["force"]["image"].width = range
				value["owns"]["force"]["image"].rotation = math.deg(angle) 
				value["owns"]["force"]["image"]:toFront()
				end
			end
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