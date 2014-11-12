CanDamage = {
	-- what kind of damage this does
	doesdamagetype = "toilet",
}

function CanDamage:doDamage(target, ...)
	target:do_damage(self.doesdamagetype, self.lastinfluence, ...)
end