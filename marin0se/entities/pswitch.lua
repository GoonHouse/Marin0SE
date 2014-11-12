pswitch = class("pswitch")

function pswitch:init(x, y, r)
	self.cox = x
	self.coy = y
	
	self.x = x-1
	self.y = y-1
	self.width = 1
	self.height = 1
	self.frame = 1
	self.speedy = 0
	self.speedx = 0
	self.moves = false
	self.active = true
	self.destroy = false
	self.inuse = false
	self.liveone = false
	self.color = 1
	
	self.quadcenterX = 8
	self.quadcenterY = 8
	self.gravitydirection = math.pi/2
	
	self.falling = false
	self.rotation = 0
	self.drawable = false
	self.type = "blue"
	self.reusable = false
	self.carryable = false
	
	self.r = {unpack(r)}
	--r == the map data at map[x][y]
	table.remove(self.r, 1) --r[1] == tile index, can be used to look up properties in tilequads{}
	table.remove(self.r, 1) --r[2] == entity index, can be used to look up generic base entity in entitylist{}
	-- all indexes of r after this point are those that you defined by the rightclick menu.
	-- P-Switch Type
	if #self.r > 0 and self.r[1] ~= "link" then
		self.type = self.r[1]
		table.remove(self.r, 1)
	end
	-- Reusability
	if #self.r > 0 and self.r[1] ~= "link" then
		self.reusable = (self.r[1] == "true")
		table.remove(self.r, 1)
	end
	-- Carryable, Changes graphic
	if #self.r > 0 and self.r[1] ~= "link" then
		self.carryable = (self.r[1] == "true")
		table.remove(self.r, 1)
	end

	self.category = 19
	
	self.mask = {true}
	
	if self.carryable == true then
		self.frame = 3
	end
	
	if self.type == "blue" then
	self.color = 1
	elseif self.type == "grey" then
	self.color = 2
	end
	
end

function pswitch:update(dt)
	if self.destroy == true then
		return true
	end
	if pswitchactive["blue"] == true then -- Timers
		pswitchtimers["blue"] = pswitchtimers["blue"] + dt
		--print("Blue P-Switch is Active: '"..pswitchtimers["blue"].."' seconds.")
	end
	if pswitchactive["grey"] == true then
		pswitchtimers["grey"] = pswitchtimers["grey"] + dt
		--print("Grey P-Switch is Active: '"..pswitchtimers["grey"].."' seconds.")
	end
	
	if pswitchtimers["blue"] >= pswitchtime and self.inuse == true then -- Out of Time
		self.inuse = false
		pswitchtimers["blue"] = 0
		pswitchactive["blue"] = false
		
		if self.carryable == false then
			self.frame = 1
			print("Pop up the P-Switch.")
		elseif self.carryable == true then
			self.frame = 3
			print("Pop up the carryable P-Switch.")
		end
		
		print("Time up on Blue P-Switches.")
	end
	if pswitchtimers["grey"] >= pswitchtime and self.inuse == true then
		self.inuse = false
		pswitchtimers["grey"] = 0
		pswitchactive["grey"] = false
		
		if self.carryable == false then
			self.frame = 1
			print("Pop up the P-Switch.")
		elseif self.carryable == true then
			self.frame = 3
			print("Pop up the carryable P-Switch.")
		end
		
		print("Time up on Grey P-Switches.")
	end

	if pswitchactive["blue"] == false and pswitchactive["grey"] == false and switchtimeout == true then
		switchtimeout = false
		self:dead()
		print("Destroy that obnoxious music.")
	end
end

function pswitch:draw()
		love.graphics.draw(pswitchimg, pswitchquads[self.color][self.frame], math.floor((self.x-xscroll)*16*scale),((self.y-yscroll)*16*scale)-8*scale, 0, scale, scale)
end

function pswitch:hit()
	if self.inuse == false then
		if self.type == "blue" then -- Set Timer for the type.
			pswitchactive["blue"] = true
			pswitchtimers["blue"] = 0
		elseif self.type == "grey" then
			pswitchactive["grey"] = true
			pswitchtimers["grey"] = 0
		end
		
		if self.reusable == true then -- Check for Reusability.
			self.inuse = true
			print("P-Switch is flattened: It's reusable.")
		elseif self.reusable == false then
			self.destroy = true
			table.insert(objects["smokepuff"], smokepuff:new(self.x, self.y))
			print("P-Switch is destroy: No Reuse.")
		end
		
		
		if self.carryable == true and self.inuse == true then -- Graphical Guff.
			self.frame = 4
			print("P-Switch is carryable.")
		elseif self.carryable == false and self.inuse == true then
			self.frame = 2
			print("P-Switch is attached to the ground.")
		end

		switchtimeout = true
		playsound("switch", self.x, self.y)
		pswitch:alive() -- Obnoxiously overwrite the music every time someone hits one.
	end
end

function pswitch:alive()
	stopmusic()
	music:play("switchmusic.ogg")
end

function pswitch:dead()
	playmusic()
	music:stop("switchmusic.ogg")
end