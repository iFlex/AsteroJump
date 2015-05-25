-- Miscellaneous helper library to keep main.lua clean

local extras = {}

local font = "TrebuchetMS"

function extras.createStatusText(text, x, y, parent, size)
	local size = size or 30
	
	local st = display.newText(text, 0, 0, font, size)
	st.x, st.y = x, y
	st:setTextColor(255, 255, 0)
	parent:insert(st)
	
	return st
end

function extras.createStatusBkg(w, h, x, y, parent)
	local bkg = display.newRoundedRect(0, 0, w, h, 10)
	bkg.x, bkg.y = x, y
	bkg:setFillColor(0, 0, 0)
	bkg.strokeWidth = 6
	bkg:setStrokeColor(255, 255, 0)
	parent:insert(bkg)
	
	return bkg
end

return extras