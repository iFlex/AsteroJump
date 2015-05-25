--ldz
-----------------------------------------------------------------------------------------
-- LEVEL DESIGNER
-- warning global CurrentLevel is used to try and preload an existing level into the designer
-- leave it empty for empty file
-----------------------------------------------------------------------------------------
-- le essential storyboard
local storyboard = require( "storyboard" )
local widget = require "widget"
local lfs    = require "lfs"
local showLoad = require("loadScreen")
local grid = require("gridView")
require "system"
system.activate( "multitouch" )

-----------------------------------------------------------------------------------------
local scene = storyboard.newScene()
local group
local zoomFactor = 1.0
-- essential engine vars
print("Game engine starts...")
local TickCount = 0
local levelData = nil;
levelData = {}
local instructions = {}
local vectors = {}
local joints = {}
-----------------------
local RemoveOnce = false
local ZoomRecover = false
-- include Corona's "physics" library
local physics = require "physics"
local TouchMode = "edit"
local AddInType = "enemy"
-- setup the physics
physics.start()
physics.pause()
physics.setGravity(0,0)
--physics.setDrawMode("hybrid")
--------------------------------------------
-- forward declarations and other locals
local ROTATION_AMPLIFYER = 2
local ZOOM_AMPLIFYER = 1

local ObjIndex   = 0
local EnemyIndex = 0
local background 
local stageH	=	display.contentHeight*0.15
local imgDim    =   display.contentWidth/5
local cameraReady = false
local amZooming = false
local changed = false
local exitAfterSave = false
-- object configuration controls
local scrn
local sup
local sdn
local fup
local fdn
local btype
local fieldDir
local slabel
local flabel
local configG = display.newGroup()
-- 
local Fpath
local levelName = "default.lvl"
local stg
local saveBtn
local deleteBtn
local ast
local enemy
local edmoveBtn = nil
local backBtn
local bselector
local classUp
local classDn 
local stageG = display.newGroup()

local selector = nil

local ClassIndex = 1
local SubclassIndex = 1
local ClassNames = {"ast","vortex","planet","starTrinket","flameTrinket","vacuumTrinket"}
local Classes = {}

local EClassIndex = 1
local ESubclassIndex = 1
local EClassNames = {"enemyDumb","enemyEver","enemyTele"}
local EClasses = {}

local nameField;
local label;

local lastAngle = nil
local touches = {}
-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
local TelekinesisForce = display.contentHeight*10
-- MIKES ARROW CODE
local arrow = display.newImageRect(SELECTED_SKIN_PACK..'arrow_tip.png',SKIN_BASE_DIR,50,50)
local rect = display.newRect(0,0,15,15)
arrow.x = 0
arrow.y = 0
local arrow_srs
arrow:setFillColor(0, 0, 255)
arrow.isVisible = false

rect:setFillColor(0, 0, 255)
rect.isVisible = false
local last_x = 0
local last_y = 0
local arrow_len = 0
local function initialiseArrow(event)
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
local function endArrow(event)
	AllowArrow = false
	arrow.isVisible = false
	rect.width = 0.001 -- not possible with 0
	rect.isVisible = false
	if(arrow_srs.x == nil) then
		return 0
	end
	return arrow_len
end
local function moveArrow(x,y)
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
---------------------------------------END OF MIKE's ARROW CODE--------------------------------------------
require "io"
require "math"
local function PedestalToFront()
	stg:toFront()
	edmoveBtn:toFront()
	ast:toFront()
	enemy:toFront()
end
local function DistTo(a,b)
	return math.sqrt((a.x-b.x)^2 + (a.y-b.y)^2)
end
local function FindClosestAsteroid()
	local mindist = 2^30
	local dist = 0
	local retKey = nil 
	for key,value in pairs(levelData) do
		if key:find("ast") then
			dist = DistTo(levelData["player"]["image"],levelData[key]["image"])
			if mindist == 0 then
				mindist = dist
				retKey = key
			end
			if mindist > dist then
				mindist = dist
				retKey = key
			end
		end
	end
	print("found dist:",mindist)
	return retKey
end
local function removePhBodies( key )
	if levelData[key]["field"] then
		physics.removeBody(levelData[key]["field"])
	end
	physics.removeBody(levelData[key]["image"])
end
local function zoomCamera( coef )
	amZooming = true
	print("Attempting zoom...")
	if( levelData["player"] and coef ~= 0) then
	print("ZOOM: player is present")
	if( levelData["player"]["image"].width*coef > display.contentWidth*0.05 and levelData["player"]["image"].width*coef < display.contentWidth/3) then 
	print("ZOOM: dimensions acceptable for zoom")
	local distX = 0
	local distY = 0
	local angle = 0.0
	local radius = 0
	grid.prezoom(coef)
	
	zoomFactor = zoomFactor * coef
	if RemoveOnce then
		ClearForZoom()
		RemoveOnce = false
	end
	
	TelekinesisForce = TelekinesisForce * coef
	local oldW = 0
	--resize all objects
	for key,value in pairs(levelData) do
		oldW = levelData[key]["image"].width
		levelData[key]["image"].width = levelData[key]["image"].width * coef
		levelData[key]["image"].height = levelData[key]["image"].height * coef 
		if levelData[key]["radius"] then
			levelData[key]["radius"] = levelData[key]["radius"] * coef 
		end
		
		--if RemoveOnce then
		removePhBodies( key )
		--end
		-- deal with the position as well
		distX = levelData[key]["image"].x - background.x
		distY = levelData[key]["image"].y - background.y
		angle = math.atan2(distY,distX)
		radius = math.sqrt(distX^2+distY^2)
		
		radius = (radius * levelData[key]["image"].width) / oldW 
		levelData[key]["image"].x = background.x + radius*math.cos(angle) 
		levelData[key]["image"].y = background.y + radius*math.sin(angle)
		-- add physics back
		
		if levelData[key]["field"] then
			print("has field:",levelData[key]["field"])
			levelData[key]["field"].width = levelData[key]["field"].width * coef
			levelData[key]["field"].height = levelData[key]["field"].width
			levelData[key]["field"].x = levelData[key]["image"].x
			levelData[key]["field"].y = levelData[key]["image"].y
		end
		if levelData[key]["jimages"] then
			for i = 1,#levelData[key]["jimages"] do
				levelData[key]["jimages"][i].width = levelData[key]["jimages"][i].width*coef
				levelData[key]["jimages"][i].height = levelData[key]["jimages"][i].height*coef
				
				distX = levelData[key]["jimages"][i].x - background.x
				distY = levelData[key]["jimages"][i].y - background.y
				angle = math.atan2(distY,distX)
				radius = math.sqrt(distX^2+distY^2)
				radius = (radius * coef)
				levelData[key]["jimages"][i].x = background.x + radius*math.cos(angle) 
				levelData[key]["jimages"][i].y = background.y + radius*math.sin(angle)
			end
		end
	end
	end
	end
	RemoveOnce = false
	print("DONE zooming!")
end
local function backToMenu()
	print("attempting to remove")
	if changed == false then
		storyboard.removeScene("levelDesignerNew")
		storyboard.gotoScene("menu","fade",fdspd)
	else
		exitAfterSave = true
		changed = false
		SaveLevelUnderName(event)
	end
end

