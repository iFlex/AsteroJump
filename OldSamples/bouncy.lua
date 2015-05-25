------------------
--[[
CBEffects Sample: Bouncy

Has a force-applying field that makes circular particles bounce up and down.

View it thus:

require("CBResources.samples.bouncy")

It is most recommended to do this on a completely blank scene.
--]]
------------------
local CBE=require("CBEffects.Library")

local fieldGroup
local ventGroup

ventGroup=CBE.VentGroup{
	{
		--Since there is no preset parameter, it automatically chooses "default"
		build=function()
			return display.newCircle(0, 0, math.random(4,10)) -- Random sized circles as particles
		end,
		title="bouncers", -- Title it
		positionType="alongLine", -- Along a line
		lifeSpan=0, -- We just want them to click out, instead of fade out.
		emitDelay=1000, -- Dela
		lifeStart=25000,
		perEmit=1,
		point1={0,50},
		propertyTable={
			force=-500
		},
		point2={display.contentWidth,50},
		physics={
			velocity=8,
			angles={
				{270,270}
			},
			gravityY=9.8,
			relativeToSize=true,
		}
	}
}
ventGroup:start("bouncers")

fieldGroup=CBE.FieldGroup{
	{
		preset="out",
		title="ground",
		targetVent=ventGroup:get("bouncers"),
		shape="rect",
		x=0,
		y=display.contentHeight-80,
		rectWidth=display.contentWidth,
		rectHeight=80,
		onCollision=function(p,f)
			p:setLinearVelocity(0, 0)
			p:applyForce(0, p.force)
			if p.force>=0 then
				p.bodyType="kinematic"
				p:setLinearVelocity(0,0)
			else
				p.force=p.force+20		
			end
		end
	}
}
fieldGroup:startMaster()