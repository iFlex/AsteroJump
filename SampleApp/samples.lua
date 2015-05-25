--------------------------------------------------------------------------------------
--[[
CBResources Sample Library

Samples:
	Vector Mini Fireworks
	Bitmap Mini Fireworks
	Inferno
	Easter Egg
	Edited Waterfall
	Fairy Dust
	Please Wait
	Edited Hyperspace
	Alien Spin
	Paint Splatter
	Bubbles
	Ice Comet
	Fire Comet
	Rainfall
--]]
--------------------------------------------------------------------------------------

local CBE=require("CBEffects.Library")
local ParticleHelper=require("CBEffects.ParticleHelper")

local either=ParticleHelper.functions.either

local samples={}

-------------
--[[
Sample: Vector Mini Fireworks

Emits a vector circle that fires and pops into a shower of smaller circles
--]]
-------------
samples[1]={title="Vector Mini Fireworks"}
samples[1].initiate=function()
	samples[1].sampleVGroup=CBE.VentGroup{
		{
			preset="sparks",
			title="explosion", -- The explosion vent
			color={{0, 255, 0}},
			build=function()
				return display.newCircle(0, 0, 3)
			end,
			onCreation=function(particle)
				particle:applyForce(math.random(-10, 10)/25, math.random(-10, 10)/25)
			end,
			perEmit=6,
			positionType="atPoint",
			onDeath=function()end,
			physics={
				velocity=2,
				gravityY=0.05, -- Just a slight bit of gravity downwards
				iterateAngle=true, -- We want to go perfectly through the angles
				autoAngle=false,
				angles={
					0, 60, 120, 180, 240, 300
				}
			}
		},
		{
			preset="sparks",
			title="pop", -- The pop that appears when a mortar shot explodes
			build=function()
				return display.newCircle(0, 0, 10)
			end,
			color={{0, 255, 0}},
			positionType="atPoint",
			perEmit=1,
			lifeSpan=300,
			fadeInTime=0,
			alpha=1,
			onDeath=function()end,
			physics={
				sizeX=0.2, -- Grow X and Y
				sizeY=0.2,
				velocity=0,
				gravityY=0
			}
		},
		{
			preset="sparks",
			title="mortar", -- Mortar vent
			color={{0, 255, 0}},
			build=function()
				return display.newCircle(0, 0, 4)
			end,
			onDeath=function(particle, vent)
				samples[1].sampleVGroup:translate("explosion", particle.x, particle.y)
				samples[1].sampleVGroup:emit("explosion") -- Move and fire off the explosion
				samples[1].sampleVGroup:translate("pop", particle.x, particle.y)
				samples[1].sampleVGroup:emit("pop") -- And the pop
			end,
			x=512,
			y=668,
			emitDelay=500,
			fadeInTime=100,
			lifeSpan=100,
			lifeStart=500,
			positionType="atPoint",
			perEmit=1,
			physics={
				angles={{60, 120}},
				
				velocity=15,
				gravityY=0.2
			}
		}
	}
	samples[1].sampleVGroup:start("mortar")
end
samples[1].stop=function()
	samples[1].sampleVGroup:destroyMaster()
	samples[1].sampleVGroup=nil
end

