weapon = class('weapon')
weapon.static.isWeapon = true
function weapon:init(parent)
	self.parent = parent
	self.primaryAttackDelay = 0 --can go negative on sufficiently large dt
	self.primaryAttackTimer = 0
	self.primaryAmmo = nil --if nil, then it doesn't use any
	self.secondaryAttackDelay = 0
	self.secondaryAttackTimer = 0
	self.secondaryAmmo = nil
	table.insert(objects["weapon"], self)
end

function weapon:update(dt)
	if self.primaryAttackDelay and self.primaryAttackTimer and self.primaryAttackTimer > 0 then
		self.primaryAttackTimer = self.primaryAttackTimer - dt
	end
	
	if self.secondaryAttackDelay and self.secondaryAttackTimer and self.secondaryAttackTimer > 0 then
		self.secondaryAttackTimer = self.secondaryAttackTimer - dt
	end
end

function weapon:draw()
	-- we don't have a standard draw procedure just yet
end

function weapon:primaryFire()
	--@TODO: make a check to see if the player is currently wielding the weapon
	if self.primaryAttackDelay and self.primaryAttackTimer and self.primaryAttackTimer <= 0 then
		-- time permits
		self.primaryAttackTimer = self.primaryAttackDelay
		return true
	else
		return false
	end
end

function weapon:secondaryFire()
	if self.secondaryAttackDelay and self.secondaryAttackTimer and self.secondaryAttackTimer <= 0 then
		-- time permits
		self.secondaryAttackTimer = self.secondaryAttackDelay
		return true
	else
		return false
	end
end