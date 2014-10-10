spring = class("spring")

function spring:init(x, y, r)
	self.cox = x
	self.coy = y
	
	--PHYSICS STUFF
	self.x = x-1
	self.y = y-32/16
	self.width = 16/16
	self.height = 32/16
	self.static = true
	self.active = true
	
	self.drawable = false
	self.type = "regular"
	
	self.timer = springtime
	
	self.r = {unpack(r)}
	--r == the map data at map[x][y]
	table.remove(self.r, 1) --r[1] == tile index, can be used to look up properties in tilequads{}
	table.remove(self.r, 1) --r[2] == entity index, can be used to look up generic base entity in entitylist{}
	-- all indexes of r after this point are those that you defined by the rightclick menu.
	--SPRINGTYPE
	if #self.r > 0 and self.r[1] ~= "link" then
		self.type = self.r[1]
		table.remove(self.r, 1)
	end
	
	self.category = 19
	
	self.mask = {true}
	
	self.frame = 1
end

function spring:update(dt)
	if self.timer < springtime then
		self.timer = self.timer + dt
		if self.timer > springtime then
			self.timer = springtime
		end
		self.frame = math.ceil(self.timer/(springtime/3)+0.001)+1
		if self.frame > 3 then
			self.frame = 6-self.frame
		end
	end
end

function spring:draw()
	if self.type == "regular" then
		love.graphics.draw(springimg, springquads[spriteset][self.frame], math.floor((self.x-xscroll)*16*scale), ((self.y-yscroll)*16-8)*scale, 0, scale, scale)
	elseif self.type == "high" then
		love.graphics.draw(springgrnimg, springquads[spriteset][self.frame], math.floor((self.x-xscroll)*16*scale), ((self.y-yscroll)*16-8)*scale, 0, scale, scale)
	end
end

function spring:hit()
	self.timer = 0
	playsound("spring")
end