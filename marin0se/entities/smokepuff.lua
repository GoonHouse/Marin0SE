smokepuff = class("smokepuff")

function smokepuff:init(x, y)
	self.x = x
	self.y = y
	self.timer = 0
end

function smokepuff:update(dt)
	self.timer = self.timer + dt
	
	if self.timer > smokepuffdelay then
		return true
	end
	
	if self.destroy then
	return true
	end
end

function smokepuff:draw()
	local framelength = smokepuffdelay/3
	local frame = 1
	if self.timer > framelength*1.1 then
		frame = 2
	end
	if self.timer > framelength*1.25 then
		frame = 3
	end
	if self.timer > framelength*1.5 then
		frame = 4
	end
	love.graphics.draw(smokepuffimg, smokepuffquads[frame], math.floor((self.x-xscroll)*16*scale),((self.y-yscroll)*16*scale)-8*scale, 0, scale, scale)
	if self.timer > framelength*1.7 then
		self.destroy=true
		return true
	end
end