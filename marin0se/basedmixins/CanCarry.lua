-- this provides the info so the object can be carried and held in the player's hands like a box

CanCarry = {
	carrier = nil, --who is carrying the this, if anybody at all
	carriable = true, --if, for whatever reason, we wish to not be carriable
}

function CanCarry:used(ply)
	-- where ply is a reference to the player object
	if self.carriable then
		self.carrier = ply
		self.active = false
		ply:pick_up(self)
		self:setInfluence(ply) 
	end
end

function CanCarry:drop()
	if self.carriable then
		self.carrier = nil
		self.active = true
	else
		print("WARNING: CanCarry was dropped but it wasn't supposed to be carried in the first place.")
	end
end