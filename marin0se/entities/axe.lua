axe = class("axe")

function axe:init(x, y, r)
	self.cox = x
	self.coy = y

	self.x = x-1
	self.y = y-1
	self.speedx = 0
	self.speedy = 0
	self.moves = false
	self.active = true
	self.width = 1
	self.height = 1
	self.category = 6
	self.mask = {true}
	self.drawable = true
	self.quad = 1
	self.rotation = 0
	self.timer = 0
	self.falling = false
	self.destroy = false
	self.r = {unpack(r)}

	table.remove(self.r, 1)
	table.remove(self.r, 1)
	if #self.r > 0 and self.r[1] ~= "link" then
		self.value = self.r[1]
		table.remove(self.r, 1)
	end
	
	if #self.r > 0 and self.r[1] ~= "link" then
		self.size = self.r[1]
		table.remove(self.r, 1)
	end
	
	self.out = false
	self.outtable = {}
end

function axe:update(dt)
	-- returning in the update method signals the object handler to destroy us
	--[[if redcoincollected[self.value] >= 1 then  -- The why do you have dupes checker.
	self.destroy = true
	return true
	end]]
	
	-- probably some redundancy here \o/
	if self.out then
		for i = 1, #self.outtable do
			if self.outtable[i][1].input then
				self.outtable[i][1]:input("on", self.outtable[i][2])
			else
				self.outtable[i][1]:input("off", self.outtable[i][2])
			end
		end
	end
	
	if self.destroy then
		return true
	end
end

function axe:collect(ply)
	-- ply is a reference to the player that collected us, we can use that later
	self.out = true
	self.active = false
	self.drawable = false
	
	if levelfinished then
		return
	end
	ply.ducking = false
	for i = 1, players do
		objects["player"][i]:removeportals()
	end
	
	for i, v in pairs(objects["platform"]) do
		objects["platform"][i] = nil
	end

	ply.raccoontimer = 0
	ply.animation = "axe"
	ply.invincible = false
	ply.drawable = true
	ply.animationx = self.x
	ply.animationy = self.y
	ply.animationbridgex = self.x
	ply.controlsenabled = false
	ply.animationtimer = 0
	ply.speedx = 0
	ply.speedy = 0
	ply.gravity = 0
	ply.active = false
	ply.infunnel = false
	levelfinished = true
	levelfinishtype = "castle"
	levelfinishedmisc = 0
	levelfinishedmisc2 = 1
	if marioworld == 8 then
		levelfinishedmisc2 = 2
	end
	bridgedisappear = false
	ply.animationtimer2 = castleanimationbridgedisappeardelay
	bowserfall = false
	
	objects["screenboundary"]["axe"] = nil
	
	if objects["bowser"][1] and not objects["bowser"][1].shot then
		local v = objects["bowser"][1]
		v.speedx = 0
		v.speedy = 0
		v.active = false
		v.gravity = 0
		v.category = 1
	else
		ply.animationtimer = castleanimationmariomove
		ply.active = true
		ply.gravity = mariogravity
		ply.animationstate = "running"
		ply.speedx = 4.27
		ply.pointingangle = -math.pi/2
		ply.animationdirection = "right"
	end
	
	--self.destroy = true
end

function axe:draw()
	if self.drawable then
		love.graphics.draw(axeimg, axequads[coinframe], math.floor((self.cox-1-xscroll)*16*scale), (self.coy-1.5-yscroll)*16*scale, 0, scale, scale)
	end
end

function axe:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end