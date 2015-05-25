--
--  Particle effects handler
--
module(..., package.seeall) 
local CBE = require("CBEffects.Library")
local ParticleHelper = require("CBEffects.ParticleHelper")
local samples = {}
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
			x=display.contentWidth/2,
			y=display.contentHeight,
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


local dust = {title="Fairy Dust"}
dust.initiate=function()
	dust.sampleVGroup=CBE.NewVent{
		title = "dust",
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

	dust.sampleVGroup:start()
end

dust.stop=function()
	dust.sampleVGroup:destroy()
	dust.sampleVGroup=nil
end

local fireComet={title="Fire Comet"}
fireComet.initiate=function()
	fireComet.sampleVGroup=CBE.VentGroup{
		{
			title="Fire Comet",
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
			y=display.contentHeight/2,
			x=display.contentWidth/2,
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
			y=display.contentHeight/2,
			x=display.contentWidth/2,
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
	fireComet.sampleVGroup:startMaster()
end
fireComet.stop=function()
	fireComet.sampleVGroup:destroyMaster()
	fireComet.sampleVGroup=nil
end
samples[2].initiate();
fireComet.initiate();