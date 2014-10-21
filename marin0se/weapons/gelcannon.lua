gelcannon = class('gelcannon', weapon)
gelcannon.static.name = 'gelcannon'
function gelcannon:init(parent)
	weapon.init(self,parent)
	self.primaryAttackDelay = gelcannondelay
	self.secondaryAttackDelay = gelcannondelay
	--gelcannonspeed = 30
end

function gelcannon:update(dt)
	weapon.update(self,dt)
	-- nothin'
end

function gelcannon:shootGel(i)
	local newgel = gel:new(self.parent.x+self.parent.width/2+8/16, self.parent.y+self.parent.height/2+6/16, i)
	newgel.speedx = math.cos(-self.parent.pointingangle-math.pi/2)*gelcannonspeed
	newgel.speedy = math.sin(-self.parent.pointingangle-math.pi/2)*gelcannonspeed
	
	table.insert(objects["gel"], newgel)
end

function gelcannon:primaryFire()
	if self.parent and weapon.primaryFire(self) then
		self:shootGel(1)
	else
		print("DEBUG: Tried to shoot gel1 with orphaned weapon?!")
	end
end

function gelcannon:secondaryFire()
	if self.parent and weapon.secondaryFire(self) then
		self:shootGel(2)
	else
		print("DEBUG: Tried to shoot gel2 with orphaned weapon?!")
	end
end