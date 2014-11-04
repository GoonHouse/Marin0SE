firework = class("firework")

function firework:init(x, yoffset)
	self.x = x+(math.random(9)-5)
	self.y = math.random(5)+3+yoffset
	self.timer = 0
	marioscore = marioscore + 200
end

function firework:update(dt)
	self.timer = self.timer + dt
	
	if self.timer >= fireworksoundtime and self.timer-dt < fireworksoundtime then
		playsound("boom", self.x, self.y)
	end
	
	if self.timer > fireworkdelay then
		return true
	end
	
	if self.destroy then
	return true
	end
end

function firework:draw()
	local framelength = fireworkdelay/3
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
	love.graphics.draw(fireworkimg, fireworkquads[frame], math.floor((self.x-xscroll)*16*scale), (self.y-yscroll-0.5)*16*scale, 0, scale, scale, 16, 16)
	if self.timer > framelength*1.7 then
		self.destroy=true
		return true
	end
end