local function SaveLevel()
	zoomCamera( 1/zoomFactor )
	local fh, reason;
	-- if player chose name
	if nameField.text:len() > 0 then
		levelName = nameField.text..".lvl"
	end
	-- save under that name
	if(levelName) then
		if Fpath:sub(#Fpath,#Fpath+1) ~= "/" then
			Fpath = Fpath.."/"
		end
		fh,reason = io.open( Fpath .. levelName, "w" )
		print("Saving unde name:",levelName);
		DebugLabel = display.newText(nameField.text.."("..nameField.text:len()..")NewFile/OVERW:"..Fpath .. levelName,0,0,display.contentWidth,display.contentHeight,native.systemFont,30)
	else
		fh,reason = io.open( CurrentLevel, "w" )
		print("Updating file:",CurrentLevel);
		DebugLabel = display.newText(nameField.text.."("..nameField.text:len()..")Update:"..CurrentLevel,0,0,display.contentWidth,display.contentHeight,native.systemFont,30)
	end
	
	DebugLabel:setTextColor(255,0,255)
	group:insert(DebugLabel)
	DebugLabel.x = display.contentWidth/2
	DebugLabel.y = display.contentHeight/2
	print("Saving level at:",path)
	levelData["player"]["startObj"] = FindClosestAsteroid()
	local jointIndex = 0;
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
					if key ~= "x" and key ~= "y" and key ~= "width" and key ~= "height" and key ~= "rotation" and key ~= "field" then
						if key ~= "jimages" and key ~= "joints" and key ~= "jointWith" and key ~= "nrJoints" and key ~= "jointPnr" and key ~= "jointParents" and key ~= "left" and key ~= "right" and key ~= "type" then   
							fh:write(key)
							fh:write("=")
							if(type(value) == "boolean") then
								if(value == true)then
									fh:write("true")
								else
									fh:write("false")
								end
							else
								fh:write(value)
							end
							fh:write("\n")
						end
					end
					if key:find("joints") then
						print(key2," is a paret of joints")
						for i = 1,#levelData[key2]["joints"] do
							local name = {"joint",jointIndex}
							name = table.concat(name)
							fh:write("{\n")
							fh:write(name)
							fh:write("\n")
							fh:write("left=")
							fh:write(key2)
							fh:write("\n")
							fh:write("right=")
							fh:write(levelData[key2]["jointWith"][i])
							fh:write("\n")
							fh:write("type=")
							fh:write(levelData[key2]["joints"][i][1])
							fh:write("\n}\n")
							jointIndex = jointIndex + 1
						end
					end
				end
			end
			fh:write("}\n")
		end
	else
		print( "Reason open failed: " .. reason )-- display failure message in terminal
		return true
	end
	io.close( fh )
	changed = false
	native.showAlert( "Level Designer", "Level Saved!" , { "OK" }  )
	if exitAfterSave then
		backToMenu()
	end
	return true
end
function SaveLevelUnderName(event)
	if( label.isVisible == true )then
		label.isVisible = false
		nameField.isVisible = false
		SaveLevel()
	else
		label.isVisible = true
		nameField.text = ""
		nameField.isVisible = true
	end
end
local function AddPhToBody(obj)
	print("reinstating body:",obj["image"].name)
	physics.addBody( obj["image"], "dynamic" ,{ density = 1, friction = 0, bounce = 0, radius = tonumber(obj["image"].width/2) } )
end
local function DestroyObject(obj)
	if obj then
		obj:removeSelf()
		obj = nil
	end
end
local function UnloadObjects()
	DestroyObject(background)
	for key,value in pairs(levelData) do
		levelData[key]=nil
	end
end
local function UpdateJoint(left,id)
	local other = levelData[left]["jointWith"][id]
	local dsx = levelData[other]["image"].x - levelData[left]["image"].x 
	local dsy = levelData[other]["image"].y - levelData[left]["image"].y
	local angle = math.atan2(dsy,dsx)
	local wii = math.sqrt(dsx^2+dsy^2)

	if levelData[left]["jimages"] == nil then
		levelData[left]["jimages"] = {}
	end
	if levelData[left]["jimages"][id] == nil then
		local wcoef = 0.25
		local hee = levelData[left]["image"].width*wcoef
		if levelData[other]["image"].width*wcoef < hee then
			hee = levelData[other]["image"].width*wcoef
		end
		print("creating joint image")
		levelData[left]["jimages"][id] = display.newRect(0,0,wii,hee)
		levelData[left]["jimages"][id].alpha = 0.3
		group:insert(levelData[left]["jimages"][id])
	end
	levelData[left]["jimages"][id].width = wii
	levelData[left]["jimages"][id].rotation = math.deg(angle)
	levelData[left]["jimages"][id].x = levelData[left]["image"].x+dsx/2 
	levelData[left]["jimages"][id].y = levelData[left]["image"].y+dsy/2
end
local function reinstatePhBodies( key )
	grid.redraw()
	for key,obj in pairs(levelData) do
		AddPhToBody(levelData[key])
		--print(key,"impulse:",levelData[key]["xvel"],levelData[key]["yvel"])
		levelData[key]["image"]:setLinearVelocity(levelData[key]["xvel"],levelData[key]["yvel"])
		levelData[key]["image"].angularVelocity =  levelData[key]["angleVel"];
		levelData[key]["xvel"] = nil
		levelData[key]["yvel"] = nil
	end
	-- reinstate tele hook
	if levelData["player"]["jointTarget"] then
		levelData["player"]["teleJoint"] = nil
		TelekinesisHook(levelData["player"]["jointTarget"])
	end
	-- reinstate enemy hook
	if levelData["player"]["enemy"] then
		levelData["player"]["enemyJoint"] = nil
		EnemyHook(levelData["player"]["enemy"])
	end
	-- reinstate player joint
	if levelData["player"]["joint"] then
		AttachPlayer(levelData["player"]["joinWith"],false)
	end
	
	for key,value in pairs(levelData) do
		if levelData[key]["field"] then
			physics.addBody( levelData[key]["field"], "static", { isSensor = true, radius = levelData[key]["field"].width/2 } )
		end
		-- all joints must be reinstated
		-- reinstate gravity pull if there is any
		if levelData[key]["image"].hasJoint then
			levelData[key]["image"].hasJoint = 1
		end
		-- reinstate custom joints if there are any
		if levelData[key]["joints"] then
			for i = 1,#levelData[key]["joints"] do
				local right = levelData[key]["jointWith"][i]
				if levelData[key]["joints"][i][1] == "elastic" then
					levelData[key]["joints"][i][2] = physics.newJoint(levelData[key]["joints"][i][1],levelData[key]["image"],levelData[right]["image"],levelData[key]["image"].x,levelData[key]["image"].y,levelData[right]["image"].x,levelData[right]["image"].y)
				elseif levelData[key]["joints"][i][1] == "pivot" then
					levelData[key]["joints"][i][2] = physics.newJoint(levelData[key]["joints"][i][1],levelData[key]["image"],levelData[right]["image"],levelData[key]["image"].x,levelData[key]["image"].y)
				end
				UpdateJoint(key,i)
			end
		end
	end
	ZoomRecover = true
end
local MAX_TAP_TOLERANCE = 5
local RemoveOnce = false
local TapNotValid = 0
local zXanchor = 0
local zYanchor = 0
local tangle = 0
local lastTarget = nil
function rotateCamera(da)
	print("Rotating by:",math.deg(da))
	local cx = display.contentWidth/2;
	local cy = display.contentHeight/2;
	for key,value in pairs(levelData) do
		if( levelData[key]["image"] and levelData[key]["image"].x ) then
			local dx=levelData[key]["image"].x-cx
			local dy=levelData[key]["image"].y-cy;
			radius = math.sqrt((dx)^2+(dy)^2)
			local cangle = math.atan2(dy,dx)+da
			levelData[key]["image"].x = cx + radius*math.cos(cangle)
			levelData[key]["image"].y = cy + radius*math.sin(cangle)
			--if levelData[key]["field"] then
			--	levelData[key]["field"].x = levelData[key]["image"].x
			--	levelData[key]["field"].y = levelData[key]["image"].y
			--end
		end
	end
end
local function moveCamera(ddx,ddy)
	grid.move(ddx,ddy)
	for key,value in pairs(levelData) do
		levelData[key]["image"].x = levelData[key]["image"].x + ddx
		levelData[key]["image"].y = levelData[key]["image"].y + ddy
		if levelData[key]["field"] then
			levelData[key]["field"].x = levelData[key]["image"].x
			levelData[key]["field"].y = levelData[key]["image"].y
		end
	end
end
local function AddObject(e)
	local key
	changed = true
	if(AddInType == "object")then
		key = {ClassNames[ClassIndex],ObjIndex}
		key = table.concat(key)
		--now copy all the keys into levelData and load object
		levelData[key] = {}
		print("Copying properties")
		for prop,value in pairs(Classes[ClassIndex][SubclassIndex]) do
			levelData[key][prop] = value
		end
		print("Done")
	else
		key = {EClassNames[EClassIndex],EnemyIndex}
		key = table.concat(key)
		--now copy all the keys into levelData and load object
		levelData[key] = {}
		print("Copying properties")
		for prop,value in pairs(EClasses[EClassIndex][ESubclassIndex]) do
			levelData[key][prop] = value
		end
		print("Done")
	end
	levelData[key]["x"] = e.x
	levelData[key]["y"] = e.y
	levelData[key]["width"] = stageH
	levelData[key]["height"] = stageH
	print("Loading obj")
	LoadObject(key,"only",key)
	print("Done")
	stageG:toFront()
	return true
end
local function TriggerSelection()
	scrn.isVisible = true
	scrn:toFront()
	levelData[Selector]["image"]:toFront()
	btype.text = levelData[Selector]["bodyType"]
	
	if levelData[Selector]["gravityForce"] then
		if tonumber(levelData[Selector]["gravityForce"]) > 0 then
			fieldDir.text = "repell"
		else
			fieldDir.text = "attract"
		end
	else
		fieldDir.text = ""
	end
	configG.isVisible = true
	configG:toFront()
end
local function DiscardSelection()
	if(Selector) then
		Selector = nil
		scrn.isVisible = false
		configG.isVisible = false
	end
end
local function UpdateVector(key)
	if vectors[key]["image"] then
		vectors[key]["image"].x = levelData[key]["image"].x
		vectors[key]["image"].y = levelData[key]["image"].y
		vectors[key]["image"].width = levelData[key]["image"].width * levelData[key]["force"]
		vectors[key]["image"].height = display.contentWidth*0.01
	end
end
local function RemoveForce(key)
	if(levelData[key]["image"] and levelData[key]["force"])then
		levelData[key]["force"] = nil 
		levelData[key]["force_angle"] = nil
		levelData[key]["force_times"] = nil
		if( vectors[key]["image"] ) then
			vectors[key]["image"]:removeSelf()
			vectors[key]["image"] = nil
			vectors[key] = nil
		end
	end
end
local function AddForce(key,length,angle)
	print("Attempting to add force to:",key,length,angle)
	if(levelData[key]["image"])then
		print("Adding force to",key)
		levelData[key]["force"] = length/levelData[key]["image"].width
		levelData[key]["force_angle"] = math.deg(angle)
		levelData[key]["force_times"] = -1
		if( vectors[key] == nil ) then
			vectors[key] = {}
		end
		if( vectors[key]["image"] ) then
			vectors[key]["image"]:removeSelf()
			vectors[key]["image"] = nil
		end
		
		vectors[key]["image"] = display.newRect(0,0,length,display.contentWidth*0.1)
		vectors[key]["image"]:setReferencePoint( display.CenterLeftReferencePoint )
		vectors[key]["image"].rotation = math.deg(angle)
		group:insert(vectors[key]["image"])
		UpdateVector(key)
	end
end
local function reAddForce(key)
	AddForce(key,levelData[key]["image"].width*tonumber(levelData[key]["force"]),math.rad(levelData[key]["force_angle"]))
end
local function Join(a,b)
	
	levelData["joint1"] = {}
	levelData["joint1"]["left"] = a
	levelData["joint1"]["right"] = b
	levelData["joint1"]["type"] = "pivot"
	LoadObject("joint1","only","joint")
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
function GetNRT()
	local nr = 0
	for key,value in pairs(touches) do
		nr = nr + 1
	end
	return nr
end
function IsRoot(event)
	if touches[event.id] and touches[event.id]["zoomRoot"] then
		return true
	end
	return false
end
function RegisterTouch(event)
	lastAnge = nil
	if( GetNRT()<3) then
		touches[event.id] = {}
		if( GetNRT() == 1 ) then
			touches[event.id]["zoomRoot"] = true
		end
		touches[event.id].x = event.x
		touches[event.id].y = event.y
		print("registering:",event.id,GetNRT())
		
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

function GetDist()
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
local function MoveTouch(e)
	TapNotValid = math.sqrt((zXanchor-e.x)^2+(zYanchor-e.y)^2)
	UpdateTouch(e)	
	if GetNRT() == 2 then
		-- rotate camera routine
		print("GETNRT",lastAngle,"e.id",e.id,GetNRT())
		if lastAngle == nil then
			lastAngle = getTouchAngle()
		else
			print("LAST ANGLE:",math.deg(lastAngle))
			local angleNow = getTouchAngle()
			if angleNow then
				rotateCamera((angleNow - lastAngle)*ROTATION_AMPLIFYER)
			end
			lastAngle = angleNow
		end
	else
	if lastTarget then
		if(TouchMode == "move") then
			e.target.x = e.x
			e.target.y = e.y
		else
			moveArrow(e.x,e.y)
		end
		tangle = math.atan2(e.y-lastTarget.y,e.x-lastTarget.x)
	else
		if TouchMode == "edit" then
			if AllowZoom then
				local dst = TapNotValid
				if zXanchor-e.x < 0 then 
					dst = -dst
				end
				if zXanchor-e.x == 0 then
					if(e.y-zYanchor)< 0 then
						dst = -dst
					end
				end
				dst = dst/(display.contentWidth/2)
				TapNotValid = MAX_TAP_TOLERANCE*10
				zoomCamera(1.0+dst)
				zXanchor = e.x
				zYanchor = e.y
			end
		else
			TapNotValid = MAX_TAP_TOLERANCE*10
			moveCamera(e.x-zXanchor,e.y-zYanchor);
			zXanchor = e.x
			zYanchor = e.y
		end
	end
	end
end
local AllowArrow = false;
local function HandleAsteroTap(e)
	print("HandleAsteroTap:",e.phase)
	DiscardSelection()
	if (e.phase == "began") then
		RegisterTouch(e)
		if amZooming then --the previous zoom has not ended
			reinstatePhBodies()
		end
		amZooming = false;
		AllowZoom = false;
		
		zXanchor = e.x;
		zYanchor = e.y;
		TapNotValid = 0
		lastTarget  = e.target
		if(TouchMode == "edit") then
			AllowArrow = true
			initialiseArrow(e)
		end
	end
	if (e.phase == "moved")then --and lastTarget) then
		MoveTouch(e)
	end
	if (e.phase == "ended") then
		UnRegisterTouch(e)
		if amZooming then
			AllowZoom = false
			reinstatePhBodies()
		end
		if TapNotValid < MAX_TAP_TOLERANCE then
			TapNotValid = 0
		end
		print("HAT Touch ended!",TapNotValid,lastTarget == e.target,(lastTarget == e.target and TapNotValid == 0))
		local force = 0;
		if(AllowArrow)then
			AllowArrow = false
			force = endArrow(e)
		end
		if(TouchMode == "edit")then
			if lastTarget then
				if( lastTarget ~= e.target)then --user has created a joint
					Join(lastTarget.name,e.target.name)
				elseif TapNotValid > 0 then--user has applied force
					RemoveForce(e.target.name)
				end
			end
		end
		if(lastTarget == e.target and TapNotValid == 0) then -- tapped 
			Selector = e.target.name
			TriggerSelection()
		end
		lastTarget = nil
	end
	return true -- unfortunately, this will not propogate down if false is returned
