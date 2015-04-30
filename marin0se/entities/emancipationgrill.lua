emancipationgrill = class("emancipationgrill")

function emancipationgrill:init(x, y, r)
	self.cox = x
	self.coy = y
	self.r = {unpack(r)}
	self.dir = "ver"
	self.power = true
	self.inputstate = "off"
	
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	
	--Input list
	--DIR
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
	
	self.destroy = false
	if getTile(self.cox, self.coy) == true then
		self.destroy = true
	end
	
	for i, v in pairs(objects["emancipationgrill"]) do
		local a, b = v:getTileInvolved(self.cox, self.coy)
		if a and b == self.dir then
			self.destroy = true
		end
	end
	
	self.particles = {}
	self.particles.i = {}
	self.particles.dir = {}
	self.particles.speed = {}
	self.particles.mod = {}
	
	self.involvedtiles = {}
	
	--find start and end
	if self.dir == "hor" then
		--self.height = 1
		local curx = self.cox
		while curx >= 1 and getTile(curx, self.coy) == false do
			self.involvedtiles[curx] = self.coy
			curx = curx - 1
		end
		self.startx = curx + 1
		
		local curx = self.cox
		while curx <= mapwidth and getTile(curx, self.coy) == false do
			self.involvedtiles[curx] = self.coy
			curx = curx + 1
		end
		self.endx = curx - 1
		
		self.range = math.floor(((self.endx - self.startx + 1 + emanceimgwidth/16)*16)*scale)
		--self.width = self.endx - self.startx + 1
		--print("grill is", self.width, "wide")
	else
		--self.width = 1
		local cury = self.coy
		while cury >= 1 and getTile(self.cox, cury) == false do
			self.involvedtiles[cury] = self.cox
			cury = cury - 1
		end
		self.starty = cury + 1
		
		local cury = self.coy
		while cury <= mapheight and getTile(self.cox, cury) == false do
			self.involvedtiles[cury] = self.cox
			cury = cury + 1
		end
		self.endy = cury - 1
		
		self.range = math.floor(((self.endy - self.starty + 1 + emanceimgwidth/16)*16)*scale)
		--self.height = self.endy - self.starty + 1
		--print("grill is", self.height, "tall")
	end
	
	for i = 1, self.range/16/scale do
		table.insert(self.particles.i, math.random())
		table.insert(self.particles.speed, (1-emanceparticlespeedmod)+math.random()*emanceparticlespeedmod*2)
		if math.random(2) == 1 then
			table.insert(self.particles.dir, 1)
		else
			table.insert(self.particles.dir, -1)
		end
		table.insert(self.particles.mod, math.random(4)-2)
	end
end

function emancipationgrill:link()
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

function emancipationgrill:update(dt)
	if self.destroy then
		return true
	end

	for i, v in pairs(self.particles.i) do
		self.particles.i[i] = self.particles.i[i] + emanceparticlespeed/(self.range/16/scale)*dt*self.particles.speed[i]
		while self.particles.i[i] > 1 do
			self.particles.i[i] = self.particles.i[i]-1
			self.particles.speed[i] = (1-emanceparticlespeedmod)+math.random()*emanceparticlespeedmod*2
			if math.random(2) == 1 then
				self.particles.dir[i] = 1
			else
				self.particles.dir[i] = -1
			end
			self.particles.mod[i] = math.random(4)-2
		end
	end
end

function emancipationgrill:draw()
	if self.destroy == false then
		if self.dir == "hor" then
			parstartleft = math.floor((self.startx-1-xscroll)*16*scale)
			parstartright = math.floor((self.endx-1-xscroll)*16*scale)
			if self.power then
				love.graphics.setScissor(parstartleft, ((self.coy-yscroll-1)*16-2)*scale, self.range - emanceimgwidth*scale, scale*4)
				
				love.graphics.setColor(unpack(emancelinecolor))
				love.graphics.rectangle("fill", math.floor((self.startx-1-xscroll)*16*scale), ((self.coy-yscroll-1)*16-2)*scale, self.range, scale*4)
				love.graphics.setColor(255, 255, 255)
				
				for i, v in pairs(self.particles.i) do
					local y = ((self.coy-1-yscroll)*16-self.particles.mod[i])*scale
					if self.particles.dir[i] == 1 then
						local x = parstartleft+self.range*v
						love.graphics.draw(emanceparticleimg, math.floor(x), y, math.pi/2, scale, scale)
					else
						local x = parstartright-self.range*v
						love.graphics.draw(emanceparticleimg, math.floor(x), y, -math.pi/2, scale, scale, 1)
					end
				end
				
				love.graphics.setScissor()
			end
			
			--Sidethings
			love.graphics.draw(emancesideimg, parstartleft, ((self.coy-1-yscroll)*16-4)*scale, 0, scale, scale)
			love.graphics.draw(emancesideimg, parstartright+16*scale, ((self.coy-1-yscroll)*16+4)*scale, math.pi, scale, scale)
		else --ver
			parstartup = math.floor((self.starty-yscroll-1)*16*scale)
			parstartdown = math.floor((self.endy-yscroll-1)*16*scale)
			if self.power then
				love.graphics.setScissor(math.floor(((self.cox-1-xscroll)*16+6)*scale), parstartup-8*scale, scale*4, self.range - emanceimgwidth*scale)
				
				love.graphics.setColor(unpack(emancelinecolor))
				love.graphics.rectangle("fill", math.floor(((self.cox-1-xscroll)*16+6)*scale), parstartup-8*scale, scale*4, self.range - emanceimgwidth*scale)
				love.graphics.setColor(255, 255, 255)
				
				for i, v in pairs(self.particles.i) do
					local x = ((self.cox-1-xscroll)*16-self.particles.mod[i]+9)*scale
					if self.particles.dir[i] == 1 then
						local y = parstartup-yscroll+self.range*v
						love.graphics.draw(emanceparticleimg, math.floor(x), y, math.pi, scale, scale)
					else
						local y = parstartdown-yscroll-self.range*v
						love.graphics.draw(emanceparticleimg, math.floor(x), y, 0, scale, scale, 1)
					end
				end
				
				love.graphics.setScissor()
			end
			
			--Sidethings
			love.graphics.draw(emancesideimg, math.floor(((self.cox-xscroll)*16-4)*scale), parstartup-8*scale, math.pi/2, scale, scale)
			love.graphics.draw(emancesideimg, math.floor(((self.cox-xscroll)*16-12)*scale), parstartdown+8*scale, -math.pi/2, scale, scale)
		end
	end
end

function emancipationgrill:getTileInvolved(x, y)
	if self.power then
		if self.dir == "hor" then
			if self.involvedtiles[x] == y then
				return true, "hor"
			else
				return false, "hor"
			end
		else
			if self.involvedtiles[y] == x then
				return true, "ver"
			else
				return false, "ver"
			end
		end
	else
		return false
	end
end

function emancipationgrill:input(t, input)
	if input == "power" then
		if t == "on" and self.inputstate == "off" then
			self.power = not self.power
		elseif t == "off" and self.inputstate == "on" then
			self.power = not self.power
		elseif t == "toggle" then
			self.power = not self.power
		end
		
		self.inputstate = t
	end
end