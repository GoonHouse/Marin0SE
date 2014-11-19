generatorbullet = class("generatorbullet")

function generatorbullet:init(x, y, r)
	self.x = x
	self.y = y
	self.cox = x
	self.coy = y
	self.bulletgentable = {left = false, right = false, up = false, down = false}
	self.bulletfiringtype = "one at a time"
	
	self.checktable = {}
	table.insert(self.checktable, "player")
	
	--Unpack the goods
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	
	
	--Directions, Firing Type
	if #self.r > 0 and self.r[1] ~= "link" then
		self.bulletgentable["left"] = true
		table.remove(self.r, 1)
	end
	
	if #self.r > 0 and self.r[1] ~= "link" then
		self.bulletgentable["right"] = true
		table.remove(self.r, 1)
	end
	
	if #self.r > 0 and self.r[1] ~= "link" then
		self.bulletgentable["up"] = true
		table.remove(self.r, 1)
	end
	
	if #self.r > 0 and self.r[1] ~= "link" then
		self.bulletgentable["down"] = true
		table.remove(self.r, 1)
	end
	
	if #self.r > 0 and self.r[1] ~= "link" then
		bulletfiringtype = self.r[1]
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
	
	if #self.r > 0 then
		local s = self.r[1]:split(":")
		self.triggerregionX, self.triggerregionY, self.triggerregionwidth, self.triggerregionheight = s[2], s[3], tonumber(s[4]), tonumber(s[5])
		if string.sub(self.triggerregionX, 1, 1) == "m" then
			self.triggerregionX = -tonumber(string.sub(self.triggerregionX, 2))
		end
		if string.sub(self.triggerregionY, 1, 1) == "m" then
			self.triggerregionY = -tonumber(string.sub(self.triggerregionY, 2))
		end
		
		self.triggerregionX = tonumber(self.triggerregionX) + self.x - 1
		self.triggerregionY = tonumber(self.triggerregionY) + self.y - 1
		table.remove(self.r, 1)
	end
end

function generatorbullet:update(dt)
	local col = checkrect(self.regionX, self.regionY, self.regionwidth, self.regionheight, self.checktable)
	if not levelfinished and #col > 0 then
		bulletbilltimer = bulletbilltimer + dt
		while bulletbilltimer > bulletbilldelay do
			bulletbilltimer = bulletbilltimer - bulletbilldelay
			bulletbilldelay = math.random(5, 40)/10
			
			local nearestplayer = 1
			
			while objects["player"][nearestplayer] and objects["player"][nearestplayer].dead do
				nearestplayer = nearestplayer + 1
			end
			
			if objects["player"][nearestplayer] then
				local nearestplayerx = objects["player"][nearestplayer].x
				for i = 2, players do
					local v = objects["player"][i]
					if v.x > nearestplayerx and not v.dead then
						nearestplayer = i
					end
				end
			end
			
				if bulletfiringtype == "oneatatime" then
					local randomfactor = math.random(1, 4)
					if randomfactor == 1 and self.bulletgentable["left"] == true then
						table.insert(objects["enemy"], enemy:new(objects["player"][nearestplayer].x+24, math.random(self.triggerregionY, self.triggerregionY+self.triggerregionheight), "bulletbill"))
					elseif randomfactor == 2 and self.bulletgentable["right"] == true then
						table.insert(objects["enemy"], enemy:new(objects["player"][nearestplayer].x-24, math.random(self.triggerregionY, self.triggerregionY+self.triggerregionheight), "bulletbill"))
					else 
					bulletbilldelay = bulletbilltimer
					end
				end
			playsound("bulletbill") --allowed global
			end
	elseif #col == 0 then
		bulletbilltimer = 0
	end
end

function generatorbullet:draw()
	
end