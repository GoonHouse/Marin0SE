noportal = class("noportal")

function noportal:init(x, y, r)
	self.x = x
	self.y = y
	self.cox = x
	self.coy = y
	
	self.checktable = "all"
	self.outtable = {}
	self.lighttime = 5
	self.lighttimer = 0
	
	--Input list
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	
	--self.checktable = {"player", "portalprojectile"}
	self.allowshootingwithin = false
	
	--ALLOW SHOOTING WITHIN?
	if #self.r > 0 and self.r[1] ~= "link" then
		if self.r[1] == "true" then
			self.allowshootingwithin = true
		end			
		table.remove(self.r, 1)
	end
	
	--REGION
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
	
	self.out = "off"
end

function noportal:getTileInvolved(x, y)
	if x >= self.regionX and x <= self.regionX+self.regionwidth then
		print("PASS X")
		if y <= self.regionY and y >= self.regionY+self.regionheight then
			print("PASS Y")
			return true
		end
	end
end

function noportal:update(dt)
	--local ply = checkrect(self.regionX, self.regionY, self.regionwidth, self.regionheight, {"player"})
	local ports = checkrect(self.regionX, self.regionY, self.regionwidth, self.regionheight, {"portalprojectile"})
	
	--[[if #ply > 0 then
		
	end]]
	
	if #ports > 0 then
		print("sweet baby jesus")
		for k,v in pairs(ports) do
			objects["portalprojectile"][k] = nil
		end
		self.out = "on"
		self.lighttimer = self.lighttime
		for i = 1, #self.outtable do
			if self.outtable[i][1].input then
				self.outtable[i][1]:input(self.out, self.outtable[i][2])
			end
		end
	end
	
	if self.lighttimer > 0 then
		self.lighttimer = self.lighttimer - dt
	end
	
	if self.lighttimer <= 0 and self.out == "on" then
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