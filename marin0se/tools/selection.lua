local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, editortool)
local thisclass = _G[classname]

function thisclass:init()
	editortool.init(self, classname)
	self.dragdraw = false
	self.selecting = false
end

function thisclass:update(dt)
	-- we can always show our status, probably
	local x,y = getMouseTile(mouse.getX(), mouse.getY()-8*scale)
	self.status="("..x..","..y..")"
	
	if self:canFire() then
		selectionstart()
	elseif self:canUnfire() then
		selectionend()
	end
end

function thisclass:draw()
	editortool.draw(self)
	
	if selectiondragging or selectionwidth then
		local x, y, width, height
		
		x, y = selectionx, selectiony
		if selectiondragging then
			width, height = mousex-selectionx, mousey-selectiony
		else
			width, height = selectionwidth, selectionheight
		end
		
		if width < 0 then
			x = x + width
			width = -width
		end
		if height < 0 then
			y = y + height
			height = -height
		end
		
		if selectiondragging then
			drawrectangle(x/scale, y/scale, width/scale, height/scale)
		end
		
		local selectionlist = selectiongettiles(x, y, width, height)
		
		love.graphics.setColor(255, 255, 255, 100)
		for i = 1, #selectionlist do
			local v = selectionlist[i]
			if map[v.x][v.y][2] and entitylist[map[v.x][v.y][2]] and rightclickmenues[entitylist[map[v.x][v.y][2]].t] then
				love.graphics.rectangle("fill", (v.x-xscroll-1)*16*scale, (v.y-yscroll-1.5)*16*scale, 16*scale, 16*scale)
			end
		end
	end
end

function thisclass:clear()
	local x, y = round(selectionx/scale), round(selectiony/scale)
	local width, height = round(selectionwidth/scale), round(selectionheight/scale)
	
	local selectionlist = selectiongettiles(selectionx, selectiony, selectionwidth, selectionheight)
	
	for i = 1, #selectionlist do
		for j = 2, #map[selectionlist[i].x][selectionlist[i].y] do
			map[selectionlist[i].x][selectionlist[i].y][j] = nil
		end
	end
end