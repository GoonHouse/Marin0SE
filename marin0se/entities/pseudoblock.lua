pseudoblock = class("pseudoblock")

--[[@NOTE:
	This is here to replace blockbounce timer, or any other blocks that are emancipated from the spritebatch.
	If it looks and acts like a block but isn't on the grid, it's this guy.
	
	The body of this code's update lives in world.lua for now.
]]


function pseudoblock:init(x, y, block, mode)
	self.block = block --the block to immitate
	-- the position of the block
	self.x = x
	self.y = y
	
	self.mode = mode or "bounce" --"bounce", "still"
	print("conblockTimeout")
	
		destroyblock(self.x, self.y, ply)
	self.bouncetimer = 0
end

	print("bounceCallback")
function pseudoblock:update(dt)
	
end

function pseudoblock:draw()
	
end