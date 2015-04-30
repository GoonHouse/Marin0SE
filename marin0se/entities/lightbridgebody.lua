lightbridgebody = class("lightbridgebody")

function lightbridgebody:init(parent, x, y, dir, i)
	parent:addChild(self)
	self.i = i
	self.cox = x
	self.coy = y
	self.dir = dir
	self.parent = parent

	--PHYSICS STUFF
	if dir == "hor" then
		self.x = x-1
		self.y = y-9/16
		self.width = 1
		self.height = 1/8
	else
		self.x = x-9/16
		self.y = y-1
		self.width= 1/8
		self.height = 1
	end
	self.moves = false
	self.active = true
	self.category = 28
	
	self.mask = {true}
	
	self.gels = {}
	
	self:pushstuff()
end

function lightbridgebody:pushstuff()
	local col = checkrect(self.x, self.y, self.width, self.height, {"box", "player"})
	for i = 1, #col, 2 do
		local v = objects[col[i]][col[i+1]]
		if self.dir == "ver" then
			if v.speedx >= 0 then
				if #checkrect(self.x + self.width, v.y, v.width, v.height, {"exclude", v}, true) > 0 then
					v.x = self.x - v.width
				else
					v.x = self.x + self.width
				end
			else
				if #checkrect(self.x - v.width, v.y, v.width, v.height, {"exclude", v}, true) > 0 then
					v.x = self.x + self.width
				else
					v.x = self.x - v.width
				end
			end
		elseif self.dir == "hor" then
			if v.speedy <= 0 then
				if #checkrect(v.x, self.y - v.height, v.width, v.height, {"exclude", v}, true) > 0 then
					v.y = self.y + self.height
				else
					v.y = self.y - v.height
				end
			else
				if #checkrect(v.x, self.y + self.height, v.width, v.height, {"exclude", v}, true) > 0 then
					v.y = self.y - v.height
				else
					v.y = self.y + self.height
				end
			end
		end
	end
end

function lightbridgebody:update(dt)
	if self.destroy then
		return true
	else
		return false
	end
end

function lightbridgebody:draw()
	love.graphics.setColor(255, 255, 255)
	
	local glowa = self.parent:getglowa(self.i)
	
	if self.dir == "hor" then
		love.graphics.draw(lightbridgeimg, math.floor((self.cox-xscroll-1)*16*scale), (self.coy-yscroll-1.5)*16*scale, 0, scale, scale)
		love.graphics.setColor(255, 255, 255, glowa*255)
		love.graphics.draw(lightbridgeglowimg, math.floor((self.cox-xscroll-1)*16*scale), (self.coy-yscroll-1.5)*16*scale, 0, scale, scale)
	else
		love.graphics.draw(lightbridgeimg, math.floor((self.cox-xscroll-1/16)*16*scale), (self.coy-yscroll-1)*16*scale, math.pi/2, scale, scale, 8, 1)
		love.graphics.setColor(255, 255, 255, glowa*255)
		love.graphics.draw(lightbridgeglowimg, math.floor((self.cox-xscroll-1/16)*16*scale), (self.coy-yscroll-1)*16*scale, math.pi/2, scale, scale, 8, 1)
	end
	
	love.graphics.setColor(255, 255, 255)
	
	--gel
	for i = 1, 4 do
		local dir = "top"
		local r = 0
		if i == 2 then
			dir = "right"
			r = math.pi/2
		elseif i == 3 then
			dir = "bottom"
			r = math.pi
		elseif i == 4 then
			dir = "left"
			r = math.pi*1.5
		end
		
		for i = 1, numgeltypes do
			if self.gels[dir] == i then
				if i == 1 then
					img = gel1groundimg
				elseif i == 2 then
					img = gel2groundimg
				elseif i == 3 then
					img = gel3groundimg
				elseif i == 4 then
					img = gel4groundimg
				elseif i == 5 then
					img = gel5groundimg
				elseif i == 6 then
					img = gel6groundimg
				end
				
				love.graphics.draw(img, math.floor((self.cox-.5-xscroll)*16*scale), math.floor((self.coy-1-yscroll)*16*scale), r, scale, scale, 8, 2)
			end
		end
	end
end