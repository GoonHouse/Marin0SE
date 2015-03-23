AdvancedPhysics = {
	body = nil, --Body userdata
	fixture = nil, --Fixture userdata
	rotation = 0,
	
	collidable = true, --Makes debuggable with STI's shape drawing.
}

function AdvancedPhysics:newSimplePhysics(phys_type)
	phys_type = phys_type or "dynamic"
	self.body = love.physics.newBody(self.world, self.x/2, self.y/2, phys_type)
	self.fixture = love.physics.newFixture(self.body, love.physics.newRectangleShape(self.width, self.height))
	self.shape = self.fixture:getShape()
	self.body:setLinearDamping(10)
end