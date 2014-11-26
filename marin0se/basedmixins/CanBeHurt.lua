CanBeHurt = {
	health = 1,
	immunities = {},
	
}

-- make hurt a method, if no target, inflict on self?

-- check if damage can be done
function CanBeHurt:processDamage(attacker, dtype, damageamount, ...)
	
end

-- this is simply for subtracting from our health
function CanBeHurt:hurt(attacker, dtype, damageamount, ...)
	
end

-- this kills the man
function CanBeHurt:kill(attacker, dtype, damageamount, ...)
	
end