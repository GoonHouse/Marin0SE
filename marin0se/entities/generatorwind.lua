generatorwind = class("generatorwind")

function generatorwind:init(x, y, r)
	self.x = x
	self.y = y
	self.cox = x
	self.coy = y
	windgentable = {"right", 0}
	
	self.checktable = {}
	table.insert(self.checktable, "player")
	
	--Unpack the goods
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	
	
	--Wind Direction
	if #self.r > 0 and self.r[1] ~= "link" then
		windgentable[1] = self.r[1]
		table.remove(self.r, 1)
	end
	
	--Wind Intensity
	if #self.r > 0 and self.r[1] ~= "link" then
		windgentable[2] = self.r[1]		
		table.remove(self.r, 1)
	end
	
	--Region
	if #self.r > 0 then
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
end

function generatorwind:update(dt)
	local col = checkrect(self.regionX, self.regionY, self.regionwidth, self.regionheight, self.checktable)
	if #col > 0 then
			gensrunning["highwind"] = true
			return true
	elseif #col == 0 then
			gensrunning["highwind"] = false
			return false
	end
end

function generatorwind:draw()
	
end