-------------
--[[
Sample: Bitmap Mini Fireworks

Bitmap version of Vector Mini Fireworks; done exactly the same but with images instead of circles
--]]
-------------
samples[2]={title="Bitmap Mini Fireworks"}
samples[2].initiate=function()
	samples[2].sampleVGroup=CBE.VentGroup{
		{
			preset="sparks",
			title="explosion",
			build=function()
				local shape=display.newImageRect("Textures/particle_with_trail.png", 5, 30)
				shape:setReferencePoint(display.CenterLeftReferencePoint)
				return shape
			end,
			onCreation=function(particle)
				particle:applyForce((math.random(-10, 10)/25), (math.random(-10, 10)/25))
			end,
			color={{255, 255, 0}},
			positionType="atPoint",
			perEmit=6,
			onDeath=function()end,
			rotateTowardVel=true,
			physics={
				sizeY=-0.02,
				velocity=2,
				gravityY=0.05,
				iterateAngle=true,
				autoAngle=false,
				angles={
					0, 60, 120, 180, 240, 300
				}
			}
		},
		{
			preset="sparks",
			title="pop",
			build=function()
				local shape=display.newImageRect("Textures/generic_particle.png", 30, 30)
				shape.rotation=math.random(360)
				return shape
			end,
			color={{255, 255, 0}},
			positionType="atPoint",
			perEmit=1,
			lifeSpan=300,
			fadeInTime=0,
			onDeath=function()end,
			physics={
				sizeX=0.3,
				sizeY=0.3,
				velocity=0,
				gravityY=0
			}
		},
		{
			preset="sparks",
			title="mortar",
			build=function()
				return display.newImageRect("Textures/particle_with_trail.png", 10, 20)
			end,
			onDeath=function(particle, vent)
				samples[2].sampleVGroup:translate("explosion", particle.x, particle.y)
				samples[2].sampleVGroup:emit("explosion")
				samples[2].sampleVGroup:translate("pop", particle.x, particle.y)
				samples[2].sampleVGroup:emit("pop")
			end,
			color={{255, 255, 0}},
			x=512,
			y=668,
			emitDelay=500,
			fadeInTime=100,
			lifeSpan=100,
			lifeStart=500,
			perEmit=1,
			positionType="atPoint",
			rotateTowardVel=true,
			physics={
				angles={{60, 120}},
				velocity=12,
				gravityY=0.1,
			}
		}
	}
	samples[2].sampleVGroup:start("mortar")
end
samples[2].stop=function()
	samples[2].sampleVGroup:destroyMaster()
	samples[2].sampleVGroup=nil
end

-------------
--[[
Sample: Inferno

A flame and smoke sample
--]]
-------------
samples[3]={title="Inferno"}
samples[3].initiate=function()
	samples[3].sampleVGroup=CBE.VentGroup{
		{preset="flame"}, -- Raw preset loading
		{preset="smoke"}
	}
	samples[3].sampleVGroup:startMaster()
end
samples[3].stop=function()
	samples[3].sampleVGroup:destroyMaster()
	samples[3].sampleVGroup=nil
end

-------------
--[[
Sample: Easter Egg

Twinkling sparkles like an easter egg for a game
--]]
-------------
samples[4]={title="Easter Egg"}
samples[4].initiate=function()
	samples[4].sampleVGroup=CBE.NewVent{
		preset="default",
		posRadius=120, -- Appear randomly inside of a radius of 120 px
		lifeSpan=500,
		fadeInTime=200,
		startAlpha=0,
		perEmit=3,
		emitDelay=100,
		color={{255, 255, 0}}, -- Yellow particles
		build=function()
			local size=math.random(30, 60)
			return display.newImageRect("Textures/sparkle_particle.png", size, size)
		end,
		physics={
			velocity=0 -- Not moving
		}
	}
	
	samples[4].sampleVGroup:start()
end
samples[4].stop=function()
	samples[4].sampleVGroup:destroy()
	samples[4].sampleVGroup=nil
end

-------------
--[[
Sample: Edited Waterfall

A new take on the "waterfall" preset
--]]
-------------
samples[5]={title="Edited Waterfall"}
samples[5].initiate=function()
	samples[5].sampleVGroup=CBE.NewVent{
		preset="waterfall",
		positionType="inRadius",
		posRadius=30,
		x=512,
		y=128,
		build=function()
			return display.newImageRect("CBEffects/textures/texture-1.png", 60, 30)
		end,
		perEmit=1,
		alpha=0.4,
		fadeInTime=100,
		emitDelay=1,
		physics={
			xDamping=3,
			sizeX=0,
			sizeY=0.2, -- This waterfall grows Y so that it looks more like a "falling" effect
			maxY=5,
			gravityY=0.2,
			velocity=0,
			angles={{260, 280}}
		}
	}
	
	samples[5].sampleVGroup:start()
end
samples[5].stop=function()
	samples[5].sampleVGroup:destroy()
	samples[5].sampleVGroup=nil
end

