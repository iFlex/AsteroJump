------------------
--[[
CBEffects Sample: Grid Wrapping onUpdate

Uses onUpdate parameter to wrap two particle vents X and Y to a grid.

CAUTION: May cause dizziness or disorientation watching it :)

View it thus:

require("CBResources.samples.onUpdate")

It is most recommended to do this on a completely blank scene.
--]]
------------------
local CBE=require("CBEffects.Library")

local VentGroup

VentGroup=CBE.VentGroup{
	{
		preset="lasergun", -- Load the "LaserGun" preset
		title="yAxis",
		x=display.contentWidth, -- At the edge of the screen
		y=-100,
		lifeSpan=4200,
		onUpdate=function(p, v)
			if p.y>display.contentHeight+100 then -- Check if the particle is past the screen's edge
				p.y=-100 -- Reset the particle's Y
				p.x=p.x-70 -- Move the particle backwards a bit
			end 
		end,
		propertyTable={
			rotation=90 -- The particle's rotation starts out as 90, as originally the LaserGun preset goes left-right
		},
		physics={
			autoAngle=false,
			angles={
				270 -- Fire straight downwards
			}
		}
	},
	{
		preset="lasergun",
		title="xAxis", -- It is ALWAYS important to title your vents, even if you're only going to :startMaster the VentGroup
		x=-100,
		y=0,
		lifeSpan=4000,
		onUpdate=function(p, v)
			if p.x>display.contentWidth+100 then -- This time check the X
				p.y=p.y+70
				p.x=-100
			end 
		end,
		-- Note how we don't need a propertyTable to set rotation now, because we're going left-right.
		physics={
			autoAngle=false,
			angles={
				0 -- Go right
			}
		}
	}
}
VentGroup:startMaster() -- Start the VentGroup