end
local function HandleGeneralTouch(e)-- this function is messed up! Needs fixing
	--print("HandleGeneralTouch")
	native.setKeyboardFocus( nil )
	DiscardSelection()
	if (e.phase == "began") then
		RegisterTouch(e)
		TapNotValid = 0
		AllowZoom  = true
		amZooming  = false
		RemoveOnce = true
		zXanchor   = e.x
		zYanchor   = e.y
		--print("HGT began")
	end
	if (e.phase == "moved") then
		--print("HGT moved")
		MoveTouch(e)
	end
	if (e.phase == "ended") then
		UnRegisterTouch(e)
		--impulse and tele
		if TapNotValid < MAX_TAP_TOLERANCE then
			TapNotValid = 0
		end
		--print("HGT ended",TapNotValid)
		local force = 0;
		if(AllowArrow)then
			AllowArrow = false
			force = endArrow(e)
		end
		-- drag originated in empty space
		if amZooming then
			reinstatePhBodies()
		end
		
		if lastTarget then
			AddForce(lastTarget.name,force,tangle)
		elseif TapNotValid == 0 then -- user has tapped
			AddObject(e)
		end
		lastTarget = nil
		AllowZoom  = false
		amZooming  = false
	end
	return true
end
local function DeleteJoint(left,id)
	if levelData[left] then
		if levelData[left]["jimages"] then
			if levelData[left]["jimages"][id] then
				levelData[left]["jimages"][id]:removeSelf()
				levelData[left]["jimages"][id] = nil
			end
		end
		if levelData[left]["joints"] then
			if levelData[left]["joints"][id] then
				levelData[left]["joints"][id][2]:removeSelf()
				levelData[left]["joints"][id] = nil
			end
		end
	end
end
local function AttachFieldToEnemy(key)
	levelData[key]["field"] = display.newCircle( 0, 0, levelData[key]["range"] * levelData[key]["image"].width/2 )
	levelData[key]["field"].alpha = 0.3
	levelData[key]["field"].x = levelData[key]["image"].x
	levelData[key]["field"].y = levelData[key]["image"].y
	group:insert(levelData[key]["field"])
