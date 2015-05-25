------------------
--[[
CBEffects Sample: Particles With Box2D Physics

Creates a snowfall with Box2D physical snow and a bullet that launches across the screen, colliding with it. When the bullet hits the ground, it resets it's position.

View it thus:

require("CBResources.samples.Box2D")

It is most recommended to do this on a completely blank scene.
--]]
------------------
local CBE=require("CBEffects.Library")

local physics=require("physics")
physics.start()
--physics.setDrawMode("hybrid")

local ground=display.newRect(0, 0, display.contentWidth, 40)
ground.x, ground.y=display.contentCenterX, display.contentHeight-20
ground:setFillColor(255, 0, 255)

local bullet=display.newRoundedRect(0, 0, 50, 10, 8)
bullet.x, bullet.y=100, display.contentCenterY

local function wrapBullet()
	if bullet.x>display.contentWidth+25 then
		bullet.x=-25
		bullet:applyForce(100, -20, bullet.x, bullet.y)
	end
end
Runtime:addEventListener("enterFrame", wrapBullet)

local function gCollision(self, event)
	if event.other==bullet then
		timer.performWithDelay(0, function()
			bullet.x, bullet.y=100, display.contentCenterY
			bullet:applyForce(5000, 0, bullet.x, bullet.y)
		end)
	end
end
ground.collision=gCollision

local collisionStuff=CBE.VentGroup{
	{
		preset="snow",
		endAlpha=1,
		perEmit=1,
		onCreation=function(p, v)
			physics.addBody(p, {radius=p.width/2, bounce=0.3})
		end
	}
}

local function initiate()
	physics.addBody(ground, "kinematic", {})
	physics.addBody(bullet, {bounce=0.3})
	bullet.isBullet=true
	bullet:applyForce(5000, 0, bullet.x, bullet.y)
	collisionStuff:startMaster()
	collisionStuff:get("snow").pPhysics.pause()
	ground:addEventListener("collision", ground)
end
initiate()