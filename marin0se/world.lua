world = class("world")
--[[
	world is meant to contain the global gamestate info that does not belong to players
	the idea is that world is supposed to be an interface for all the global functions and data
	that are getting used everywhere
	
	additionally, map info is available through this, but it is important to note that 
	we want to be able to extend this functionality such that multiple maps can be loaded
	simultaneously, but they would belong to the same world so the timer and such would be
	shared
	
	since world is a class there can be multiple worlds and by utilizing this we would have
	multiple sets of worlds loaded simultaneously
	
	modifying this file to teach bungalo something
]]

function world:init()
	self.map = { --x
			{ --y
				{ --z
					{}, --element at 1,1,1
				},
			},
		}
	self.friction = 14
	--[[significant friction values:
		14 = base friction for motionless players
		20 = friction the box 
		100 = "superfriction" for when player's run speed is above maxrunspeed
	]]
	self.friction_air_multiplier = 0
	--[[significant air friction values:
		0 = basically nothing cares about air
	]]
	self.gravity = 80 --this is aliased as "yacceleration" in the code, so be aware
	--[[significant gravity values:
		30 = player's gravity while jumping
		
	]]
end