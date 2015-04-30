lightbridge = class("lightbridge")

function lightbridge:init(x, y, r)
	self.cox = x
	self.coy = y
	self.dir = "right"
	self.r = {unpack(r)}
	
	self.childtable = {}
	
	self.power = true
	self.glowa = 1
	self.glowtimer = 0
	self.input1state = "off"
	self.children = 0
	
	self.dir = "right"
	
	--Input list
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	--DIRECTION
	if #self.r > 0 and self.r[1] ~= "link" then
		self.dir = self.r[1]
		table.remove(self.r, 1)
	end
	
	--POWER
	if #self.r > 0 and self.r[1] ~= "link" then
		if self.r[1] == "true" then
			self.power = false
		end
		table.remove(self.r, 1)
	end
	
	self:updaterange()
end

function lightbridge:link()
	while #self.r > 3 do
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[3]) == v.cox and tonumber(self.r[4]) == v.coy then
					v:addoutput(self, self.r[2])
				end
			end
		end
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
	end
end

function lightbridge:input(t, input)
	if input == "power" then
		if t == "on" and self.input1state == "off" then
			self.power = not self.power
		elseif t == "off" and self.input1state == "on" then
			self.power = not self.power
		elseif t == "toggle" then
			self.power = not self.power
		end
		self:updaterange()
		
		self.input1state = t
	end
end

function lightbridge:update(dt)
	self.glowtimer = self.glowtimer + dt*2
	
end

function lightbridge:getglowa(offset)
	return math.sin(self.glowtimer-offset*0.5)*.25+.75
end

function lightbridge:draw()
	local rot = 0
	if self.dir == "up" then
		rot = math.pi*1.5
	elseif self.dir == "down" then
		rot = math.pi*0.5
	elseif self.dir == "left" then
		rot = math.pi
	end

	love.graphics.draw(lightbridgesideimg, math.floor((self.cox-xscroll-.5)*16*scale), (self.coy-yscroll-1)*16*scale, rot, scale, scale, 8, 8)
end

function lightbridge:updaterange()
	--save old gel values
	local gels = {}
	
	for i, v in pairs(self.childtable) do
		if v.gels.top then
			table.insert(gels, {x=v.cox, y=v.coy, dir="top", i=v.gels.top})
		elseif v.gels.left then
			table.insert(gels, {x=v.cox, y=v.coy, dir="left", i=v.gels.left})
		elseif v.gels.right then
			table.insert(gels, {x=v.cox, y=v.coy, dir="right", i=v.gels.right})
		elseif v.gels.bottom then
			table.insert(gels, {x=v.cox, y=v.coy, dir="bottom", i=v.gels.bottom})
		end
	end	
	
	for i, v in pairs(self.childtable) do
		v.destroy = true
	end
	self.childtable = {}
	
	if self.power == false then
		return
	end
	
	local dir = self.dir
	local startx, starty = self.cox, self.coy
	local x, y = self.cox, self.coy
	self.children = 0
	
	local firstcheck = true
	local quit = false
	while x >= 1 and x <= mapwidth and y >= 1 and y <= mapheight and (tilequads[map[x][y][1]]:getproperty("collision", x, y) == false or tilequads[map[x][y][1]]:getproperty("grate", x, y)) and (x ~= startx or y ~= starty or dir ~= self.dir or firstcheck == true) and quit == false do
		firstcheck = false
		
		self.children = self.children + 1
		if dir == "right" then
			x = x + 1
			table.insert(objects["lightbridgebody"], lightbridgebody:new(self, x-1, y, "hor", self.children))
		elseif dir == "left" then
			x = x - 1
			table.insert(objects["lightbridgebody"], lightbridgebody:new(self, x+1, y, "hor", self.children))
		elseif dir == "up" then
			y = y - 1
			table.insert(objects["lightbridgebody"], lightbridgebody:new(self, x, y+1, "ver", self.children))
		elseif dir == "down" then
			y = y + 1
			table.insert(objects["lightbridgebody"], lightbridgebody:new(self, x, y-1, "ver", self.children))
		end
		
		--check if current block is a portal
		local opp = "left"
		if dir == "left" then
			opp = "right"
		elseif dir == "up" then
			opp = "down"
		elseif dir == "down" then
			opp = "up"
		end
		
		local portalx, portaly, portalfacing, infacing = getPortal(x, y, opp)
		if portalx ~= false and ((dir == "left" and infacing == "right") or (dir == "right" and infacing == "left") or (dir == "up" and infacing == "down") or (dir == "down" and infacing == "up")) then
			x, y = portalx, portaly
			dir = portalfacing
			
			if dir == "right" then
				x = x + 1
			elseif dir == "left" then
				x = x - 1
			elseif dir == "up" then
				y = y - 1
			elseif dir == "down" then
				y = y + 1
			end
		end
		
		--doors
		for i, v in pairs(objects["door"]) do
			if v.active then
				if v.dir == "ver" then
					if x == v.cox and (y == v.coy or y == v.coy-1) then
						quit = true
					end
				elseif v.dir == "hor" then
					if y == v.coy and (x == v.cox or x == v.cox+1) then
						quit = true
					end
				end
			end
		end
	end
	
	--Restore gels! yay!
	--crosscheck childtable with gels to see any matching shit
	for j, w in pairs(self.childtable) do
		for i, v in pairs(gels) do
			if v.x == w.cox and v.y == w.coy then
				if v.dir == "left" or v.dir == "right" then
					if w.dir == "ver" then
						w.gels[v.dir] = v.i
					end
				else
					if w.dir == "hor" then
						w.gels[v.dir] = v.i
					end
				end
			end
		end
	end
end

function lightbridge:addChild(t)
	table.insert(self.childtable, t)
end