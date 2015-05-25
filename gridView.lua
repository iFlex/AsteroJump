module(..., package.seeall)  
local lockMovement = false

local verticals   = {}
local horizontals = {}
local CX = display.contentWidth/2
local CY = display.contentHeight/2
local boxSize = 100 --px
local zoomLevel = 1
local pgroup = nil
local addToGroup = false
local noGridLines = false
local noVerticals = false
local noHorizontals = false
function init(args)
	if(args["group"]) then
		pgroup = args["group"]
		addToGroup = true
	end
	if( args["noGridLines"] == true)then
		noGridLines = true
	end
	if( args["noVerticals"] == true)then
		noVerticals = true
	end
	if( args["noHorizontals"] == true)then
		noHorizontals = true
	end
	if( args["boxSize"] > 0 ) then
		boxSize = args["boxSize"]
	end
	verticals = {}
	horizontals = {}
end
function AddOneVertical(x,vx)
	vx = math.floor(vx)
	local i = #verticals + 1
	verticals[i] = display.newLine(x,0,x,display.contentHeight)
	verticals[i].x = x
	verticals[i].y = 0
	if noGridLines == true or noVerticals == true then
		verticals[i].isVisible = false
	end	
	
	verticals[i].Tfield = display.newText("00000",0,0,native.systemFont, 16)  
	verticals[i].Tfield:setReferencePoint(display.BottomLeftReferencePoint);
	verticals[i].Tfield.x = verticals[i].x 
	verticals[i].Tfield.y = display.contentHeight
	verticals[i].Tfield.text = vx 
	verticals[i].Tfield.rotation = -90
	verticals[i].Tfield:setTextColor( 255, 0, 0 )
	if(addToGroup == true)then
		pgroup:insert(verticals[i])
		pgroup:insert(verticals[i].Tfield)
	end
end
function AddOneHorizontal(y,vy)
	local i = #horizontals+1
	vy = math.floor(vy)
	horizontals[i] = display.newLine(0,y,display.contentWidth,y)
	horizontals[i].y = y
	horizontals[i].x = 0
	if noGridLines == true or noHorizontals == true then
		horizontals[i].isVisible = false
	end			
	
	horizontals[i].Tfield = display.newText("00000",0,0,native.systemFont, 16)  
	horizontals[i].Tfield:setReferencePoint(display.BottomLeftReferencePoint);
	horizontals[i].Tfield.x = 0
	horizontals[i].Tfield.y = horizontals[i].y
	horizontals[i].Tfield.text = vy
	horizontals[i].Tfield:setTextColor( 0, 255, 0 )		
	if(addToGroup == true)then
		pgroup:insert(horizontals[i])
		pgroup:insert(horizontals[i].Tfield)
	end
	print("Adding new horizo:",i,horizontals[i].y)
