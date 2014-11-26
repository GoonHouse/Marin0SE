pseudoblock = class("pseudoblock")

--[[@NOTE:
	This is here to replace blockbounce timer, or any other blocks that are emancipated from the spritebatch.
	If it looks and acts like a block but isn't on the grid, it's this guy.
	
	The body of this code's update lives in world.lua for now.
]]


function pseudoblock:init(x, y, block, map)
	self.map = map
	self.block = block --the block to immitate
	-- the position of the block
	self.x = x
	self.y = y
	
	self.bouncers = {"enemy", "item"}
	-- all the x and y coordinates we give were x-0.5, y-1; we decided against that to see what'd happen
end
--spawn item
--table.insert(blockbouncecontent, entitylist[r[2]].t)
--table.insert(blockbouncecontent2, t.size)

--spawn enemy
--table.insert(blockbouncecontent, r[2])
--table.insert(blockbouncecontent2, t.size)

--spawn nothing
--table.insert(blockbouncecontent, false)
--table.insert(blockbouncecontent2, t.size)

function pseudoblock:coinblockTimeout()
	self.destroy = true
	self:changeBlock(enum_itemblock_visible[spriteset])
end

function pseudoblock:hit(ply, do_destroy)
	local contents
	local soundtoplay
	local blockType
	local doBounce = false
	local batchUpdate = false
	
	if #self.block > 1 and entitylist[self.block[2]] then
		contents = entitylist[self.block[2]]
		if entitylist[self.block[2]].t ~= "manycoins" then
			soundtoplay = "mushroomappear"
			if entitylist[self.block[2]] and entitylist[self.block[2]].t == "vine" then
				soundtoplay = "vine"
				--@NOTE: technically, the vine should play its sound upon spawning so we needn't do it here
			end
			blockType = "item"
		else
			blockType = "manycoins"
		end
	elseif #self.block > 1 and (table.contains(enemies, self.block[2])) then
		contents = self.block[2]
		soundtoplay = "mushroomappear"
		blockType = "enemy"
	elseif #self.block == 1 and tilequads[self.block[1]]:getproperty("coinblock") then
		--soundtoplay = "coin"
		blockType = "coin"
	end
	
	if blockType then
		if tilequads[self.block[1]]:getproperty("invisible") then
			self:changeBlock(enum_itemblock_invisible[spriteset])
		else
			self:changeBlock(enum_itemblock_visible[spriteset])
		end
		batchUpdate = true
		
		if soundtoplay then
			playsound(soundtoplay, self.x, self.y)
		end
		
		if blockType == "coin" or blockType == "manycoins" then
			table.insert(self.map.objects.coinblockanimation, coinblockanimation:new(self.x, self.y))
			-- we don't use soundtoplay because getcoin does that
			traceinfluence(ply):getcoin(1, nil, nil, self.x, self.y)
			
			if blockType == "manycoins" then
				if not timer.Exists(self) then
					--[[@WARNING:
						This could potentially be an infinite coin block if struck
						between the timer expiring and the next update.
					]]
					timer.Create(self, coinblocktime, 1, function() self:coinblockTimeout() end)
				end
			elseif table.contains(self.bouncers, blockType) and not timer.Exists(self) then
				timer.Create(self, blockbouncetime, 1, function() self:bounceCallback(content, ply.size) end)
			end
		end
	end
	
	if do_destroy then
		destroyblock(self.x, self.y, ply)
		batchUpdate = true
	end
	
	--kill enemies on top
	for j, w in pairs(self.map.objects.enemy) do
		local centerX = w.x + w.width/2
		if inrange(centerX, self.x-1, self.x, true) and self.y-1 == w.y+w.height then
			if not w.notkilledfromblocksbelow then --kill enemy on top
				--get dir
				local dir = "right"
				if w.x+w.width/2 < self.x-0.5 then
					dir = "left"
				end
				
				w:do_damage("bump", traceinfluence(ply), dir, true)
			elseif w.jumpsfromblocksbelow then --make the enemy jump
				w.falling = true
				w.speedy = -(w.jumpforce or mushroomjumpforce)
				if w.x+w.width/2 < self.x-0.5 then
					w.speedx = -math.abs(w.speedx)
				elseif w.x+w.width/2 > self.x-0.5 then
					w.speedx = math.abs(w.speedx)
				end
			end
		end
	end
	
	-- get coin on top of block
	if self.map:inmap(self.x, self.y-1) and self.map.coinmap[self.x][self.y-1] then
		traceinfluence(ply):getcoin(1, self.x, self.y-1)
		table.insert(self.map.objects.coinblockanimation, coinblockanimation:new(self.x, self.y-1))
	end
	
	-- just assume we touched the map layout
	if batchUpdate then
		generatespritebatch()
	end
end

function pseudoblock:bounceCallback(content, size)
	item(content, self.x, self.y, size)
end

function pseudoblock:changeBlock(nid)
	print("DEFLOG: ", self.x, self.y, self.map, nid)
	self.map.map[self.x][self.y][1] = nid
end

function pseudoblock:update(dt)
	if not timer.Exists(self) then
		return self.destroy
	else
		generatespritebatch()
	end
end

function pseudoblock:draw()
	
end