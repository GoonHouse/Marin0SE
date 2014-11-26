--[[@NOTE: This is a lua file so that I can take advantage of [ZeroBrane's markdown](http://studio.zerobrane.com/doc-markdown-formatting.html).
	This document illustrates the significant changes between Mari0 SE and Marin0 SE.
	This will only point out changes crucial to getting old Mari0 mappacks working
	so that a converter of some sort can be made.
]]

--[[
	# Entities
	some names got changed
]]

--[[
	# Tiles -> Tiled Tileset
	
	* Images 
]]

tilequads = {}
rgblist = {}

function legacy_tilegen(filename)
	-- presumes filenameimg is already a loaded asset by imagelist
	
	local imgdata = love.image.newImageData(filename..".png")
	local imgwidth, imgheight = imgdata:getWidth(), imgdata:getHeight()
	local width = math.floor(imgwidth/17)
	local height = math.floor(imgheight/17)
	
	for y = 1, height do
		for x = 1, width do
			table.insert(tilequads, quad:new(_G[filename.."img"], imgdata, x, y, imgwidth, imgheight))
			local r, g, b = getaveragecolor(imgdata, x, y)
			table.insert(rgblist, {r, g, b})
		end
	end
	_G[filename.."count"] = width*height
end