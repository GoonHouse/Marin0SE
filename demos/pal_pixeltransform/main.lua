local Shader;
local sceneCanvas;
local graphicCanvas;
local debugCanvas;

local testimg = love.image.newImageData("graphic_steps.png")
--[[WHERE:
	graphic_steps			[0,    1,   2,   3]
	graphic_ceil_x4_1-4		[64, 128, 192, 255]		math.ceil((x/4)*255)	for 1-4
	graphic_ceil_x4_0-3		[0,   64, 128, 192]		math.ceil((x/4)*255)	for 0-3
	graphic_floor_x4_0-3	[0,   64, 128, 191]		math.floor((x/4)*255)	for 0-3
]]
palimg = love.image.newImageData("pal_contrast.png")
palette = {}
for y=1,palimg:getHeight() do
	palette[y] = {}
	for x=1,palimg:getWidth() do
		palette[y][x]={palimg:getPixel(x-1,y-1)}
	end
end
g_pal = 1
g_pal_depth = palimg:getWidth()
function palTransform(x, y, r, g, b, a)
	--print(x, y, r)
	return unpack(palette[g_pal][r+1])
end

local baseimg = love.graphics.newImage("background.jpg")


local num_pals = palimg:getHeight()
local pal_depth = palimg:getWidth()

local basedims = {testimg:getDimensions()} 

local draw_coords = {}
local draw_images = {}

local exportTimer = 0

function love.load()
	love._openConsole()
	
	for i=1,num_pals do
		table.insert(draw_coords, {basedims[1]*i-basedims[1], basedims[2]*i-basedims[2]})
		local decimg = love.image.newImageData("graphic_steps.png")
		g_pal = i
		decimg:mapPixel(palTransform)
		table.insert(draw_images, love.graphics.newImage(decimg))
	end
	
end

function love.draw()
	love.graphics.setColor(255,255,255,255)
	love.graphics.clear()
	love.graphics.draw(baseimg, 0, 0)
	
	for i=1, #draw_coords do
		love.graphics.draw(draw_images[i], draw_coords[i][1], draw_coords[i][2])
	end
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
		love.graphics.newScreenshot():encode("debug.png")
		exportTimer = 10
	end
	
	if exportTimer >= 0 then
		exportTimer = exportTimer-dt
	end
	
	love.window.setTitle(love.timer.getFPS())
end