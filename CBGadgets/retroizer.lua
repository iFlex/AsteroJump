--[[
CBGadget: Retroizer

Collects a vent data table and converts it into 8-bit retro style.

Usage:

---------------------
local CBE=require("CBEffects.Library")

local retroizer=require("retroizer")

local myVentParams={ -- Vent parameters, not VentGroup parameters
	preset="fountain",
	physics={
		velocity=24,
		sizeX=0,
		sizeY=0
	}
}

local retroParams=retroizer.retroize{
	data=myVentParams, -- Original vent data
	cellSize=24, -- Width/height particles will be clamped to
	particleSize=24 -- Width/height of each particle
}

local VentGroup=CBE.VentGroup{
	retroParams -- Use retro parameters in VentGroup
}
VentGroup:startMaster()
---------------------
--]]

local retroizer={}

local ParticleHelper=require("CBEffects.ParticleHelper")
local presets=ParticleHelper.presets.vents

local function spaceToGrid(x,y,size) return math.round((x==0 and 1 or x)/size), math.round((y==0 and 1 or y)/size) end


function retroizer.retroize(params)
	local particleSize
	local cellSize

	local preset
	local build

	preset=presets[params.data.preset or "default"] or presets["default"]

	build=params.data.build or preset.build

	if not params.particleSize then
		local p=build()
		particleSize=p.width
		display.remove(p)
		p=nil
	else
		particleSize=params.particleSize
	end

	cellSize=params.cellSize or particleSize

	local phys=params.data.physics or preset.physics
	local rot=params.data.rotation or preset.rotation

	phys.angularVelocity=0
	rot.towardVel=false

	local prevOnCreation=params.data.onCreation or preset.onCreation
	local prevOnUpdate=params.data.prevOnUpdate or preset.onCreation

	params.data.build=function()
		return display.newRect(0, 0, particleSize, particleSize)
	end

	params.data.onCreation=function(p, v, c)
		p.cx, p.cy=p.x, p.y

		prevOnCreation(p, v, c)
	end

	params.data.onUpdate=function(p, v, c)
		p.cx, p.cy=p.cx+(p.velX*v.scale), p.cy+(p.velY*v.scale)
		local X, Y=spaceToGrid(p.cx, p.cy, cellSize)
		p.x, p.y=X*cellSize, Y*cellSize

		prevOnUpdate(p, v, c)
	end

	return params.data
end

return retroizer