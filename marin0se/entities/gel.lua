gel = class("gel")

function gel:init(x, y, id)
	self.id = id
	
	--PHYSICS STUFF
	self.x = x-14/16
	self.y = y-12/16
	self.speedy = 0
	self.speedx = 0
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.category = 8
	self.mask = {false, false, true, true, true, true, true, true, false, false, true}
	self.gravity = 50
	self.autodelete = true
	self.timer = 0
	
	--IMAGE STUFF
	self.drawable = true
	self.quad = gelquad[math.random(3)]
	self.offsetX = 8
	self.offsetY = 0
	self.quadcenterX = 8
	self.quadcenterY = 8
	self.rotation = 0 --for portals
	if self.id == 1 then
		self.graphic = gel1img
	elseif self.id == 2 then
		self.graphic = gel2img
	elseif self.id == 3 then
		self.graphic = gel3img
	elseif self.id == 4 then
		self.graphic = gel4img
	elseif self.id == 5 then
		self.graphic = gel5img
	elseif self.id == 6 then
		self.graphic = gel6img
	end
	
	self.destroy = false
end

function gel:update(dt)
	--Funnels and fuck
	if self.funnel and not self.infunnel then
		self:enteredfunnel(true)
	end
	
	if self.infunnel and not self.funnel then
		self:enteredfunnel(false)
	end
	
	self.funnel = false

	if self.speedy > gelmaxspeed then
		self.speedy = gelmaxspeed
	end
	
	self.rotation = 0
	
	self.timer = self.timer + dt
	if self.timer >= gellifetime then
		return true
	end
	
	return self.destroy
end

function gel:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.destroy = true
	if a == "tile" then
		local x, y = b.cox, b.coy
		
		if (inmap(x+1, y) and tilequads[map[x+1][y][1]]:getproperty("collision", x+1, y)) or (inmap(x, y) and tilequads[map[x][y][1]]:getproperty("collision", x, y) == false) then
			return
		end
		
		--see if adjsajcjet tile is a better fit
		if math.floor(self.y+self.height/2)+1 ~= y then
			if inmap(x, math.floor(self.y+self.height/2)+1) and tilequads[map[x][math.floor(self.y+self.height/2)+1][1]]:getproperty("collision", x, math.floor(self.y+self.height/2)+1) then
				y = math.floor(self.y+self.height/2)+1
			end
		end
		
		map[x][y]["gels"]["right"] = self.id
	elseif a == "lightbridgebody" and b.dir == "ver" then
		b.gels.right = self.id
	end
end

function gel:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.destroy = true
	if a == "tile" then
		local x, y = b.cox, b.coy
		
		if (inmap(x-1, y) and tilequads[map[x-1][y][1]]:getproperty("collision", x-1, y)) or (inmap(x, y) and tilequads[map[x][y][1]]:getproperty("collision", x, y) == false) then
			return
		end
		
		--see if adjsajcjet tile is a better fit
		if math.floor(self.y+self.height/2)+1 ~= y then
			if inmap(x, math.floor(self.y+self.height/2)+1) and tilequads[map[x][math.floor(self.y+self.height/2)+1][1]]:getproperty("collision", x, math.floor(self.y+self.height/2)+1) then
				y = math.floor(self.y+self.height/2)+1
			end
		end
		
		map[x][y]["gels"]["left"] = self.id
	elseif a == "lightbridgebody" and b.dir == "ver" then
		b.gels.left = self.id
	end
end

function gel:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.destroy = true
	if a == "tile" then
		local x, y = b.cox, b.coy
		
		if (inmap(x, y-1) and tilequads[map[x][y-1][1]]:getproperty("collision", x, y-1)) or (inmap(x, y) and tilequads[map[x][y][1]]:getproperty("collision", x, y) == false) then
			return
		end
		
		--see if adjsajcjet tile is a better fit
		if math.floor(self.x+self.width/2)+1 ~= x then
			if inmap(x, y) and tilequads[map[x][y][1]]:getproperty("collision", x, y) then
				x = math.floor(self.x+self.width/2)+1
			end
		end
		
		if inmap(x, y) and tilequads[map[x][y][1]]:getproperty("collision", x, y) then
			if map[x][y]["gels"]["top"] == self.id then
				if self.speedx > 0 then
					for cox = x+1, x+self.speedx*0.2 do
						if inmap(cox, y-1) and tilequads[map[cox][y][1]]:getproperty("collision", cox, y) == true and tilequads[map[cox][y-1][1]]:getproperty("collision", cox, y-1) == false then
							if map[cox][y]["gels"]["top"] ~= self.id then
								map[cox][y]["gels"]["top"] = self.id
								break
							end
						else
							break
						end
					end
				elseif self.speedx < 0 then
					for cox = x-1, x+self.speedx*0.2, -1 do
						if inmap(cox, y-1) and tilequads[map[cox][y][1]]:getproperty("collision", cox, y) and tilequads[map[cox][y-1][1]]:getproperty("collision", cox, y-1) == false then
							if map[cox][y]["gels"]["top"] ~= self.id then
								map[cox][y]["gels"]["top"] = self.id
								break
							end
						else
							break
						end
					end
				end
			else
				map[x][y]["gels"]["top"] = self.id
			end
		end
	elseif a == "lightbridgebody" and b.dir == "hor" then
		b.gels.top = self.id
	end
end

function gel:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.destroy = true
	if a == "tile" then
		local x, y = b.cox, b.coy
		if not inmap(x, y+1) or tilequads[map[x][y+1][1]]:getproperty("collision", x, y+1) == false then
			local x, y = b.cox, b.coy
			
			map[x][y]["gels"]["bottom"] = self.id
		end
	elseif a == "lightbridgebody" and b.dir == "hor" then
		b.gels.bottom = self.id
	end
end

function gel:globalcollide(a, b)
	if a == "tile" then
		local x, y = b.cox, b.coy
		if tilequads[map[x][y][1]]:getproperty("invisible", x, y) or tilequads[map[x][y][1]]:getproperty("grate", x, y) then
			return true
		end
	end
end

function gel:enteredfunnel(inside)
	if inside then
		self.infunnel = true
	else
		self.infunnel = false
		self.gravity = 50
	end
end