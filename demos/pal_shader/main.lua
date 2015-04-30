local Shader;
local sceneCanvas;
local graphicCanvas;
local debugCanvas;

local testimg = love.graphics.newImage("graphic_steps.png")
--[[WHERE:
	graphic_steps			[0,    1,   2,   3]
	graphic_ceil_x4_1-4		[64, 128, 192, 255]		math.ceil((x/4)*255)	for 1-4
	graphic_ceil_x4_0-3		[0,   64, 128, 192]		math.ceil((x/4)*255)	for 0-3
	graphic_floor_x4_0-3	[0,   64, 128, 191]		math.floor((x/4)*255)	for 0-3
]]

local baseimg = love.graphics.newImage("background.jpg")
local palimg = love.graphics.newImage("pal_contrast.png") 

local num_pals = palimg:getHeight()
local pal_depth = palimg:getWidth()

local basedims = {testimg:getDimensions()} 

local draw_coords = {}
for i=1,num_pals do
	table.insert(draw_coords, {basedims[1]*i-basedims[1], basedims[2]*i-basedims[2]})
end

local exportTimer = 0

function love.load()
	love._openConsole()
	
	print("paldepth:", (1/pal_depth))
	print("paltable:")
	for k,v in pairs(draw_coords) do
		print(k, "=", (k-1)/(num_pals-1))
	end
	 
	Shader = love.graphics.newShader[[
extern Image ColorTable;
extern number PalIndex;
extern number NumPals;
extern number PalDepth;

float round(float f, float prec){
	return(floor(f*(1.0/prec) + 0.5)/(1.0/prec));
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords){
	//where texture and texture_coords correspond to the individual sprites
	
	vec4 pcolor = Texel(texture, texture_coords,1.0);
	vec4 ncolor = Texel(ColorTable, 
		vec2(
			((pcolor.r*255)/(PalDepth-1)),
			//(pcolor.r*255)-(1/PalDepth),
			//pcolor.r*255+(1/255),
			//step(0.33,pcolor.r),
			//pcolor.r,
			//1
			//(0/3)*255
			//(pcolor.r*255)-(1/PalDepth), 
			//step(pcolor.r, PalDepth),
			
			(PalIndex-1)/(NumPals-1)
			// sweet baby jesus this is a lot of failed formulas
			//(PalIndex-1)*(1/NumPals)-1 //-1)/(NumPals-1)
			//clamp(pcolor.r, PalDepth*(pcolor.r-PalDepth),PalDepth*(pcolor.r)),
			//round(((PalIndex-1)/(NumPals-1)),0.001)
			//min((PalIndex-1)*255,((PalIndex-1)/(NumPals-1))*256)
			//wholeround((PalIndex-1)/(NumPals-1))
			//clamp(((PalIndex-1)/(NumPals-1)), (PalIndex-1)/NumPals, (PalIndex)/NumPals)
		)
	);
	return ncolor; 
}
		]]
	
	Shader:send("ColorTable", palimg) 
	Shader:send("NumPals", num_pals)
	Shader:send("PalDepth", pal_depth)

	sceneCanvas = love.graphics.newCanvas(love.window.getWidth(), love.window.getHeight())
	graphicCanvas = love.graphics.newCanvas(basedims[1], basedims[2]) 
	debugCanvas = love.graphics.newCanvas(basedims[1]*(num_pals/2), basedims[2]*(num_pals/2))
end

local function deployModified(itodraw, dex, x, y)
	Shader:send("PalIndex", dex) --(dex-1)/(num_pals-1)
	--((dex+1)/num_pals)-(1/num_pals)
	love.graphics.setShader(Shader);
	love.graphics.draw(itodraw, x, y)
	love.graphics.setShader();
end

function love.draw()
	--love.graphics.setColor(255,255,255,255)
	love.graphics.clear()
	sceneCanvas:clear()
	love.graphics.setCanvas(sceneCanvas)
	love.graphics.draw(baseimg, 0, 0)
	
	-- place the image on the special graphic canvas
	for i=1, #draw_coords do
		graphicCanvas:clear()
		graphicCanvas:renderTo(function() deployModified(testimg, i) end)
		love.graphics.draw(graphicCanvas, draw_coords[i][1], draw_coords[i][2])  -- deploy the graphic to the sceneCanvas
	end
	
	-- return to main and draw the composite
	love.graphics.setCanvas()
	love.graphics.draw(sceneCanvas)
end

local lastModified = love.filesystem.getLastModified("main.lua")


function love.update(dt)
	------------To make the code update in real time
	if(love.filesystem.getLastModified("main.lua") ~= lastModified)then 
		local testFunc = function()
			love.filesystem.load('main.lua')
		end
		local test,e = pcall(testFunc)
		if(test)then 
		 	love.filesystem.load('main.lua')()
		 	love.run()
		else 
			print(e)
		end
		lastModified = love.filesystem.getLastModified("main.lua")
	end
	
	if(love.keyboard.isDown("x") and exportTimer <= 0)then
		debugCanvas:renderTo(function() deployModified(testimg, 1, draw_coords[1][1], 0) end)
		debugCanvas:renderTo(function() deployModified(testimg, 2, draw_coords[2][1], 0) end)
		debugCanvas:renderTo(function() deployModified(testimg, 3, draw_coords[1][1], draw_coords[2][2]) end)
		debugCanvas:renderTo(function() deployModified(testimg, 4, draw_coords[2][1], draw_coords[2][2]) end)
		debugCanvas:getImageData():encode("debug.png")
		love.graphics.newScreenshot():encode("screenshot.png")
		exportTimer = 10
	end
	
	if exportTimer >= 0 then
		exportTimer = exportTimer-dt
	end
	-----------Get average FPS
	--[[c2 = c2 + 1;
	sum = sum + dt;
	if(sum > 1)then 
		sum = sum / c2;
		fps = math.floor(1/sum);
		c2 = 0;
		sum = 0;
	end]]
	-- DISREGARD AVERAGES, DO THIS INSTEAD
	love.window.setTitle(love.timer.getFPS())
end