-------------
--[[
Sample: Fairy Dust

Sparkles that float down with gravity
--]]
-------------
samples[6]={title="Fairy Dust"}
samples[6].initiate=function()
	samples[6].sampleVGroup=CBE.NewVent{
		preset="sparks",
		positionType="atPoint",
		build=function()
			local size=math.random(40, 70) -- Random sized particles
			return display.newImageRect("Textures/sparkle_particle.png", size, size)
		end,
		onDeath=function()end, -- Original "sparks" preset changes the perEmit onDeath, so we need to overwrite it
		perEmit=1,
		fadeInTime=100,
		emitDelay=1,
		physics={
			xDamping=1.02, -- Lose their X-velocity quickly
			gravityY=0.1,
			velocity=3
		}
	}

	samples[6].sampleVGroup:start()
end
samples[6].stop=function()
	samples[6].sampleVGroup:destroy()
	samples[6].sampleVGroup=nil
end

-------------
--[[
Sample: Please Wait

An animated "loading circle"
--]]
-------------
samples[7]={title="Please Wait"}
samples[7].initiate=function()
	samples[7].sampleVGroup=CBE.NewVent{
		preset="default",
		positionType="fromPointList",
		x=512,
		y=384,
		pointList={{60, 60}, {13, 84}, {-39, 76}, {-76, 39}, {-84, -13}, {-60, -60}, {-13, -84}, {39, -76}, {76, -39}, {84, 13}}, -- A circle of points
		iteratePoint=true, -- Go through the points one by one
		build=function()
			return display.newImageRect("Textures/generic_particle.png", 60, 60)
		end,
		perEmit=1,
		fadeInTime=150,
		startAlpha=0,
		lifeSpan=800,
		lifeStart=0,
		emitDelay=100,
		physics={
			gravityY=0,		
			velocity=0 -- Don't move
		}
	}
	samples[7].sampleVGroup:start()
end
samples[7].stop=function()
	samples[7].sampleVGroup:destroy()
	samples[7].sampleVGroup=nil
end

-------------
--[[
Sample: Edited Hyperspace

A new take on the "hyperspace" preset; there aren't many changes from the original
--]]
-------------
samples[8]={title="Edited Hyperspace"}
samples[8].initiate=function()
	samples[8].sampleVGroup=CBE.NewVent{
		preset="hyperspace",
		build=function()
			return display.newImageRect("Textures/generic_particle.png", 10, 10)
		end,
		positionType="atPoint",
		perEmit=3,
		lifeSpan=1500,
		lifeStart=750,
		fadeInTime=750,
		endAlpha=0,
		alpha=1,
		physics={
			linearDamping=1.001,
			sizeX=0.5
		}
	}
	
	samples[8].sampleVGroup:start()
end
samples[8].stop=function()
	samples[8].sampleVGroup:destroy()
	samples[8].sampleVGroup=nil
end

-------------
--[[
Sample: Alien Spin

Green and yellow glowing dots that spin alternately from both sides of the screen
--]]
-------------
samples[9]={title="Alien Spin"}
samples[9].initiate=function()
	samples[9].sampleVGroup=CBE.NewVent{
		preset="wisps",
		x=0,
		y=0,
		positionType="fromPointList",
		pointList={{128, 768}, {896, 768}},
		iteratePoint=true, -- Alternate from both sides of the screen
		build=function()
			return display.newImageRect("Textures/generic_particle.png", 60, 60)
		end,
		onUpdate=function(particle)
			particle:applyForce((512-particle.x)*0.001, 0) -- Pull towards the middle
		end,
		perEmit=2, -- One from both sides each time it's emitted
		emitDelay=500,
		fadeInTime=100,
		lifeSpan=500,
		lifeStart=6500,
		endAlpha=0,
		physics={
			xDamping=1.01, -- Lose velocity slowly
			gravityY=0,
			autoAngle=false, -- We don't need to have a lot of angles, just...
			angles={90} -- ...going straight up
		}
	}

	samples[9].sampleVGroup:start()
end
samples[9].stop=function()
	samples[9].sampleVGroup:destroy()
	samples[9].sampleVGroup=nil
end