end
function move(dx,dy)
	if lockMovement then
		print("VERTICALS:",display.contentWidth)
		for i =1,#verticals do
			print(verticals[i].x,"visible",verticals[i].isVisible)	
		end
		--[[print("HORIZONTALS:")
		for i =1,#horizontals do
			print(horizontals[i].y)
		end]]--
		return
	end
	CX = CX - dx
	CY = CY - dy
	--print("CX.CY",CX,CY)
	local lastCoord
	if dx ~= 0 then
		for i =1,#verticals do
			verticals[i].x = verticals[i].x + dx
			verticals[i].Tfield.x = verticals[i].Tfield.x + dx 
			if verticals[i].x < 0 or verticals[i].x > display.contentWidth then
				verticals[i].isVisible = false	
			end
		end
	end
	if  dy ~= 0 then
		for i =1,#horizontals do
			horizontals[i].y = horizontals[i].y + dy 
			horizontals[i].Tfield.y = horizontals[i].Tfield.y + dy
			if horizontals[i].y < 0 or horizontals[i].y > display.contentHeight then
				horizontals[i].isVisible = false	
			end
		end
	end
	--ensure that the grid rolls (VERTICALS)
	if( dx > 0 )then
		-- check if one grid needs to be added
		local replacer = 0
		local minDist  = display.contentWidth
		local minVpos  = 0
		for i = 1, #verticals do
			--if verticals[i].isVisible == true and ( verticals[i].x < minDist and verticals[i].x >= 0 ) then
			if ( verticals[i].x < minDist and verticals[i].x >= 0 ) then
				
				minDist = verticals[i].x
				minVpos = verticals[i].Tfield.text
			end
			if verticals[i].x > display.contentWidth or verticals[i].isVisible == false then
				replacer = i
			end
		end
		if(minDist > boxSize) then
			if minDist >= boxSize*2 then
				lockMovement = true
				print("bs",boxSize," md",minDist)
				return
			end
			minVpos = minVpos - boxSize
			if replacer > 0 then
				verticals[replacer].isVisible = true
				verticals[replacer].Tfield.isVisible = true
				verticals[replacer].Tfield.text = math.floor(minVpos)
				verticals[replacer].x = minDist - boxSize
				verticals[replacer].Tfield.x = verticals[replacer].x
			else
				AddOneVertical( minDist - boxSize , minVpos )
				print("Camera move has added a new vertical")
			end
		end
	elseif dx < 0 then
		local replacer = 0
		local minDist  = 0
		local minVpos  = 0
		for i = 1, #verticals do
			if verticals[i].isVisible == true and ( verticals[i].x > minDist and verticals[i].x <= display.contentWidth ) then
				minDist = verticals[i].x
				minVpos = verticals[i].Tfield.text
			end
			if verticals[i].x < 0 or verticals[i].x > display.contentWidth or verticals[i].isVisible == false then
				replacer = i
			end
		end
		minDist = display.contentWidth - minDist
		if minDist > boxSize then
			if minDist >= boxSize*2 then
				lockMovement = true
				print("bs",boxSize," md",minDist,"dir",dx)
				return
			end
			minVpos = minVpos + boxSize
			if replacer > 0 then
				verticals[replacer].isVisible = true
				verticals[replacer].Tfield.isVisible = true
				verticals[replacer].Tfield.text = math.floor(minVpos)
				verticals[replacer].x = display.contentWidth - minDist + boxSize
				verticals[replacer].Tfield.x = verticals[replacer].x
			else
				print("Camera move has added a new vertical")
				AddOneVertical( display.contentWidth - minDist + boxSize , minVpos )
			end
		end
	end
	--ensure that the grid rolls (HORIZONTALS)
	--[[if( dy > 0 )then  -- proof
		
		-- check if one grid needs to be added
		local replacer = 0
		local minDist  = 2147483640
		local minVpos  = 0
		for i = 1, #horizontals do
			if horizontals[i].isVisible == true and ( horizontals[i].y < minDist and horizontals[i].y >= 0 ) then
				minDist = horizontals[i].y
				minVpos = horizontals[i].Tfield.text
			end
			if horizontals[i].y > display.contentHeight or horizontals[i].isVisible == false then
				replacer = i
			end
		end
		if(minDist > boxSize) then
			if minDist >= boxSize*2 then
				lockMovement = true
				print("bs",boxSize," md",minDist)
			end
			minVpos = minVpos - boxSize
			if replacer > 0 then
				horizontals[replacer].isVisible = true
				horizontals[replacer].Tfield.isVisible = true
				horizontals[replacer].Tfield.text = math.floor(minVpos)
				horizontals[replacer].y = minDist - boxSize
				horizontals[replacer].Tfield.y = horizontals[replacer].y
			else
				AddOneHorizontal( minDist - boxSize , minVpos )
				print("Camera move has added a new horizontal dy,",dy)
			end
		end
	elseif dy <= 0 then
		
		local replacer = 0
		local minDist  = 2147483640
		local minVpos  = 0
		for i = 1, #horizontals do
			if horizontals[i].isVisible == true and ((display.contentHeight - horizontals[i].y) < minDist and (display.contentHeight - horizontals[i].y) >= 0)then
				minDist = (display.contentHeight - horizontals[i].y)
				minVpos = horizontals[i].Tfield.text
			end
			if horizontals[i].y < 0 or horizontals[i].isVisible == false then
				replacer = i
			end
		end
		if minDist > boxSize then
			if minDist >= boxSize*2 then
				lockMovement = true
				print("bs",boxSize," md",minDist)
			end
			minVpos = minVpos + boxSize
			if replacer > 0 then
				horizontals[replacer].isVisible = true
				horizontals[replacer].Tfield.isVisible = true
				horizontals[replacer].Tfield.text = math.floor(minVpos)
				horizontals[replacer].y = display.contentHeight - minDist + boxSize
				horizontals[replacer].Tfield.y = horizontals[replacer].y
			else
				print("Camera move has added a new vertical DY",dy)
				AddOneHorizontal( display.contentHeight - minDist + boxSize , minVpos )
			end
		end
	end]]--
