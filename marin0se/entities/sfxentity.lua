sfxentity = class("sfxentity")

function sfxentity:init(x, y, r)
	self.x = x
	self.y = y
	self.cox = x
	self.coy = y
	self.visible = false
	self.r = {unpack(r)}
	self.single = true
	self.triggered = false
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	
	--VISIBLE
	if #self.r > 0 and self.r[1] ~= "link" then
		self.visible = (self.r[1] == "true")
		table.remove(self.r, 1)
	end
	
	--Single Trigger
	if #self.r > 0 and self.r[1] ~= "link" then
		self.single = (self.r[1] == "true")
		table.remove(self.r, 1)
	end
	
	--SFX SOURCE
	if #self.r > 0 and self.r[1] ~= "link" then
		self.sfxname = self.r[1]
		table.remove(self.r, 1)
	end
	
	self.outtable = {}
end

function sfxentity:link()
	while #self.r > 3 do
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[3]) == v.cox and tonumber(self.r[4]) == v.coy then
					print("trying to touch", v)
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

function sfxentity:draw()
	if self.visible then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(sfxentityimg, math.floor((self.x-1-xscroll)*16*scale), ((self.y-yscroll-1)*16-8)*scale, 0, scale, scale)
	end
end

function sfxentity:input(t, input)
	if t ~= "off" then
		if not self.triggered or not self.single then
			self.triggered = true
			if self.sfxname ~= "none.ogg" then
				playsound(self.sfxname)
			end
		end
	end
end

function sfxentity:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end