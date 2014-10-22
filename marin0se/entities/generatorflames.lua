generatorflames = class("generatorflames")

function generatorflames:init(x, y, r)
	self.x = x
	self.y = y
	self.cox = x
	self.coy = y
	flamegentable = {"right", 0}
	
	self.checktable = {}
	table.insert(self.checktable, "player")
	
	--Unpack the goods
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	
	
	--Stuff to come sometime
	--[[if #self.r > 0 and self.r[1] ~= "link" then
		bulletgentable[1] = self.r[1]
		table.remove(self.r, 1)
	end
	
	--Wind Intensity
	if #self.r > 0 and self.r[1] ~= "link" then
		bulletgentable[2] = self.r[1]		
		table.remove(self.r, 1)
	end]]
	
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

function generatorflames:update(dt)
	local col = checkrect(self.regionX, self.regionY, self.regionwidth, self.regionheight, self.checktable)
	if #col > 0 then
			gensrunning["bowserflames"] = true
			return true
	elseif #col == 0 then
			gensrunning["bowserflames"] = false
			return false
	end
end

function generatorflames:draw()
	
end