end
function LoadObject(key,action,filter)
	if filter:len() > 0 then
		if (action == "only" and not key:find(filter)) or ( action == "exclude" and key:find(filter)) then
			print("Filtered load",key," filter",filter)
			return 
		end
	end
		print("Loading body",key)
		if(key:find("enemy"))then
			EnemyIndex = EnemyIndex+1
		else
			ObjIndex = ObjIndex+1
		end
		if levelData[key]["imgname"] then
			levelData[key]["image"] = display.newImageRect(SELECTED_SKIN_PACK..levelData[key]["imgname"],SKIN_BASE_DIR, tonumber(levelData[key]["width"]), tonumber(levelData[key]["height"]) )
			levelData[key]["image"].name = key
			levelData[key]["image"].x = tonumber(levelData[key]["x"])
			levelData[key]["image"].y = tonumber(levelData[key]["y"])
			levelData[key]["image"].rotation = tonumber(levelData[key]["rotation"])
			group:insert(levelData[key]["image"])
			print("Created image for",key," img:",levelData[key]["image"])
			local bodyType = "dynamic"
			if levelData[key]["bodyType"] then
				bodyType = levelData[key]["bodyType"]
				if levelData[key]["gravity"] and levelData[key]["bodyType"] == "static" then
					levelData[key]["field"] = display.newCircle( 0, 0, levelData[key]["gravity"] * levelData[key]["image"].width/2 )
					levelData[key]["field"].alpha = 0.3
					levelData[key]["field"].name  = key
					levelData[key]["field"].x = levelData[key]["image"].x
					levelData[key]["field"].y = levelData[key]["image"].y
					physics.addBody( levelData[key]["field"], "static", { isSensor = true, radius = levelData[key]["gravity"] * levelData[key]["image"].width/2 } )
					
					levelData[key]["field"].collision = GravityCollision
					group:insert(levelData[key]["field"])
				end
			else
				levelData[key]["bodyType"] = bodyType
			end
			if key:find("enemy") then
				if levelData[key]["actionType"] ~= "ever-charging" then
					AttachFieldToEnemy(key)
				end
			end
			if key:find("exit") then
				levelData[key]["absorb"] = true
			end
			AddPhToBody(levelData[key])
			if(levelData[key]["angleforce"] ~= nil) then
				levelData[key]["image"]:applyTorque( tonumber(levelData[key]["angleforce"]) )
			end
			--if key:find("ast") or key:find("boo") then
			levelData[key]["image"]:addEventListener("touch",HandleAsteroTap)
			--end
		end
		--unpack the code
		if key:find("timedOperation") then
			print("codebit detected:")
			local nr = 1
			local code = {}
			local nextSep = 0 
			while levelData[key]["code"]:len() > 0 do
				nextSep = levelData[key]["code"]:find(";")
				code[nr] = levelData[key]["code"]:sub(0,nextSep-1)
				levelData[key]["code"] = levelData[key]["code"]:sub(nextSep+1,levelData[key]["code"]:len())
				print("insruction",nr,code[nr])
				nr = nr + 1
			end
			instructions[key] = {}
			instructions[key] = levelData[key]
			instructions[key]["code"] = code
			levelData[key] = nil
			print("instr:",instructions[key]["code"][1])
		end
		if levelData[key]["force"] and levelData[key]["force_angle"] then
			reAddForce(key)
		end
		--------------------------------------
		if key:find("joint") then
			if levelData[key]["left"] and levelData[key]["right"] and levelData[key]["type"] then
				local left  = levelData[key]["left"]
				local right = levelData[key]["right"]
				if levelData[left]["joints"] == nil then
					levelData[left]["nrJoints"]  = 0
					levelData[left]["joints"]    = {}
					levelData[left]["jointWith"] = {}
				end
				if levelData[right]["jointParents"] == nil then
					levelData[right]["jointPnr"] = 0
					levelData[right]["jointParents"] = {}
				end
				if levelData[left] and levelData[right] then
					print("Joining objects:",left,right)
					levelData[left]["nrJoints"] = levelData[left]["nrJoints"] + 1
					if levelData[key]["type"] == "elastic" then
						print("elastic")
						levelData[left]["joints"][levelData[left]["nrJoints"]] = {levelData[key]["type"],physics.newJoint(levelData[key]["type"],levelData[left]["image"],levelData[right]["image"],levelData[left]["image"].x,levelData[left]["image"].y,levelData[right]["image"].x,levelData[right]["image"].y)}
					elseif levelData[key]["type"] == "pivot" then
						print("pivot")
						levelData[left]["joints"][levelData[left]["nrJoints"]] = {levelData[key]["type"],physics.newJoint(levelData[key]["type"],levelData[left]["image"],levelData[right]["image"],levelData[left]["image"].x,levelData[left]["image"].y)}
					end
					levelData[left]["jointWith"][levelData[left]["nrJoints"]] = right
					levelData[right]["jointPnr"] = levelData[right]["jointPnr"] + 1
					levelData[right]["jointParents"][levelData[right]["jointPnr"]] = {left,levelData[left]["nrJoints"]}
					
					UpdateJoint(left,levelData[left]["nrJoints"])
				end
			end
			levelData[key] = nil
		end
	arrow:toFront()
end
local function LoadLevel(path)
	local levelF,reason = io.open(path,"r")
	print("path:",path)
	local nesting_level = 0
	local createNew = false
	local parents_list = {}
	if(levelF == nil) then
		print("Could not open file to read from",reason);
		return true
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
	--now create joints
	for key,value in pairs(levelData) do
		LoadObject(key,"exclude","joint")
	end
	--load joints
	for key,value in pairs(levelData) do
		LoadObject(key,"only","joint")
	end
	return false
end

local function IsInsideAsteroid()
	for key,value in pairs(levelData) do
		if key:find("ast") then
			local dist = math.sqrt((levelData["player"]["image"].x-levelData[key]["image"].x)^2 + (levelData["player"]["image"].y-levelData[key]["image"].y)^2)
			if  dist <= (levelData[key]["image"].width/2+levelData["player"]["image"].width/2) then
				return levelData[key]
			end
		end
	end
	return nil
end
local function PlayerCollision(event)
	event.other:setLinearVelocity(0,0)
	levelData["player"]["image"]:setLinearVelocity(0,0)
end
local function GeneralInteraction(event)
	event.object1:setLinearVelocity(0,0)
	event.object2:setLinearVelocity(0,0)
end
---------------provisional enter frame listener------------------------------------
local function RemoveItem(key)
	--remove out joints
	if(levelData[key]["image"] and vectors[key] and  vectors[key]["image"])then
		vectors[key]["image"]:removeSelf()
		vectors[key]["image"] = nil
		vectors[key] = nil
	end
	if joints[key] then
		if(joints[key]["parent"])then
			joints[joints[key]["parent"]]["child"] = nil
			joints[joints[key]["parent"]]["type"]  = nil
			joints[joints[key]["parent"]] = nil
			joints[key]["parent"] = nil
			joints[key]           = nil
		else
			joints[joints[key]["child"]]["parent"] = nil
			joints[joints[key]["child"]] = nil
			joints[key]["child"] = nil
			joints[key]["type"]  = nil
			joints[key]          = nil
		end
	end
	print("deleting:",key)
	if levelData[key]["joints"] then
		for i = 1,#levelData[key]["joints"] do
			DeleteJoint(key,i)
		end
		levelData[key]["nrJoints"] = nil
		levelData[key]["joints"] = nil
	end
	--remove in joints
	if levelData[key]["jointParents"] then
		for i = 1,#levelData[key]["jointParents"] do
			DeleteJoint(levelData[key]["jointParents"][i][1],levelData[key]["jointParents"][i][2])
		end
		levelData[key]["jointPnr"] = nil
		levelData[key]["jointParents"] = nil
	end
	-- remove player joint
	if(levelData[key]["joint"]) then
		levelData[key]["joint"]:removeSelf()
		levelData[key]["joint"] = nil
	end
	-- removing player joint if asteroid gets sucked
	if levelData["player"] then
		if levelData["player"]["joint"] and levelData["player"]["joinWith"]["image"] == levelData[key]["image"] then
			levelData["player"]["joint"]:removeSelf()
			levelData["player"]["joint"] = nil
		end
	end
	print("Deleting image:",key)
	levelData[key]["image"]:removeSelf()
	levelData[key]["image"] = nil
	
	if(levelData[key]["field"]) then
		levelData[key]["field"]:removeSelf()
		levelData[key]["field"] = nil
	end
	levelData[key] = nil
end
local function onDelete()
	if(Selector and Selector~="player" and Selector~="exit")then
		RemoveItem(Selector)
		DiscardSelection()
		changed = true
	end
	return true
end
local function MaintainJoints(key)
	for i = 1,#levelData[key]["joints"] do
		UpdateJoint(key,i)
	end
end
local function ClearForZoom()
	physics.pause()
	end
local function RecoverAfterZoom()
	ZoomRecover = false
	physics.start()
end
local function frameEnter(event)
	grid.tick()
	
	TickCount = TickCount + 1
	if ZoomRecover then
		RecoverAfterZoom()
	end
	for key,value in pairs(vectors) do
		UpdateVector(key)
	end
	for key,value in pairs(levelData) do
		-- update game shapes
		if levelData[key]["image"] then
			-- maintain joints
			if levelData[key]["joints"] then
				MaintainJoints(key)
			end
			--relocate field if necessary
			if levelData[key]["field"] then
				if(levelData[key]["field"].x ~= levelData[key]["image"].x) then
					levelData[key]["field"].x = levelData[key]["image"].x
				end
				if(levelData[key]["field"].y ~= levelData[key]["image"].y) then 
					levelData[key]["field"].y = levelData[key]["image"].y
				end
			end
		end
	end
end
function ClearListeners()
	levelData["player"]["image"]:removeEventListener("preCollision",PlayerCollision)
	for key,value in pairs(levelData) do
		if levelData[key]["field"] then
			levelData[key]["field"]:removeEventListener("collision",levelData[key]["field"])
		end
		if key:find("ast") or key:find("boo") then
			levelData[key]["image"]:removeEventListener("touch",HandleAsteroTap)
		end
	end
end
local function SwitchObjectType(e)
	if(AddInType == "object")then
		AddInType = "enemy"
		bselector.x = 3*imgDim+saveBtn.width/2
	else
		AddInType = "object"
		bselector.x = 2*imgDim+saveBtn.width/2
	end
	return true
end
local function UpdateAsteroImg()
	if(ast)then
		ast:removeEventListener("tap",SwitchObjectType)
		ast:removeSelf()
		ast = nil
	end
	ast = display.newImageRect(SELECTED_SKIN_PACK..Classes[ClassIndex][SubclassIndex]["imgname"],SKIN_BASE_DIR,stageH,stageH)
	ast.x = 2*imgDim+saveBtn.width/2
	ast.y = saveBtn.y
	ast:addEventListener("tap",SwitchObjectType)
	stageG:insert(ast)
end
local function UpdateEnemyImg()
	if(enemy)then
		enemy:removeEventListener("tap",SwitchObjectType)
		enemy:removeSelf()
		enemy = nil
	end
	enemy = display.newImageRect(SELECTED_SKIN_PACK..EClasses[EClassIndex][ESubclassIndex]["imgname"],SKIN_BASE_DIR,stageH,stageH)
	enemy.x = 3*imgDim+saveBtn.width/2
	enemy.y = saveBtn.y
	enemy:addEventListener("tap",SwitchObjectType)
	stageG:insert(enemy)
