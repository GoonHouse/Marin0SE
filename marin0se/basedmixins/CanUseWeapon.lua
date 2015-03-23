CanUseWeapon = {
	activeWeapon = nil, --class weapon
	weapons = {}, --array of weapons, keyed by name
	
	weaponEnabled = true, 
}

function CanUseWeapon:primaryFire()
	if self.activeWeapon and self.weaponEnabled then 
		self.activeWeapon:primaryFire()
	end
end

function CanUseWeapon:secondaryFire()
	if self.activeWeapon and self.weaponEnabled then 
		self.activeWeapon:secondaryFire()
	end
end

function CanUseWeapon:reloadFire()
	if self.activeWeapon and self.weaponEnabled then 
		self.activeWeapon:primaryFire()
	end
end

function CanUseWeapon:collectWeapon(weapon)
	--if weapon.isWeapon then
	self.weapons[weapon.name] = weapon
	weapon:setOwner(self)
end

function CanUseWeapon:equipWeapon(weaponName)
	self.activeWeapon = self.weapons[weaponName]
end

function CanUseWeapon:dropWeapon(weaponName)
	if self.activeWeapon.name == weaponName then
		self.activeWeapon = nil
	end
	self.weapons[weaponName]:drop()
	self.weapons[weaponName] = nil
end