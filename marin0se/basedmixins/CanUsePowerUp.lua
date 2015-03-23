CanUsePowerUp = {
	currentPowerUp = nil --class powerup or something
}

--- A method that allows things to utilize a given power up.
-- When this is used, a power up is meant to be stored
-- somewhere in memory without destroying the object
-- because inventory systems and stuff.
-- @param powerup 
function CanUsePowerUp:collectPowerUp(powerup)
	self.currentPowerUp = powerup
end