-------------
--[[
Sample: Paint Splatter

The name says it all
--]]
-------------
samples[10]={title="Paint Splatter"}
samples[10].initiate=function()
	samples[10].sampleVGroup=CBE.NewVent{
		preset="default",
		color={{255, 255, 0}, {255, 0, 0}, {0, 0, 255}, {0, 255, 0}, {255, 0, 255}},
		build=function()
			local size=math.random(600, 1200)/10
			return display.newImageRect(either{"Textures/splat.png", "Textures/splat2.png"}, size, size)
		end,
		onUpdate=function(particle)
			if particle._numUpdates>=3 then
				particle._particlephysics.rotateToVel=false -- Turn it off because of unexpected behavior from no velocity; it does some jittery rotation at the very end without this
			end
		end,
		perEmit=12,
		positionType="inRadius",
		emitDelay=2500,
		fadeInTime=100,
		lifeSpan=2500,
		lifeStart=500,
		endAlpha=0,
		rotateTowardVel=true,
		physics={
			iterateAngle=true, -- We want to go all the way around
			autoAngle=false,
			angles={0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330}, -- From all directions
			linearDamping=1.1,
			velocity=7,
			gravityY=0
		}
	}
	
	samples[10].sampleVGroup:start()
	samples[10].sampleVGroup:emit()
end
samples[10].stop=function()
	samples[10].sampleVGroup:destroy()
	samples[10].sampleVGroup=nil
end

-------------
--[[
Sample: Bubbles

A simple bubble vent

Note: The bubble image was sourced from http://developer.coronalabs.com/code/simple-bubble-popper by TheRealTonyK. Thanks!
--]]
-------------
samples[11]={title="Bubbles"}
samples[11].initiate=function()
	samples[11].sampleVGroup=CBE.NewVent{
		preset="default",
		color={{255, 255, 255}},
		build=function()
			local size=math.random(600, 1200)/20
			return display.newImageRect("Textures/bubble.png", size, size)
		end,
		y=512,
		perEmit=1,
		positionType="inRadius",
		emitDelay=50,
		fadeInTime=100,
		lifeSpan=500,
		lifeStart=500,
		endAlpha=0,
		physics={
			sizeX=-0.01,
			sizeY=-0.01,
			angles={{0, 360}}, -- All directions, angles 0-360
			velocity=3,
			xDamping=1.1,
			gravityY=-0.1 -- Bubbles get pulled upwards
		}
	}
	
	samples[11].sampleVGroup:start()
end
samples[11].stop=function()
	samples[11].sampleVGroup:destroy()
	samples[11].sampleVGroup=nil
end

-------------
--[[
Sample: Ice Comet

A blue and white icy looking comet effect
--]]
-------------
samples[12]={title="Ice Comet"}
samples[12].initiate=function()
	samples[12].sampleVGroup=CBE.VentGroup{
		{
			preset="burn",
			color={{180, 180, 255}}, -- Ice blue
			build=function()
				local size=math.random(90, 120)
				return display.newImageRect("Textures/generic_particle.png", size, size)
			end,
			onCreation=function()end, -- Original "burn" preset changes color onCreation
			perEmit=1,
			positionType="inRadius",
			posRadius=10,
			emitDelay=50,
			fadeInTime=500,
			lifeSpan=1000,
			lifeStart=500,
			endAlpha=0,
			physics={
				sizeX=-0.005,
				sizeY=-0.005,
				autoAngle=false,
				angles={135},
				velocity=3,
				xDamping=1,
				gravityY=-0.01,
				gravityX=-0.01
			}
		},
		{
			preset="burn",
			title="shield",
			color={{180, 180, 255}},
			build=function()
				local particle=display.newImageRect("Textures/shield.png", 120, 190)
				particle:setReferencePoint(display.TopCenterReferencePoint)
				return particle
			end,
			onCreation=function()end, -- Same here
			perEmit=1,
			positionType="inRadius",
			posRadius=10,
			emitDelay=50,
			fadeInTime=100,
			lifeSpan=1000,
			lifeStart=500,
			alpha=0.5,
			propertyTable={
				rotation=135,
				blendMode="add"
			},
			endAlpha=0,
			physics={
				sizeX=-0.005,
				sizeY=-0.005,
				autoAngle=false,
				angles={135},
				velocity=0,
				xDamping=1,
				gravityY=0,
				gravityX=0
			}
		}
	}
	samples[12].sampleVGroup:startMaster()
