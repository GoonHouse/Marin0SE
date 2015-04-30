--[[
	this is primarily for tracking who touched something last for kill attribution
]]
CanInfluence = {
	canInfluence = true,
	influencers = {},
	lastInfluence = nil,
	
	-- if this is capable of being influenced by a player to kill someone
	influencable = true,
	-- last player to touch this, or nobody
}

function CanInfluence:setInfluence(inf)
	if self.influencable then
		self.lastinfluence = inf
		return true
	else
		return false
	end
end