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
	if not levelfinished and #col > 0 then
		--[[if windsound:isStopped() then
			playsound(windsound)
		end]]
		local player1 = objects["player"][1]
		if player1.animationdirection == "left" and player1.animationstate ~= "idle" then
			if not player1.spring and not player1.springhigh then
				if windgentable[1] == "left" then
					player1.speedx = player1.speedx - ((windgentable[2]/100)/2)
					elseif windgentable[1] == "right" then
					player1.speedx = player1.speedx + (windgentable[2]/100)
				end
			else
				
			end
		elseif player1.animationstate ~= "idle" then
			if not player1.spring and not player1.springhigh then
				if windgentable[1] == "left" then
					player1.speedx = player1.speedx - (windgentable[2]/100)
					elseif windgentable[1] == "right" then
					player1.speedx = player1.speedx + ((windgentable[2]/100)/2)
				end
			else
				
			end
		elseif player1.animationstate == "idle" then
			if windgentable[2] == "left" then
				player1.speedx = player1.speedx - 1
				elseif windgentable[1] == "right" then
				player1.speedx = player1.speedx + 1
			end
		end
		-- Make high wind leaves appear
		windtimer = windtimer + dt
		while windtimer > 0.05 do
			windtimer = windtimer - 0.05
			if windgentable[1] == "right" then
			table.insert(objects["leaf"], leaf:new(xscroll, math.random(1, mapheight)))
			elseif windgentable[1] == "left" then
			table.insert(objects["leaf"], leaf:new(xscroll+25, math.random(1, mapheight)))
			end
		end
	elseif #col == 0 then
	windtimer = 0
	end
end

function generatorwind:draw()
	
end