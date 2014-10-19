redcoin = class("redcoin")

function redcoin:init(x, y, r)
	self.cox = x
	self.coy = y

	self.x = x-1
	self.y = y-1
	self.width = 1
	self.height = 1
	self.static = true
	self.active = true
	self.category = 6
	self.mask = {true}
	self.drawable = true
	self.quad = 1
	self.rotation = 0
	self.timer = 0
	self.falling = false
	self.r = {unpack(r)}

	table.remove(self.r, 1)
	table.remove(self.r, 1)
		if #self.r > 0 and self.r[1] ~= "link" then
			self.value = self.r[1]
			table.remove(self.r, 1)
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
end

function redcoin:update(dt)
	if gameplaytype ~= 2 or redcoincollected[self.value] == 1 then
	self.active = false
	self.drawable = false
	end
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