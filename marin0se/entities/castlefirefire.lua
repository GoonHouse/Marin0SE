castlefirefire = class("castlefirefire")

function castlefirefire:init()
	--PHYSICS STUFF
	self.y = 0
	self.x = 0
	self.width = 8/16
	self.height = 8/16
	self.active = true
	self.moves = false
	self.category = 23
	
	self.kills = true
	
	self.mask = {	true,
					true, false, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true}
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = fireballimg
	self.quad = fireballquad[1]
	self.offsetX = 4
	self.offsetY = 4
	self.quadcenterX = 4
	self.quadcenterY = 4
end