redcoin = class("redcoin")

function redcoin:init(x, y, r)
	self.cox = x
	self.coy = y

	self.x = x-1
	self.y = y-1
	self.width = 1
	self.height = 1
	self.moves = false
	self.active = true
	self.category = 6
	self.mask = {true}
	self.drawable = true
	self.quad = 1
	self.rotation = 0
	self.timer = 0
	self.falling = false
	self.destroy = false
	self.r = {unpack(r)}

	table.remove(self.r, 1)
	table.remove(self.r, 1)
	if #self.r > 0 and self.r[1] ~= "link" then
		self.value = self.r[1]
		table.remove(self.r, 1)
	end
	
	if #self.r > 0 and self.r[1] ~= "link" then
		self.size = self.r[1]
		table.remove(self.r, 1)
	end
	
	if self.size == "tallthin" then
		self.height = 2
		self.y = self.y-1
	elseif self.size == "large" then
		self.width = 2
		self.height = 2
		self.x = self.x-1
		self.y = self.y-1
	end
	if gameplaytype ~= "oddjob" then -- Make it not exist outside gameplaytype.
	self.destroy = true
	end
end

function redcoin:update(dt)
	-- returning in the update method signals the object handler to destroy us
	--[[if redcoincollected[self.value] >= 1 then  -- The why do you have dupes checker.
	self.destroy = true
	return true
	end]]
	if self.destroy then
	return true
	end
end

function redcoin:collect(ply)
	-- ply is a reference to the player that collected us, we can use that later
	redcoincollected[self.value] = 1
	redcoincount = redcoincount + 1
	if redcoincount == oddjobquotas[1] then
		playsound("redcoin5", self.x, self.y)
	else
		playsound("redcoin1", self.x, self.y)
	end
	self.active = false
	self.drawable = false
	self.destroy = true
end

function redcoin:draw()
	if self.size == "tallthin" then
		love.graphics.draw(redcointallimg, redcointallquads[redcoinframe], math.floor((self.x-xscroll)*16*scale), ((self.y-yscroll)*16*scale)-8*scale, 0, scale, scale)
	elseif self.size == "large" then
		love.graphics.draw(redcoinbigimg, redcoinbigquads[redcoinframe], math.floor((self.x-xscroll)*16*scale), ((self.y-yscroll)*16*scale)-8*scale, 0, scale, scale)
	else
		love.graphics.draw(redcoinimg, redcoinquads[redcoinframe], math.floor((self.x-xscroll)*16*scale), ((self.y-yscroll)*16*scale)-8*scale, 0, scale, scale)
	end
end