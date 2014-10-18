textentity = class("textentity")

function textentity:init(x, y, r)
	self.x = x
	self.y = y
	self.power = true
	self.text = ""
	
	self.red = 1
	self.green = 1
	self.blue = 1
	
	--Input list
	self.input1state = "off"
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	--TEXT
	if #self.r > 0 and self.r[1] ~= "link" then
		self.text = self.r[1]
		table.remove(self.r, 1)
	end
	--POWER
	if #self.r > 0 and self.r[1] ~= "link" then
		self.power = not (self.r[1] == "true")
		table.remove(self.r, 1)
	end
	--Red
	if #self.r > 0 and self.r[1] ~= "link" then
		self.red = tonumber(self.r[1])
		table.remove(self.r, 1)
	end
	--Green
	if #self.r > 0 and self.r[1] ~= "link" then
		self.green = tonumber(self.r[1])
		table.remove(self.r, 1)
	end
	--Blue
	if #self.r > 0 and self.r[1] ~= "link" then
		self.blue = tonumber(self.r[1])
		table.remove(self.r, 1)
	end
end

function textentity:link()
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

function textentity:input(t, input)
	if input == "power" then
		if t == "on" and self.input1state == "off" then
			self.power = not self.power
		elseif t == "off" and self.input1state == "on" then
			self.power = not self.power
		elseif t == "toggle" then
			self.power = not self.power
		end
		
		self.input1state = t
	end
end

function textentity:update(dt)
	
end

function textentity:draw()
	if self.power then
		love.graphics.setColor(self.red, self.green, self.blue)
		properprint(self.text, math.floor((self.x-xscroll-1)*16*scale), math.floor((self.y-yscroll-.5+0.25-1)*16*scale))
		-- I don't know *why* I have to off-by-one the X and Y but that's the way I found it.
	end
end