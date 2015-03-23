IsWorldObject = {
	x = 0,
	y = 0,
	z = 0,
	
	world = nil,
}

function IsWorldObject:setWorld(world)
	self.world = world
end

function IsWorldObject:setPosition(x, y, z)
	self.x = x
	self.y = y
	self.z = z
end