end
function prezoom(coef)
	boxSize = boxSize * coef
	zoomLevel = zoomLevel * coef
end
function zoom(coef)
	prezoom(coef)
	redraw()
end
function tick()
	--move(0,0)
end
function redraw(FT)
	if FT == nil and zoomLevel == 1 then
		return
	end
	if FT == true then
		local nrl = math.ceil(display.contentWidth/boxSize)
		print("Nr verticals:",nrl,"previous nr verticals:",#verticals)
		for i =1,nrl do
			AddOneVertical(i*boxSize,i*boxSize)
		end
		nrl = math.ceil(display.contentHeight/boxSize)
		print("Nr verticals:",nrl,"previous nr hs:",#horizontals)
		for i=1,nrl do
			AddOneHorizontal(i*boxSize,i*boxSize)
		end
		return
	end
	print("Grid view redrawing...:bs",boxSize)
	local nrl = math.ceil(display.contentWidth/boxSize)
	print("Nr verticals:",nrl,"previous nr verticals:",#verticals)
	for i =1,#verticals do
		verticals[i].x = display.contentWidth/2+(verticals[i].x-display.contentWidth/2) * zoomLevel  
		verticals[i].isVisible = true
		verticals[i].Tfield.x = verticals[i].x
		verticals[i].Tfield.text = math.floor(CX+(tonumber(verticals[i].Tfield.text)-CX) * zoomLevel)
		if i > nrl then
			print("		ivisibling vt:",i)
			verticals[i].isVisible = false
			verticals[i].Tfield.isVisible = false
		end
	end
	
	nrl = math.ceil(display.contentHeight/boxSize)
	print("Nr verticals:",nrl,"previous nr hs:",#horizontals)
	for i=1,#horizontals do
		horizontals[i].y = display.contentHeight/2+(horizontals[i].y-display.contentHeight/2) * zoomLevel
		horizontals[i].isVisible = true
		horizontals[i].Tfield.y = horizontals[i].y
		horizontals[i].Tfield.text = math.floor(CY+(tonumber(horizontals[i].Tfield.text)-CY) * zoomLevel)
		if i > nrl then
			print("		ivisibling hr:",i)
			horizontals[i].isVisible = false
			horizontals[i].Tfield.isVisible = false
		end
	end
	
	zoomLevel = 1
	move(0,0)
end
function clear()
	for i=1,#horizontals do
		horizontals[i].Tfield:removeSelf()
		horizontals[i].Tfield = nil
		horizontals[i]:removeSelf()
		horizontals[i] = nil
	end
	for i=1,#verticals do
		verticals[i].Tfield:removeSelf()
		verticals[i].Tfield = nil
		verticals[i]:removeSelf()
		verticals[i] = nil
	end
	horizontals = nil
	verticals = nil
end