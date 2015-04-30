local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, editortool)
local thisclass = _G[classname]

function thisclass:init(drawtile)
	editortool.init(self, classname)
	self.dragdraw = false
	self.dragging = true
	self.drawtile = drawtile or 0
end

function thisclass:operate(x,y)
	placetile(x,y)
end

function thisclass:change(...)
	local arg={...}
	self.drawtile = arg[1] or 0
end

function thisclass:update(dt)
	-- we can always show our status, probably
	local x, y = getMousePos()
	local tilex,tiley = getMouseTile(x, y-8*scale)
	self.status="("..tilex..","..tiley..")"
	
	if editortool.update(self,dt) and not rightclickm then
		-- paint everywhere for as long as the mouse is down
		if inmap(tilex,tiley) then
			self:operate(x,y)
		end
	end
end

function thisclass:draw()
	editortool.draw(self)
	
	if not rightclickactive and not rightclickm and not regiondragging then
		local x, y = getMouseTile(mouse.getX(), mouse.getY()-8*scale)
		--local posstr = x..",|"..y
		--local xcenteroffset = (2/16) --((string.len(posstr)*4)/16)
		-- the above is the closest I got to centered when using the format "(x,y)"
		--properprintbackground(posstr, math.floor((x-xscroll-1-(3/16)+xcenteroffset)*16*scale), math.floor(((y-yscroll+(2/16))*16+8)*scale), true)
		if inmap(x, y+1) then
			love.graphics.setColor(255, 255, 255, 200)
			-- we do this because if we open the enemies tab and don't do anything we end up with a beetle
			-- deep down, isn't that all we *really* want out of life?
			if editentities == false and type(currenttile)=="number" then
				local quad = tilequads[currenttile]:quad()
				if currenttile > 10000 then
					quad = tilequads[currenttile]:quad()
				end
				love.graphics.draw(tilequads[currenttile].image, quad, math.floor((x-xscroll-1)*16*scale), math.floor(((y-yscroll-1)*16+8)*scale), 0, scale, scale)
			elseif editenemies == false then
				love.graphics.draw(entityquads[currenttile].image, entityquads[currenttile].quad, math.floor((x-xscroll-1)*16*scale), math.floor(((y-yscroll-1)*16+8)*scale), 0, scale, scale)
			else
				local v = enemiesdata[currenttile]
				local xoff, yoff = (((v.spawnoffsetx or 0)+v.width/2-.5)*16 - v.offsetX + v.quadcenterX)*scale, (((v.spawnoffsety or 0)-v.height+1)*16-v.offsetY - v.quadcenterY)*scale
				love.graphics.draw(v.graphic, v.quad, math.floor((x-xscroll-1)*16*scale+xoff), math.floor(((y-yscroll)*16)*scale+yoff), 0, scale, scale)
			end
		end
	end
end