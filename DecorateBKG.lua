module(..., package.seeall)  
local starsArray = {};

local grp = nil
local nebula 
local directionX = 1;
local directionY = 1;
local nrStars = 100;
local maxSize = display.contentWidth * 0.05;
local moduleOperational = false;
local selfTick = false;
local completeCleanUponExit = true;
local addToParentGroup = true

function initDecorator(ParetGroup,args)
 moduleOperational = false;
 selfTick = false;
 completeCleanUponExit = true;

	starsArray = {}
	
	group = ParentGroup
	filename = "nebula1.jpg"
	if( args["filename"] ) then
		filename = args["filename"]
	end
	if( args["noGroup"] == true) then
		addToParentGroup = false
	end
	
	nebula = display.newImage(filename);
	nebula.width = display.contentHeight*2.1;
	nebula.height = nebula.width;
	nebula.x = display.contentWidth/2;
	nebula.y = display.contentHeight/2;
	nebula.alpha = 0.3;
	nebula.speed = 0.1;
	--tint the nebula if needed
	if( args["tint"] ) then
		nebula:setFillColor( args["tint"]["r"],args["tint"]["g"],args["tint"]["b"], 1)--args["tint"]["alpha"] )
	end
	if( args["speed"] ) then
		nebula.speed = args["speed"];
	end	
	if( args["alpha"] ) then
		nebula.alpha = args["alpha"];
	end	
	if( args["noClean"] ) then
		completeCleanUponExit = false;
	end	
	
	if addToParentGroup then
		group:insert(nebula)
	end
	
	if( args["nrStars"] ) then
		nrStars = args["nrStars"];
	end
	
	for i=1,nrStars do
		local star = display.newImage( "decor_star.png");
		star.x = 0;
		star.y = 0;
		star.width  = maxSize;
		star.height = maxSize;
		star.alpha = 0;
		star.isVisible = false;
		starsArray[#starsArray +1] = {starProperties=star, wait=1};
		if addToParentGroup then
			group:insert(star)
		end
	end
	
	if(args["noNebula"]) then
		nebula.isVisible = false;
	end
	
	moduleOperational = true;
	if(args["selfTick"]) then
		selfTick = true;
		timer.performWithDelay(100/6,animate,1);
	end
end
function toBack()
	for k,v in pairs(starsArray) do
		v.starProperties:toBack()
	end
	nebula:toBack()
end
function moveNebula()

	if (nebula.x < 0) then
		directionX = 1;
	elseif (nebula.x > display.contentWidth) then
		directionX = -1;
	end

	if (nebula.y < 0 ) then
		directionY = 1;
	elseif (nebula.y > display.contentHeight) then
		nebula.y = display.contentHeight;
		directionY = -1;
	end

	nebula.x = nebula.x + directionX*nebula.speed;
	nebula.y = nebula.y + directionY*nebula.speed;
end

-- CREATE STAR FUNCTION
local function createStar()

	local randX = math.random(0, display.contentWidth );
	local randY = math.random(0, display.contentHeight);
	local randTimer = math.random(3, 30);
	local randSize = math.random(1, 7);
	
	for k,v in pairs(starsArray) do
		if v["starProperties"].isVisible == false then
			v["starProperties"].isVisible = true
			v["starProperties"].alpha = 0.0
			v["starProperties"].x = randX
			v["starProperties"].y = randY
			v["starProperties"].width  = maxSize/randSize
			v["starProperties"].height = maxSize/randSize
			v["wait"] = randTimer
			break
		end
	end
	
end
function trigger()
	if( moduleOperational == false and selfTick ) then
		timer.performWithDelay(100/6,animate,1);
	end
	moduleOperational = true
end
function clean()
	if moduleOperational then
		moduleOperational = false;
		if completeCleanUponExit then
			for k,v in pairs(starsArray) do
				v["starProperties"]:removeSelf();
				v = nil;
			end
			nebula:removeSelf()
			print("Cleared decorator");
		end
	end
end
-- ANIMATE FUNCTION
function animate()
	if not moduleOperational then
		return
	end
	local fadeInRate = 0.01;
	local fadeOutRate = 0.01;

	createStar();
	moveNebula();
	
	for k,v in pairs(starsArray) do
		if v["starProperties"].isVisible then
			-- fade in
			if (v["starProperties"].alpha < 1) then
				if( v["starProperties"].alpha + fadeInRate > 1 ) then
					v["starProperties"].alpha = 1
				else
					v["starProperties"].alpha = v["starProperties"].alpha + fadeInRate;
				end
			else
				v["wait"] = v["wait"] - 1;
			end

			-- fade out
			if (v["wait"] == 0) then
				if (v["starProperties"].alpha > 0) then
					if v["starProperties"].alpha - fadeOutRate < 0 then
						v["starProperties"].alpha = 0
					else
						v["starProperties"].alpha = v["starProperties"].alpha - fadeOutRate;
					end
				end
				if  (v["starProperties"].alpha == 0) then
					v["starProperties"].isVisible = false
				end
			end
		end
	end
	if(selfTick) then
		timer.performWithDelay(100/6,animate,1);
	end
end