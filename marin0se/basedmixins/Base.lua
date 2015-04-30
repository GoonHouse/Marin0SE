-- this is a convenience collection while I clean house of baseentity
--[[
	this is a stub for static entities that control their own movement
	
	if you think you might need collision at any point, use HasPhysics instead
]]

Base = {
	x = 0, width  = 0, speedx = 0, centerx = 0,
	y = 0, height = 0, speedy = 0, centery = 0,
	z = 0, depth  = 0, speedz = 0, centerz = 0,
	
	moves = false,
	category = 1,
	mask = {true, false},
	active = true,
	drawable = true, --try to use the global drawhandler if possible, disable if we can't
}
--[[
	REQUIRES ATTRIBUTES:
	r
	
	EXPECTED STATIC PROPERTIES:
	
]]

function Base:setPosition(nx, ny, nz)
	if type(nx) == "table" then
		nz = nx[3]
		ny = nx[2]
		nx = nx[1]
	end
	self.x = nx or 0
	self.y = ny or 0
	self.z = nz or 0
end