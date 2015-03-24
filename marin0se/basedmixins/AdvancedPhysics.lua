--[[
	some year in the future, we'll transpose this to override box2d methods
	and provide appropriate transforms in a love2d API sort of way
]]

--[[
	USED STATICS:
	image_sigs
	PHYS_BODY_TYPE
	PHYS_BODY_MASS
	PHYS_BODY_CENTER_OF_MASS
	PHYS_SHAPE
	PHYS_SHAPE_SIZE
]]

AdvancedPhysics = {
	body = nil, --Body userdata
	fixture = nil, --Fixture userdata
	rotation = 0,
	
	collidable = true, --Makes debuggable with STI's shape drawing.
}

function AdvancedPhysics.inithook(self, t) --t is the named parameters for baseentity's init method
	local k = t.class.static
	self.world = t.world
	self.body = love.physics.newBody(self.world.pworld, t.x, t.y, k.PHYS_BODY_TYPE)
	self.body:setMass(k.PHYS_BODY_CENTER_OF_MASS[1], k.PHYS_BODY_CENTER_OF_MASS[2], k.PHYS_BODY_MASS)
	local shape
	if k.PHYS_SHAPE == "rectangle" then
		shape = love.physics.newRectangleShape(unpack(k.PHYS_SHAPE_SIZE))
	else
		assert(false, "Unsupported physics shape (PHYS_SHAPE) in BasedEntity definition.")
	end
	self.fixture = love.physics.newFixture(self.body, shape)
	self.shape = self.fixture:getShape()
	self.body:setLinearDamping(k.PHYS_BODY_LINEAR_DAMPING)
end

function AdvancedPhysics:newSimplePhysics(phys_type)
	phys_type = phys_type or "dynamic"
	self.body = love.physics.newBody(self.world, 0, 0, phys_type)
	self.body:setMass(8, 8, 1)
	self.fixture = love.physics.newFixture(self.body, love.physics.newRectangleShape(16, 16))
	self.shape = self.fixture:getShape()
	self.body:setLinearDamping(10)
end

function AdvancedPhysics:included(klass)
	registerInitHook(klass, AdvancedPhysics.inithook)
	--table.insert(klass.inithooks, {AdvancedPhysics, "ap"})
end