end
samples[12].stop=function()
	samples[12].sampleVGroup:destroyMaster()
	samples[12].sampleVGroup=nil
end

-------------
--[[
Sample: Fire Comet

A reddish-yellowish-orangish burning & smoking comet effect
--]]
-------------
samples[13]={title="Fire Comet"}
samples[13].initiate=function()
	samples[13].sampleVGroup=CBE.VentGroup{
		{
			preset="burn",
			color={{255, 111, 0}, {255, 70, 0}}, -- Reddish-orange colors
			build=function()
				local size=math.random(120, 140) -- Particles are a bit bigger than ice comet particles
				return display.newImageRect("Textures/generic_particle.png", size, size)
			end,
			onCreation=function()end, -- See the note for the ice comet
			perEmit=2,
			positionType="inRadius",
			posRadius=20,
			emitDelay=50,
			fadeInTime=500,
			lifeSpan=500, -- Particles are removed sooner than the ice comet
			lifeStart=500,
			endAlpha=0,
			physics={
				sizeX=-0.01,
				sizeY=-0.01,
				autoAngle=false,
				angles={135},
				velocity=3,
				xDamping=1,
				gravityY=-0.01,
				gravityX=0.01
			}
		},
		{
			preset="burn", -- Not the smoke preset because it's just about the same as the burn effect, just with a few changes
			title="smoke", -- The smoke vent
			color={{100}},
			build=function()
				local size=math.random(120, 140)
				return display.newImageRect("Textures/smoke.png", size, size)
			end,
			propertyTable={blendMode="screen"}, -- Lighten the comet slightly
			onCreation=function()end,
			perEmit=1,
			y=384,
			x=512,
			positionType="inRadius",
			posRadius=20,
			emitDelay=50,
			fadeInTime=500,
			lifeSpan=500,
			lifeStart=500,
			alpha=0.5,
			endAlpha=0,
			physics={
				sizeX=-0.01,
				sizeY=-0.01,
				autoAngle=false,
				angles={135},
				velocity=3,
				xDamping=1,
				gravityY=-0.01,
				gravityX=0.01
			}
		}
	}
	samples[13].sampleVGroup:startMaster()
end
samples[13].stop=function()
	samples[13].sampleVGroup:destroyMaster()
	samples[13].sampleVGroup=nil
end


-------------
--[[
Sample: Rainfall

A rainfall with raindrop "plinks" at the end of each particle's life time.
--]]
-------------
samples[14]={title="Rainfall"}
samples[14].initiate=function()
	samples[14].sampleVGroup=CBE.VentGroup{
		{
			preset="rain",
			title="drop", -- The "plink" effect at the end of each raindrop
			positionType="atPoint",
			build=function()
				return display.newImageRect("Textures/generic_particle.png", 20, 5)
			end,
			alpha=0.5,
			fadeInTime=0,
			lifeStart=0,
			lifeSpan=100,
			endAlpha=0,
			perEmit=1,
			physics={
				maxX=30,
				sizeX=1, -- Grow X like a ripple
				velocity=0 -- Don't move
			}
		},
		{
			preset="rain",
			title="rain",
			scale=1,
			positionType="inRect",
			rectLeft=0,
			rectTop=-100,
			rectWidth=display.contentWidth,
			rectHeight=100,
			build=function()
				return display.newImageRect("Textures/generic_particle.png", 10, math.random(70,90))
			end,
			alpha=0.5,
			onDeath=function(p, v, c)
				samples[14].sampleVGroup:translate("drop", p.x, p.y)
				samples[14].sampleVGroup:emit("drop")
			end,
			propertyTable={
				rotation=10
			},
			lifeStart=425,
			lifeSpan=50,
			endAlpha=0,
			perEmit=2,
			physics={
				autoAngle=false,
				angles={265},
				velocity=24
			}
		}
	}
	samples[14].sampleVGroup:start("rain")
end
samples[14].stop=function()
	samples[14].sampleVGroup:destroyMaster()
	samples[14].sampleVGroup=nil
end

return samples