end
local function SwitchEditMode(e)
	if(edmoveBtn)then
		edmoveBtn:removeEventListener("tap",SwitchEditMode);
		edmoveBtn:removeSelf()
		edmoveBtn = nil
	end
	if(TouchMode == "move") then
		TouchMode = "edit"
		edmoveBtn = display.newImageRect("edit.png",stageH,stageH)
	else
		TouchMode = "move"
		edmoveBtn = display.newImageRect("move.png",stageH,stageH)
	end
	edmoveBtn.x = 1*imgDim+saveBtn.width/2
	edmoveBtn.y = saveBtn.y
	edmoveBtn:addEventListener("tap",SwitchEditMode);
	stageG:insert(edmoveBtn)
	return true
end
-- Called when the scene's view does not exist:
-- Called when the scene's view does not exist:
local function objClassUp()
	if(AddInType == "enemy")then
		ESubclassIndex = ESubclassIndex + 1
		if( ESubclassIndex > #EClasses[EClassIndex])then
			ESubclassIndex = 1
			EClassIndex = EClassIndex + 1
		end
		if( EClassIndex > #EClasses ) then
			EClassIndex = 1
		end
		UpdateEnemyImg()
	else
		SubclassIndex = SubclassIndex + 1
		if( SubclassIndex > #Classes[ClassIndex])then
			SubclassIndex = 1
			ClassIndex = ClassIndex + 1
		end
		if( ClassIndex > #Classes ) then
			ClassIndex = 1
		end
		UpdateAsteroImg()
	end
end
local function objClassDn()
	if(AddInType == "enemy")then
		ESubclassIndex = ESubclassIndex - 1
		if( ESubclassIndex < 1 )then
			EClassIndex = EClassIndex - 1
			if( EClassIndex < 1 ) then
				EClassIndex = #EClasses
			end
			ESubclassIndex = #EClasses[EClassIndex]
		end
		UpdateEnemyImg()
	else
		SubclassIndex = SubclassIndex - 1
		if( SubclassIndex < 1 )then
			ClassIndex = ClassIndex - 1
			if( ClassIndex < 1 ) then
				ClassIndex = #Classes
			end
			SubclassIndex = #Classes[ClassIndex]
		end
		UpdateAsteroImg()
	end
end
local function ZoomOneObj(key,coef)
	ClearForZoom()
	levelData[key]["image"].width = levelData[key]["image"].width * coef
	levelData[key]["image"].height = levelData[key]["image"].height * coef 
	if levelData[key]["radius"] then
		levelData[key]["radius"] = levelData[key]["radius"] * coef 
	end
	--if RemoveOnce then
	removePhBodies( key )
	if levelData[key]["field"] then
		print("has field:",levelData[key]["field"])
		levelData[key]["field"].width = levelData[key]["field"].width * coef
		levelData[key]["field"].height = levelData[key]["field"].width
		levelData[key]["field"].x = levelData[key]["image"].x
		levelData[key]["field"].y = levelData[key]["image"].y
	end
	reinstatePhBodies(key)
	RecoverAfterZoom()
end
local function sizeUp(e)
	if(e.phase ~= "ended") then
		return true
	end
	ZoomOneObj(Selector,1.1)
	return true
end
local function sizeDn(e)
	if(e.phase ~= "ended") then
		return true
	end
	ZoomOneObj(Selector,0.9)
	return true
end
local function fieldUp(e)
	if(e.phase ~= "ended" ) then
		return true
	end
	if Selector:find("enemy") then
		print("Enemy up")
		if Selector:find("enemyEver") then
			return true
		end
		if levelData[Selector]["range"] == nil then 
			print("Created range field")
			levelData[Selector]["range"] = 0
		end
		levelData[Selector]["range"] = levelData[Selector]["range"] + 0.25
		if levelData[Selector]["range"] < 1 then
			levelData[Selector]["range"] = levelData[Selector]["range"] + 1
		end
		if levelData[Selector]["field"] == nil then
			levelData[Selector]["field"] = display.newCircle( 0,0,levelData[Selector]["range"]*levelData[Selector]["image"].width/2)
			levelData[Selector]["field"].alpha = 0.3
			levelData[Selector]["field"].x = levelData[Selector]["image"].x
			levelData[Selector]["field"].y = levelData[Selector]["image"].y
			group:insert(levelData[Selector]["field"])
		else
			levelData[Selector]["field"].width = levelData[Selector]["range"]*levelData[Selector]["image"].width
			levelData[Selector]["field"].height = levelData[Selector]["field"].width 
		end
	else
		if not levelData[Selector]["gravity"] then
			levelData[Selector]["gravity"] = 0
		end
		levelData[Selector]["gravity"] = levelData[Selector]["gravity"] + 0.25
		if levelData[Selector]["gravity"] < 1 then
			levelData[Selector]["gravity"] = levelData[Selector]["gravity"] + 1
		end
		if levelData[Selector]["field"] == nil then
			levelData[Selector]["field"] = display.newCircle( 0,0,levelData[Selector]["gravity"]*levelData[Selector]["image"].width/2)
			levelData[Selector]["field"].alpha = 0.3
			levelData[Selector]["field"].x = levelData[Selector]["image"].x
			levelData[Selector]["field"].y = levelData[Selector]["image"].y
			group:insert(levelData[Selector]["field"])
		else
			levelData[Selector]["field"].width = levelData[Selector]["gravity"]*levelData[Selector]["image"].width
			levelData[Selector]["field"].height = levelData[Selector]["field"].width 
		end
	end
	return true
end
local function fieldDn(e)
	if(e.phase ~= "ended") then
		return true
	end
	if Selector:find("enemy") then
		if Selector:find("boo") or Selector:find("enemyEver") then
			return true
		end
		levelData[Selector]["range"] = levelData[Selector]["range"] - 0.25
		if levelData[Selector]["range"] < 1 then
			levelData[Selector]["range"] = 0
		end
		if levelData[Selector]["range"] == 0 then
			if levelData[Selector]["field"] then
				levelData[Selector]["field"]:removeSelf()
				levelData[Selector]["field"] = nil
			end
		else
			if levelData[Selector]["field"] then
				levelData[Selector]["field"].width = levelData[Selector]["range"]*levelData[Selector]["image"].width
				levelData[Selector]["field"].height = levelData[Selector]["field"].width
			end
		end
	else
		levelData[Selector]["gravity"] = levelData[Selector]["gravity"] - 0.25
		if levelData[Selector]["gravity"] < 1 then
			levelData[Selector]["gravity"] = 0
		end
		if levelData[Selector]["gravity"] == 0 then
			if levelData[Selector]["field"] then
				levelData[Selector]["field"]:removeSelf()
				levelData[Selector]["field"] = nil
			end
		else
			levelData[Selector]["field"].width = levelData[Selector]["gravity"]*levelData[Selector]["image"].width
			levelData[Selector]["field"].height = levelData[Selector]["field"].width
		end
	end
	return true
end
local function changeBtype(e)
	if(e.phase == "ended") then
		if btype.text == "static" then
			btype.text = "dynamic"
			levelData[Selector]["bodyType"] = "dynamic"
		else
			btype.text = "static"
			levelData[Selector]["bodyType"] = "static"
		end
	end
	return true
end
function changeFieldDir(e)
	if (e.phase == "ended") and levelData[Selector]["gravityForce"] then
		if tonumber(levelData[Selector]["gravityForce"]) > 0 then
			fieldDir.text = "repell"
		else
			fieldDir.text = "attract"
		end
		levelData[Selector]["gravityForce"] = -levelData[Selector]["gravityForce"]
	end
	return true
end
local function Disengager(e)
	if(e.phase == "ended") then
		DiscardSelection()
	end
	return true
end
local function EventCapturer(e)
	return true
end
local function InitObjectClasses()
	--typical asteroid1 configuration
	Classes[1] = {}
	Classes[1][1] = {}
	Classes[1][1]["gravity"]       = 0
	Classes[1][1]["explosiveness"] = 0
	Classes[1][1]["gravityForce"]  = 0
	Classes[1][1]["bodyType"]      = "dynamic"
	Classes[1][1]["friction"]      = 0.5
	Classes[1][1]["bounce"]        = 0.1
	Classes[1][1]["density"]       = 50
	Classes[1][1]["rotation"]      = 0
	Classes[1][1]["imgname"]       = "rock1.png"
	Classes[1][1]["angleforce"]    = 0
	
	Classes[1][2] = {}
	Classes[1][2]["gravity"]       = 0
	Classes[1][2]["explosiveness"] = 0
	Classes[1][2]["gravityForce"]  = 0
	Classes[1][2]["bodyType"]      = "dynamic"
	Classes[1][2]["friction"]      = 0.0
	Classes[1][2]["bounce"]        = 0.0
	Classes[1][2]["density"]       = 25
	Classes[1][2]["rotation"]      = 0
	Classes[1][2]["imgname"]       = "rock2.png"
	Classes[1][2]["angleforce"]    = 0
	
	Classes[1][3] = {}
	Classes[1][3]["gravity"]       = 0
	Classes[1][3]["explosiveness"] = 0
	Classes[1][3]["gravityForce"]  = 0
	Classes[1][3]["bodyType"]      = "dynamic"
	Classes[1][3]["friction"]      = 0.0
	Classes[1][3]["bounce"]        = 0.0
	Classes[1][3]["density"]       = 10
	Classes[1][3]["rotation"]      = 0
	Classes[1][3]["imgname"]       = "rock3.png"
	Classes[1][3]["angleforce"]    = 0
	
	Classes[1][4] = {}
	Classes[1][4]["gravity"]       = 0
	Classes[1][4]["explosiveness"] = 0
	Classes[1][4]["gravityForce"]  = 0
	Classes[1][4]["bodyType"]      = "dynamic"
	Classes[1][4]["friction"]      = 0.0
	Classes[1][4]["bounce"]        = 0.0
	Classes[1][4]["density"]       = 150
	Classes[1][4]["rotation"]      = 0
	Classes[1][4]["imgname"]       = "rock4.png"
	Classes[1][4]["angleforce"]    = 0
	
	Classes[1][5] = {}
	Classes[1][5]["gravity"]       = 0
	Classes[1][5]["explosiveness"] = 2
	Classes[1][5]["gravityForce"]  = 0
	Classes[1][5]["bodyType"]      = "dynamic"
	Classes[1][5]["friction"]      = 0.0
	Classes[1][5]["bounce"]        = 0.0
	Classes[1][5]["density"]       = 20
	Classes[1][5]["rotation"]      = 0
	Classes[1][5]["imgname"]       = "erock1.png"
	Classes[1][5]["angleforce"]    = 0
	
	Classes[1][6] = {}
	Classes[1][6]["gravity"]       = 0
	Classes[1][6]["explosiveness"] = 4
	Classes[1][6]["gravityForce"]  = 0
	Classes[1][6]["bodyType"]      = "dynamic"
	Classes[1][6]["friction"]      = 0.0
	Classes[1][6]["bounce"]        = 0.0
	Classes[1][6]["density"]       = 20
	Classes[1][6]["rotation"]      = 0
	Classes[1][6]["imgname"]       = "erock2.png"
	Classes[1][6]["angleforce"]    = 0
	
	Classes[1][7] = {}
	Classes[1][7]["gravity"]       = 0
	Classes[1][7]["explosiveness"] = 6
	Classes[1][7]["gravityForce"]  = 0
	Classes[1][7]["bodyType"]      = "dynamic"
	Classes[1][7]["friction"]      = 0.0
	Classes[1][7]["bounce"]        = 0.0
	Classes[1][7]["density"]       = 20
	Classes[1][7]["rotation"]      = 0
	Classes[1][7]["imgname"]       = "erock3.png"
	Classes[1][7]["angleforce"]    = 0
	
	Classes[1][8] = {}
	Classes[1][8]["gravity"]       = 0
	Classes[1][8]["explosiveness"] = 8
	Classes[1][8]["gravityForce"]  = 0
	Classes[1][8]["bodyType"]      = "dynamic"
	Classes[1][8]["friction"]      = 0.0
	Classes[1][8]["bounce"]        = 0.0
	Classes[1][8]["density"]       = 20
	Classes[1][8]["rotation"]      = 0
	Classes[1][8]["imgname"]       = "erock4.png"
	Classes[1][8]["angleforce"]    = 0
	
	Classes[1][9] = {}
	Classes[1][9]["gravity"]       = 0
	Classes[1][9]["explosiveness"] = -2
	Classes[1][9]["gravityForce"]  = 0
	Classes[1][9]["bodyType"]      = "dynamic"
	Classes[1][9]["friction"]      = 0.0
	Classes[1][9]["bounce"]        = 0.0
	Classes[1][9]["density"]       = 20
	Classes[1][9]["rotation"]      = 0
	Classes[1][9]["imgname"]       = "irock1.png"
	Classes[1][9]["angleforce"]    = 0
	
	Classes[1][10] = {}
	Classes[1][10]["gravity"]       = 0
	Classes[1][10]["explosiveness"] = -4
	Classes[1][10]["gravityForce"]  = 0
	Classes[1][10]["bodyType"]      = "dynamic"
	Classes[1][10]["friction"]      = 0.0
	Classes[1][10]["bounce"]        = 0.0
	Classes[1][10]["density"]       = 20
	Classes[1][10]["rotation"]      = 0
	Classes[1][10]["imgname"]       = "irock2.png"
	Classes[1][10]["angleforce"]    = 0
	
	Classes[1][11] = {}
	Classes[1][11]["gravity"]       = 0
	Classes[1][11]["explosiveness"] = -6
	Classes[1][11]["gravityForce"]  = 0
	Classes[1][11]["bodyType"]      = "dynamic"
	Classes[1][11]["friction"]      = 0.0
	Classes[1][11]["bounce"]        = 0.0
	Classes[1][11]["density"]       = 20
	Classes[1][11]["rotation"]      = 0
	Classes[1][11]["imgname"]       = "irock3.png"
	Classes[1][11]["angleforce"]    = 0
	
	Classes[1][12] = {}
	Classes[1][12]["gravity"]       = 0
	Classes[1][12]["explosiveness"] = -8
	Classes[1][12]["gravityForce"]  = 0
	Classes[1][12]["bodyType"]      = "dynamic"
	Classes[1][12]["friction"]      = 0.0
	Classes[1][12]["bounce"]        = 0.0
	Classes[1][12]["density"]       = 20
	Classes[1][12]["rotation"]      = 0
	Classes[1][12]["imgname"]       = "irock4.png"
	Classes[1][12]["angleforce"]    = 0
	
	-- typical asteroid2 configuration
	-- typical vortex1 configuration
	Classes[2] = {}
	Classes[2][1] = {}
	Classes[2][1]["gravity"]       = 4
	Classes[2][1]["explosiveness"] = 0
	Classes[2][1]["gravityForce"]  = 0.3
	Classes[2][1]["bodyType"]      = "static"
	Classes[2][1]["friction"]      = 0.0
	Classes[2][1]["bounce"]        = 0.0
	Classes[2][1]["density"]       = 50
	Classes[2][1]["rotation"]      = 0
	Classes[2][1]["imgname"]       = "vortex1.png"
	Classes[2][1]["angleforce"]    = 0
	Classes[2][1]["absorb"]        = "true"
	-- typical planet configuration
	Classes[3]	= {}
	Classes[3][1] = {}
	Classes[3][1]["gravity"]       = 3
	Classes[3][1]["explosiveness"] = 0
	Classes[3][1]["gravityForce"]  = 1.0
	Classes[3][1]["bodyType"]      = "static"
	Classes[3][1]["friction"]      = 0.0
	Classes[3][1]["bounce"]        = 0.0
	Classes[3][1]["density"]       = 100
	Classes[3][1]["rotation"]      = 0
	Classes[3][1]["imgname"]       = "planet1.png"
	Classes[3][1]["angleforce"]    = 0
	--trinkets
	Classes[4] = {}
	Classes[4][1] = {}
	Classes[4][1]["bodyType"]      = "dynamic"
	Classes[4][1]["imgname"]       = "star.png"
	
	Classes[5] = {}
	Classes[5][1] = {}
	Classes[5][1]["bodyType"]      = "dynamic"
	Classes[5][1]["imgname"]       = "flame.png"
	
	Classes[6] = {}
	Classes[6][1] = {}
	Classes[6][1]["bodyType"]      = "dynamic"
	Classes[6][1]["imgname"]       = "vacuum.png"
	--ENEMIES
	-- simple 
	EClasses[1] = {}
	EClasses[1][1] = {}
	EClasses[1][1]["gravity"]       = 0
	EClasses[1][1]["explosiveness"] = 0
	EClasses[1][1]["gravityForce"]  = 0
	EClasses[1][1]["bodyType"]      = "dynamic"
	EClasses[1][1]["friction"]      = 0.1
	EClasses[1][1]["bounce"]        = 0.1
	EClasses[1][1]["density"]       = 1
	EClasses[1][1]["rotation"]      = 0
	EClasses[1][1]["imgname"]       = "enemy9.png"
	EClasses[1][1]["actionType"]    = "dumb-charging"
	EClasses[1][1]["range"]         = 0.0
	EClasses[1][1]["GoForce"]       = 1
	
	EClasses[1][2] = {}
	EClasses[1][2]["gravity"]       = 0
	EClasses[1][2]["explosiveness"] = 0
	EClasses[1][2]["gravityForce"]  = 0
	EClasses[1][2]["bodyType"]      = "dynamic"
	EClasses[1][2]["friction"]      = 0.1
	EClasses[1][2]["bounce"]        = 0.1
	EClasses[1][2]["density"]       = 1
	EClasses[1][2]["rotation"]      = 0
	EClasses[1][2]["imgname"]       = "enemy10.png"
	EClasses[1][2]["actionType"]    = "dumb-charging"
	EClasses[1][2]["range"]         = 0.0
	EClasses[1][2]["GoForce"]       = 2
	
	EClasses[1][3] = {}
	EClasses[1][3]["gravity"]       = 0
	EClasses[1][3]["explosiveness"] = 0
	EClasses[1][3]["gravityForce"]  = 0
	EClasses[1][3]["bodyType"]      = "dynamic"
	EClasses[1][3]["friction"]      = 0.1
	EClasses[1][3]["bounce"]        = 0.1
	EClasses[1][3]["density"]       = 0.2
	EClasses[1][3]["rotation"]      = 0
	EClasses[1][3]["imgname"]       = "enemy11.png"
	EClasses[1][3]["actionType"]    = "dumb-charging"
	EClasses[1][3]["range"]         = 0.0
	EClasses[1][3]["GoForce"]       = 2.0
	
	EClasses[1][4] = {}
	EClasses[1][4]["gravity"]       = 0
	EClasses[1][4]["explosiveness"] = 0
	EClasses[1][4]["gravityForce"]  = 0
	EClasses[1][4]["bodyType"]      = "dynamic"
	EClasses[1][4]["friction"]      = 0.1
	EClasses[1][4]["bounce"]        = 0.1
	EClasses[1][4]["density"]       = 0.2
	EClasses[1][4]["rotation"]      = 0
	EClasses[1][4]["imgname"]       = "enemy12.png"
	EClasses[1][4]["actionType"]    = "dumb-charging"
	EClasses[1][4]["range"]         = 0.0
	EClasses[1][4]["GoForce"]       = 2.0
	
	EClasses[1][5] = {}
	EClasses[1][5]["gravity"]       = 0
	EClasses[1][5]["explosiveness"] = 0
	EClasses[1][5]["gravityForce"]  = 0
	EClasses[1][5]["bodyType"]      = "dynamic"
	EClasses[1][5]["friction"]      = 0.1
	EClasses[1][5]["bounce"]        = 0.1
	EClasses[1][5]["density"]       = 0.2
	EClasses[1][5]["rotation"]      = 0
	EClasses[1][5]["imgname"]       = "enemy13.png"
	EClasses[1][5]["actionType"]    = "dumb-charging"
	EClasses[1][5]["range"]         = 0.0
	EClasses[1][5]["GoForce"]       = 2.0
	
	EClasses[1][6] = {}
	EClasses[1][6]["gravity"]       = 0
	EClasses[1][6]["explosiveness"] = 0
	EClasses[1][6]["gravityForce"]  = 0
	EClasses[1][6]["bodyType"]      = "dynamic"
	EClasses[1][6]["friction"]      = 0.1
	EClasses[1][6]["bounce"]        = 0.1
	EClasses[1][6]["density"]       = 0.2
	EClasses[1][6]["rotation"]      = 0
	EClasses[1][6]["imgname"]       = "enemy14.png"
	EClasses[1][6]["actionType"]    = "dumb-charging"
	EClasses[1][6]["range"]         = 0.0
	EClasses[1][6]["GoForce"]       = 2.0
	
	EClasses[1][7] = {}
	EClasses[1][7]["gravity"]       = 0
	EClasses[1][7]["explosiveness"] = 0
	EClasses[1][7]["gravityForce"]  = 0
	EClasses[1][7]["bodyType"]      = "dynamic"
	EClasses[1][7]["friction"]      = 0.1
	EClasses[1][7]["bounce"]        = 0.1
	EClasses[1][7]["density"]       = 0.2
	EClasses[1][7]["rotation"]      = 0
	EClasses[1][7]["imgname"]       = "enemy15.png"
	EClasses[1][7]["actionType"]    = "dumb-charging"
	EClasses[1][7]["range"]         = 0.0
	EClasses[1][7]["GoForce"]       = 2.0
	
	EClasses[1][8] = {}
	EClasses[1][8]["gravity"]       = 0
	EClasses[1][8]["explosiveness"] = 0
	EClasses[1][8]["gravityForce"]  = 0
	EClasses[1][8]["bodyType"]      = "dynamic"
	EClasses[1][8]["friction"]      = 0.1
	EClasses[1][8]["bounce"]        = 0.1
	EClasses[1][8]["density"]       = 0.2
	EClasses[1][8]["rotation"]      = 0
	EClasses[1][8]["imgname"]       = "enemy16.png"
	EClasses[1][8]["actionType"]    = "dumb-charging"
	EClasses[1][8]["range"]         = 0.0
	EClasses[1][8]["GoForce"]       = 2.0
	-- ever charging enemy
	EClasses[2] = {}
	EClasses[2][1] = {}
	EClasses[2][1]["bodyType"]      = "dynamic"
	EClasses[2][1]["friction"]      = 0.1
	EClasses[2][1]["bounce"]        = 0.1
	EClasses[2][1]["density"]       = 0.2
	EClasses[2][1]["rotation"]      = 0
	EClasses[2][1]["imgname"]       = "enemy2.png"
	EClasses[2][1]["actionType"]    = "dumb-charging"
	EClasses[2][1]["range"]         = 0.0
	EClasses[2][1]["GoForce"]       = 2.0
	-- telekinetic enemy
	EClasses[3] = {}
	EClasses[3][1] = {}
	EClasses[3][1]["bodyType"]      = "dynamic"
	EClasses[3][1]["friction"]      = 0.0
	EClasses[3][1]["bounce"]        = 0.0
	EClasses[3][1]["density"]       = 0.2
	EClasses[3][1]["rotation"]      = 0
	EClasses[3][1]["imgname"]       = "enemy1.png"
	EClasses[3][1]["actionType"]    = "dragger"
	EClasses[3][1]["range"]         = 4
	EClasses[3][1]["dragForce"]     = 0.5
	
	EClasses[3][2] = {}
	EClasses[3][2]["bodyType"]      = "dynamic"
	EClasses[3][2]["friction"]      = 0.0
	EClasses[3][2]["bounce"]        = 0.0
	EClasses[3][2]["density"]       = 0.2
	EClasses[3][2]["rotation"]      = 0
	EClasses[3][2]["imgname"]       = "enemy2.png"
	EClasses[3][2]["actionType"]    = "dragger"
	EClasses[3][2]["range"]         = 5
	EClasses[3][2]["dragForce"]     = 1.5
	
	EClasses[3][3] = {}
	EClasses[3][3]["bodyType"]      = "dynamic"
	EClasses[3][3]["friction"]      = 0.0
	EClasses[3][3]["bounce"]        = 0.0
	EClasses[3][3]["density"]       = 0.2
	EClasses[3][3]["rotation"]      = 0
	EClasses[3][3]["imgname"]       = "enemy3.png"
	EClasses[3][3]["actionType"]    = "dragger"
	EClasses[3][3]["range"]         = 6
	EClasses[3][3]["dragForce"]     = 3.5
	
	EClasses[3][4] = {}
	EClasses[3][4]["bodyType"]      = "dynamic"
	EClasses[3][4]["friction"]      = 0.0
	EClasses[3][4]["bounce"]        = 0.0
	EClasses[3][4]["density"]       = 0.2
	EClasses[3][4]["rotation"]      = 0
	EClasses[3][4]["imgname"]       = "enemy4.png"
	EClasses[3][4]["actionType"]    = "dragger"
	EClasses[3][4]["range"]         = 7
	EClasses[3][4]["dragForce"]     = 5.5

	EClasses[3][5] = {}
	EClasses[3][5]["bodyType"]      = "dynamic"
	EClasses[3][5]["friction"]      = 0.0
	EClasses[3][5]["bounce"]        = 0.0
	EClasses[3][5]["density"]       = 0.2
	EClasses[3][5]["rotation"]      = 0
	EClasses[3][5]["imgname"]       = "enemy5.png"
	EClasses[3][5]["actionType"]    = "dragger"
	EClasses[3][5]["range"]         = 7
	EClasses[3][5]["dragForce"]     = 6.5
	
	EClasses[3][6] = {}
	EClasses[3][6]["bodyType"]      = "dynamic"
	EClasses[3][6]["friction"]      = 0.0
	EClasses[3][6]["bounce"]        = 0.0
	EClasses[3][6]["density"]       = 0.2
	EClasses[3][6]["rotation"]      = 0
	EClasses[3][6]["imgname"]       = "enemy6.png"
	EClasses[3][6]["actionType"]    = "dragger"
	EClasses[3][6]["range"]         = 8
	EClasses[3][6]["dragForce"]     = 8.5
	
	EClasses[3][7] = {}
	EClasses[3][7]["bodyType"]      = "dynamic"
	EClasses[3][7]["friction"]      = 0.0
	EClasses[3][7]["bounce"]        = 0.0
	EClasses[3][7]["density"]       = 0.2
	EClasses[3][7]["rotation"]      = 0
	EClasses[3][7]["imgname"]       = "enemy7.png"
	EClasses[3][7]["actionType"]    = "dragger"
	EClasses[3][7]["range"]         = 9
	EClasses[3][7]["dragForce"]     = 10.5
	
	EClasses[3][8] = {}
	EClasses[3][8]["bodyType"]      = "dynamic"
	EClasses[3][8]["friction"]      = 0.0
	EClasses[3][8]["bounce"]        = 0.0
	EClasses[3][8]["density"]       = 0.2
	EClasses[3][8]["rotation"]      = 0
	EClasses[3][8]["imgname"]       = "enemy8.png"
	EClasses[3][8]["actionType"]    = "dragger"
	EClasses[3][8]["range"]         = 10
	EClasses[3][8]["dragForce"]     = 16
end
local function setupScene()
	print("sys dir:",system.DocumentsDirectory)
	Fpath = system.pathForFile( "", system.DocumentsDirectory )
	--Fpath = Fpath .. "yours/"
	print("path attempt:",Fpath)
	local success = lfs.chdir( Fpath ) -- returns true on success
	if not success then
		Fpath = system.pathForFile( "", system.DocumentsDirectory )
		success = lfs.chdir( Fpath )
		if success then
			lfs.mkdir( "yours" )
			--Fpath = lfs.currentdir() .. "/yours"
			success = lfs.chdir( Fpath )
			if not success then
				print("Error, i won't be able to write files to your disk!(can't change path)")
			end
		else
			print("ERROR, i won't be able to write levels to your disk!(no yours directory)")
		end
	end
	
	background = display.newRect( 0,0, display.contentWidth*1.1, display.contentHeight*1.2)
	background:setFillColor(0,0,0)
	background.x = display.contentWidth / 2
	background.y = display.contentHeight / 2
	background.alpha = BKG_ALPHA
	group:insert(background)
	grid.init({group = group,boxSize=83})

	grid.redraw(true)
	
	InitObjectClasses() -- initialise all possible added elements
	if(stageH>imgDim)then
		stageH = imgDim
	end
	
	stg = display.newRect( 0 , 0 , display.contentWidth, stageH)
	stg:setFillColor(140, 140, 140)
	stg:addEventListener("touch",EventCapturer)
	stageG:insert(stg)
	group:insert(stageG)
	
	saveBtn = widget.newButton{
		defaultFile="save.png",
		overFile="saveOver.png",
		width=stageH, height=stageH,
		onRelease = SaveLevelUnderName	-- event listener function
	} 
	saveBtn.x = stageH/2
	saveBtn.y = stageH/2
	stageG:insert(saveBtn)
	
	classDn = widget.newButton{
		defaultFile="dn.png",
		overFile="dn.png",
		width=stageH/2, height=stageH/2,
		onRelease = objClassDn	-- event listener function
	}
	classDn.x = classDn.width/2
	classDn.y = stageH+classDn.height/2
	stageG:insert(classDn)
	
	classUp = widget.newButton{
		defaultFile="up.png",
		overFile="up.png",
		width=stageH/2, height=stageH/2,
		onRelease = objClassUp	-- event listener function
	}
	classUp.x = display.contentWidth-classUp.width/2
	classUp.y = stageH+classUp.height/2
	stageG:insert(classUp)
	
	bselector = display.newRect(0,0,stageH,stageH)
	bselector:setFillColor(255,0,0)
	bselector.alpha=0.5
	bselector.y = saveBtn.y
	SwitchObjectType()
	stageG:insert(bselector)
	
	SwitchEditMode(nil)
	UpdateAsteroImg()
	UpdateEnemyImg()
	
	deleteBtn = widget.newButton{
		defaultFile="delete.png",
		overFile="deleteOver.png",
		width=stageH, height=stageH,
		onRelease = onDelete	-- event listener function
	} 
	deleteBtn.x = 4*imgDim+saveBtn.width/2
	deleteBtn.y = saveBtn.y
	stageG:insert(deleteBtn)
	
	backBtn = widget.newButton{
		defaultFile="backButton.png",
		overFile="backButtonOver.png",
		width=stageH/2, height=stageH/2,
		onRelease = backToMenu	-- event listener function
	} 
	backBtn.x = backBtn.width/2
	backBtn.y = display.contentHeight - backBtn.width/2
	stageG:insert(backBtn)
	
	scrn = display.newRect(0,stageH,display.contentWidth,display.contentHeight)
	scrn:setFillColor(140,140,140)
	scrn.alpha = 0.5
	scrn:addEventListener("touch",Disengager)
	
	sup = display.newImageRect("up.png",stageH/2, stageH/2)
	sdn = display.newImageRect("dn.png",stageH/2, stageH/2)	
	fup = display.newImageRect("up.png",stageH/2, stageH/2)
	fdn = display.newImageRect("dn.png",stageH/2, stageH/2)

	sup.y = display.contentHeight/2-sup.height
	sdn.y = sup.y
	sup.x = display.contentWidth - sup.width
	sdn.x = sdn.width

	fup.y = display.contentHeight/2+fup.height
	fdn.y = fup.y
	fup.x = display.contentWidth - fup.width
	fdn.x = fdn.width
	
	fieldDir = display.newText("attract",0,0,native.systemFont,display.contentWidth*0.1)
	fieldDir:setTextColor(255,255,255)
	fieldDir.x = display.contentWidth/2
	fieldDir.y = fdn.y+fdn.height*2
	
	btype = display.newText("dynamic",0,0,native.systemFont,display.contentWidth*0.1)
	btype:setTextColor(255,255,255)
	btype.x = display.contentWidth/2
	btype.y = fieldDir.y+fieldDir.height*2
	
	slabel = display.newText("size",0,0,native.systemFont,display.contentWidth*0.1)
	slabel:setTextColor(255,255,255)
	slabel.x = display.contentWidth/2
	slabel.y = sup.y
	
	flabel = display.newText("field",0,0,native.systemFont,display.contentWidth*0.1)
	flabel:setTextColor(255,255,255)
	flabel.x = display.contentWidth/2
	flabel.y = fup.y
	
	sup:addEventListener("touch",sizeUp)
	sdn:addEventListener("touch",sizeDn)
	fup:addEventListener("touch",fieldUp)
	fdn:addEventListener("touch",fieldDn)
	btype:addEventListener("touch",changeBtype)
	fieldDir:addEventListener("touch",changeFieldDir)
	
	configG:insert(slabel)
	configG:insert(flabel)
	configG:insert(sup)
	configG:insert(sdn)
	configG:insert(fup)
	configG:insert(fdn)
	configG:insert(btype)
	configG:insert(fieldDir)
	
	scrn.isVisible = false
	configG.isVisible = false
	
local notloaded = true
if(CurrentLevel:len()) then
	levelName = nil
	notloaded = LoadLevel(CurrentLevel)
	if notloaded then
		levelName = "default.lvl"
	end
end

if notloaded then
levelData["ast0"] = {}
levelData["ast0"]["friction"]=1
levelData["ast0"]["radius"]=70.5
levelData["ast0"]["explosiveness"]=0
levelData["ast0"]["gravity"]=0
levelData["ast0"]["bounce"]=1
levelData["ast0"]["density"]=50
levelData["ast0"]["x"]=display.contentWidth/2
levelData["ast0"]["y"]=display.contentHeight/2
levelData["ast0"]["width"]=141
levelData["ast0"]["height"]=141
levelData["ast0"]["rotation"]=0
levelData["ast0"]["gravityForce"]=0.4
levelData["ast0"]["imgname"]="rock1.png"
levelData["ast0"]["acidness"]=0
levelData["ast0"]["angleforce"]=20
LoadObject("ast0","only","ast")

levelData["exit"] = {}
levelData["exit"]["gravity"]=3
levelData["exit"]["bounce"]=1
levelData["exit"]["bodyType"]="static"
levelData["exit"]["imgname"]="exit.png"
levelData["exit"]["radius"]=50
levelData["exit"]["explosiveness"]=0
levelData["exit"]["angleforce"]=0
levelData["exit"]["acidness"]=0
levelData["exit"]["x"]=display.contentWidth/2
levelData["exit"]["y"]=display.contentWidth/4
levelData["exit"]["width"]=100
levelData["exit"]["height"]=100
levelData["exit"]["rotation"]=0
levelData["exit"]["friction"]=0
levelData["exit"]["density"]=1000
levelData["exit"]["gravityForce"] = 999999999
LoadObject("exit","only","exit")

levelData["player"] = {}
levelData["player"]["friction"]=1
levelData["player"]["radius"]=50
levelData["player"]["explosiveness"]=0
levelData["player"]["startObj"]=ast0
levelData["player"]["x"]=display.contentWidth/2+100
levelData["player"]["y"]=display.contentHeight/2
levelData["player"]["width"]=100
levelData["player"]["height"]=100
levelData["player"]["rotation"]=0
levelData["player"]["angleforce"]=0
levelData["player"]["bounce"]=1
levelData["player"]["density"]=0.1
levelData["player"]["acidness"]=0
levelData["player"]["imgname"]="player.png"
levelData["player"]["gravity"]=0
LoadObject("player","only","player")
end
background:addEventListener( "touch", HandleGeneralTouch )
Runtime:addEventListener("enterFrame",frameEnter)
Runtime:addEventListener("preCollision", GeneralInteraction)
--stageG:toFront()

end
function scene:createScene( event )
	--change current dir
	-- get raw path to app's Temporary directory
	group = self.view
	showLoad.init()
	showLoad.trigger(display.contentWidth/2,display.contentHeight/2)
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	
	MENU_ANIMATION_RUNNING = false
	setupScene()
	label = display.newText("Save As:",0,0,native.systemFont,display.contentWidth*0.1)
	label:setTextColor(255,255,255)
	label.x = display.contentWidth/2
	label.y = display.contentHeight/4
	nameField = native.newTextField( display.contentWidth*0.1, label.y+label.height/2, display.contentWidth*0.8,display.contentWidth*0.2)
	nameField.hintText = "Filename Here"
	nameField.isVisible = false
	label.isVisible = false
	
	group:insert(label)
	group:insert(nameField)
	
	showLoad.clear()
	physics.start()
	stageG:toFront()

end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	label:removeSelf()
	label = nil
	nameField :removeSelf()
	nameField = nil
	
	grid.clear()
end
-- If scene's view is removed, scene:destroyScene() will be called just prior to:
local function DestroyObject(obj)
	if obj then
		obj:removeSelf()
		obj = nil
	end
end
function scene:destroyScene( event )
	print("removing pblsnr")
	package.loaded[physics] = nil
	physics = nil
	levelData = nil
	background:removeEventListener( "touch", HandleGeneralTouch )
	Runtime:removeEventListener("enterFrame",frameEnter)
	Runtime:removeEventListener("preCollision", GeneralInteraction)
	--pauseBtn:removeEventListener("tap",backToMenu)
	storyboard.gotoScene("menu","fade",fdspd)
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