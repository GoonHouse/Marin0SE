noportal = class("noportal")

function noportal:init(x, y, r)
	self.x = x
	self.y = y
	self.cox = x
	self.coy = y
	
	self.checktable = "all"
	self.outtable = {}
	self.input1state = "off"
	self.power = true
	
	--Input list
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	self.checktable = {}
	
	--TRIGGER ON PROJECTILE?
	if #self.r > 0 and self.r[1] ~= "link" then
		if self.r[1] == "true" then
			table.insert(self.checktable, "portalprojectile")
		end			
		table.remove(self.r, 1)
	end
	
	--POWER
	if #self.r > 0 and self.r[1] ~= "link" then
		self.power = self.r[1] == "true"
		table.remove(self.r, 1)
	end
	
	--REGION
	if #self.r > 0 and self.r[1] ~= "link" then
		local s = self.r[1]:split(":")
		self.regionX, self.regionY, self.regionwidth, self.regionheight = s[2], s[3], tonumber(s[4]), tonumber(s[5])
		if string.sub(self.regionX, 1, 1) == "m" then
			self.regionX = -tonumber(string.sub(self.regionX, 2))
		end
		if string.sub(self.regionY, 1, 1) == "m" then
			self.regionY = -tonumber(string.sub(self.regionY, 2))
		end
		
		self.regionX = tonumber(self.regionX) + self.x - 1
		self.regionY = tonumber(self.regionY) + self.y - 1
		table.remove(self.r, 1)
	end
	
	self.out = "off"
end

function noportal:link()
	print("DEBUG: noportal was linked")
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

function noportal:input(t, input)
	--print("contact")
	if input == "power" then
		if t == "on" and self.input1state == "off" then
			--print("the first one")
			self.power = not self.power
		elseif t == "off" and self.input1state == "on" then
			--print("the second one")
			self.power = not self.power
		elseif t == "toggle" then
			--print("the last one")
			self.power = not self.power
		end
		
		self.input1state = t
	else
		--print("what")
	end
end

function noportal:update(dt)
	if self.power then
		local col = checkrect(self.regionX, self.regionY, self.regionwidth, self.regionheight, self.checktable)
		
		if self.out == "off" and #col > 0 then
			for i=1,#col,2 do
				objects[col[i]][col[i+1]].destroy = true
				--print("DEBUG: caught item", i, col[i], col[i+1])
				--v.delete = true
			end
			self.out = "on"
			for i = 1, #self.outtable do
				if self.outtable[i][1].input then
					self.outtable[i][1]:input(self.out, self.outtable[i][2])
				end
			end
		end
	end
	if self.out == "on" then
		self.out = "off"
		for i = 1, #self.outtable do
			if self.outtable[i][1].input then
				self.outtable[i][1]:input(self.out, self.outtable[i][2])
			end
		end
	end
end

function noportal:draw()
	
end

function noportal:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end