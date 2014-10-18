groundlight = class("groundlight")

function groundlight:init(x, y, r)
	self.x = x
	self.y = y
	self.dir = 2
	
	--[[@NOTE: In the event everything goes horribly wrong, refer to this.
		1	=	ver
		2	=	hor
		3	=	upright
		4	=	rightdown
		5	=	downleft
		6	=	leftup
	]]
	
	self.timer = 0
	
	self.input1state = "off"
	
	self.lighted = false
	--Input list
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	
	--DIRECTION
	if #self.r > 0 and self.r[1] ~= "link" then
		self.dir = tonumber(self.r[1])
		table.remove(self.r, 1)
	end
	
	--POWER
	if #self.r > 0 and self.r[1] ~= "link" then
		self.lighted = (self.r[1] == "true")
		table.remove(self.r, 1)
	end
end

function groundlight:link()
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

function groundlight:update(dt)
	print("groundlight", self.dir, self.lighted)
	if self.timer > 0 then
		self.timer = self.timer - dt
		if self.timer <= 0 then
			self.timer = 0
			self:input("off")
		end
	end
end

function groundlight:draw()
	if self.lighted then
		love.graphics.setColor(255, 122, 66, 255)
	else
		love.graphics.setColor(60, 188, 252, 255)
	end
	love.graphics.draw(groundlightimg, groundlightquad[self.dir], math.floor((self.x-1-xscroll)*16*scale), ((self.y-yscroll-1)*16-8)*scale, 0, scale, scale)
end

function groundlight:input(t, input)
	if input == "power" then
		if t == "on" and self.input1state == "off" then
			self.lighted = not self.lighted
		elseif t == "off" and self.input1state == "on" then
			self.lighted = not self.lighted
		elseif t == "toggle" then
			self.lighted = not self.lighted
		end
		
		self.input1state = t
	end
end