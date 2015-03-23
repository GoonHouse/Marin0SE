function gethatoffset(char, graphic, animationstate, runframe, jumpframe, climbframe, swimframe, underwater, infunnel, fireanimationtimer, ducking)
	local hatoffset
	if graphic == char.animations or graphic == char.nogunanimations then
		if not char.hatoffsets then
			return
		end
		
		if infunnel then
			hatoffset = char.hatoffsets["jumping"][jumpframe]
		elseif underwater and (animationstate == "jumping" or animationstate == "falling") then
			hatoffset = char.hatoffsets["swimming"][swimframe]
		elseif animationstate == "jumping" then
			hatoffset = char.hatoffsets["jumping"][jumpframe]
		elseif animationstate == "running" or animationstate == "falling" then
			hatoffset = char.hatoffsets["running"][runframe]
		elseif animationstate == "climbing" then
			hatoffset = char.hatoffsets["climbing"][climbframe]
		end
	else
		if not char.bighatoffsets then
			return
		end
		if infunnel or animationstate == "jumping" and not ducking then
			hatoffset = char.bighatoffsets["jumping"][jumpframe]
		elseif underwater and (animationstate == "jumping" or animationstate == "falling") then
			hatoffset = char.bighatoffsets["swimming"][swimframe]
		elseif ducking then
			hatoffset = char.bighatoffsets["ducking"]
		elseif fireanimationtimer < fireanimationtime then
			hatoffset = char.bighatoffsets["fire"]
		else
			if animationstate == "running" or animationstate == "falling" then
				hatoffset = char.bighatoffsets["running"][runframe]
			elseif animationstate == "climbing" then
				hatoffset = char.bighatoffsets["climbing"][climbframe]
			end
		end
	end
	
	if not hatoffset then
		if graphic == char.animations or graphic == char.nogunanimations then
			hatoffset = char.hatoffsets[animationstate]
		else
			hatoffset = char.bighatoffsets[animationstate]
		end
	end
	
	return hatoffset
end

function twistdirection(gravitydir, dir)
	if not gravitydir or (gravitydir > math.pi/4*1 and gravitydir <= math.pi/4*3) then
		if dir == "floor" then
			return "floor"
		elseif dir == "left" then
			return "left"
		elseif dir == "ceil" then
			return "ceil"
		elseif dir == "right" then
			return "right"
		end
	elseif gravitydir > math.pi/4*3 and gravitydir <= math.pi/4*5 then
		if dir == "floor" then
			return "left"
		elseif dir == "left" then
			return "ceil"
		elseif dir == "ceil" then
			return "right"
		elseif dir == "right" then
			return "floor"
		end
	elseif gravitydir > math.pi/4*5 and gravitydir <= math.pi/4*7 then
		if dir == "floor" then
			return "ceil"
		elseif dir == "left" then
			return "right"
		elseif dir == "ceil" then
			return "floor"
		elseif dir == "right" then
			return "left"
		end
	else
		if dir == "floor" then
			return "right"
		elseif dir == "left" then
			return "floor"
		elseif dir == "ceil" then
			return "left"
		elseif dir == "right" then
			return "ceil"
		end
	end
end

function hitblock(x, y, t, koopa)	
	for i, v in pairs(t.world.objects.portal) do
		if v.x1 and v.x2 and v.y1 and v.y2 then
			local x1 = v.x1
			local y1 = v.y1
			
			local x2 = v.x2
			local y2 = v.y2
			
			local x3 = x1
			local y3 = y1
			
			if v.facing1 == "up" then
				x3 = x3+1
			elseif v.facing1 == "right" then
				y3 = y3+1
			elseif v.facing1 == "down" then
				x3 = x3-1
			elseif v.facing1 == "left" then
				y3 = y3-1
			end
			
			local x4 = x2
			local y4 = y2
			
			if v.facing2 == "up" then
				x4 = x4+1
			elseif v.facing2 == "right" then
				y4 = y4+1
			elseif v.facing2 == "down" then
				x4 = x4-1
			elseif v.facing2 == "left" then
				y4 = y4-1
			end
			
			if (x == x1 and y == y1) or (x == x2 and y == y2) or (x == x3 and y == y3) or (x == x4 and y == y4) then
				return
			end
		end
	end


	if editormode then
		return
	end

	if not t.world:inmap(x, y) then
		return
	end
	
	local r = t.world.map[x][y]
	if not t or not t.infunnel then
		playsound("blockhit", x-0.5, y-1)
	end
	
	if tilequads[r[1]]:getproperty("breakable", x, y) == true or tilequads[r[1]]:getproperty("coinblock", x, y) == true then --Block should bounce!
		table.insert(blockbouncetimer, 0.000000001) --yeah it's a cheap solution to a problem but screw it.
		table.insert(blockbouncex, x)
		table.insert(blockbouncey, y)
		if #r > 1 and entitylist[r[2]] and entitylist[r[2]].t ~= "manycoins" then --block contained something!
			table.insert(blockbouncecontent, entitylist[r[2]].t)
			table.insert(blockbouncecontent2, t.size)
			if tilequads[r[1]]:getproperty("invisible", x, y) then
				if spriteset == 1 then
					map[x][y][1] = 113
				elseif spriteset == 2 then
					map[x][y][1] = 118
				else
					map[x][y][1] = 112
				end
			else
				if spriteset == 1 then
					map[x][y][1] = 113
				elseif spriteset == 2 then
					map[x][y][1] = 114
				else
					map[x][y][1] = 117
				end
			end
			if entitylist[r[2]].t == "vine" then
				--playsound("vine", x-0.5, y-1)
			else
				playsound("mushroomappear", x-0.5, y-1)
			end
		elseif #r > 1 and table.contains(enemies, r[2]) then
			table.insert(blockbouncecontent, r[2])
			table.insert(blockbouncecontent2, t.size)
			playsound("mushroomappear", x-0.5, y-1)
			
			
			if tilequads[r[1]]:getproperty("invisible", x, y) then
				if spriteset == 1 then
					map[x][y][1] = 113
				elseif spriteset == 2 then
					map[x][y][1] = 118
				else
					map[x][y][1] = 112
				end
			else
				if spriteset == 1 then
					map[x][y][1] = 113
				elseif spriteset == 2 then
					map[x][y][1] = 114
				else
					map[x][y][1] = 117
				end
			end
		else
			table.insert(blockbouncecontent, false)
			table.insert(blockbouncecontent2, t.size)
			
			if (koopa or (t and t.size > 1)) and tilequads[r[1]]:getproperty("coinblock", x, y) == false and (#r == 1 or (entitylist[r[2]] and entitylist[r[2]].t ~= "manycoins")) then --destroy block!
				destroyblock(x, y, t)
			end
		end
		
		if #r == 1 and tilequads[r[1]]:getproperty("coinblock", x, y) then --coinblock
			playsound("coin", x-0.5, y-1) --not sure if these slight offsets are correct
			if tilequads[r[1]]:getproperty("invisible", x, y) then
				if spriteset == 1 then
					map[x][y][1] = 113
				elseif spriteset == 2 then
					map[x][y][1] = 118
				else
					map[x][y][1] = 112
				end
			else
				if spriteset == 1 then
					map[x][y][1] = 113
				elseif spriteset == 2 then
					map[x][y][1] = 114
				else
					map[x][y][1] = 117
				end
			end
			if #r == 1 then
				table.insert(coinblockanimations, coinblockanimation:new(x-0.5, y-1))
				
				traceinfluence(t):getcoin(1, nil, nil, x-0.5, y-1)
				--@WARNING: These might not be right, but, who knows
			end
		end
		
		if #r > 1 and entitylist[r[2]] and entitylist[r[2]].t == "manycoins" then --block with many coins inside! yay $_$
			table.insert(coinblockanimations, coinblockanimation:new(x-0.5, y-1))
			traceinfluence(t):getcoin(1, nil, nil, x-0.5, y-1)
			
			local exists = false
			for i = 1, #coinblocktimers do
				if x == coinblocktimers[i][1] and y == coinblocktimers[i][2] then
					exists = i
				end
			end
			
			if not exists then
				table.insert(coinblocktimers, {x, y, coinblocktime})
			elseif coinblocktimers[exists][3] <= 0 then
				--@WARNING: Magic tileID transformations, this is bad.
				if spriteset == 1 then
					map[x][y][1] = 113
				elseif spriteset == 2 then
					map[x][y][1] = 114
				else
					map[x][y][1] = 117
				end
			end
		end
		
		--kill enemies on top
		for j, w in pairs(objects["enemy"]) do
			if not w.notkilledfromblocksbelow then
				local centerX = w.x + w.width/2
				if inrange(centerX, x-1, x, true) and y-1 == w.y+w.height then
					--get dir
					local dir = "right"
					if w.x+w.width/2 < x-0.5 then
						dir = "left"
					end
					
					--if w.shotted then
					--@WARNING: FLAGRANTLY DISREGARDING SAFETY
					w:do_damage("bump", traceinfluence(t), dir, true)
						--addpoints(100, w.x+w.width/2, w.y)
						--@WARNING: origin of points might not be right, but, who knows
					--end
				end
			end
		end
		
		--make items jump
		for j, w in pairs(objects["enemy"]) do
			if w.jumpsfromblocksbelow then
				local centerX = w.x + w.width/2
				if inrange(centerX, x-1, x, true) and y-1 == w.y+w.height then
					w.falling = true
					w.speedy = -(w.jumpforce or mushroomjumpforce)
					if w.x+w.width/2 < x-0.5 then
						w.speedx = -math.abs(w.speedx)
					elseif w.x+w.width/2 > x-0.5 then
						w.speedx = math.abs(w.speedx)
					end
				end
			end
		end
		
		--check for coin on top
		if inmap(x, y-1) and coinmap[x][y-1] then
			traceinfluence(t):getcoin(1, x, y-1)
			table.insert(coinblockanimations, coinblockanimation:new(x-0.5, y-1))
		end
		generatespritebatch()
	end
end

function destroyblock(x, y, t)
	for i = 1, players do
		local v = objects["player"][i].portal
		local x1 = v.x1
		local y1 = v.y1
		
		local x2 = v.x2
		local y2 = v.y2
		
		local x3 = x1
		local y3 = y1
		
		if v.facing1 == "up" then
			x3 = x3+1
		elseif v.facing1 == "right" then
			y3 = y3+1
		elseif v.facing1 == "down" then
			x3 = x3-1
		elseif v.facing1 == "left" then
			y3 = y3-1
		end
		
		local x4 = x2
		local y4 = y2
		
		if v.facing2 == "up" then
			y4 = y4-1
		elseif v.facing2 == "right" then
			x4 = x4+1
		elseif v.facing2 == "down" then
			y4 = y4+1
		elseif v.facing2 == "left" then
			x4 = x4-1
		end
		
		if (x == x1 and y == y1) or (x == x2 and y == y2) or (x == x3 and y == y3) or (x == x4 and y == y4) then
			return
		end
	end
	
	map[x][y][1] = 1
	objects["tile"][x .. "-" .. y] = nil
	map[x][y]["gels"] = {}
	playsound("blockbreak", x, y) --blocks don't move, we want the position of the block
	
	traceinfluence(t):getscore(score_enum.block_break, x-0.5, y-1)
	
	blockdebris:new(x, y, "right", 1)
	blockdebris:new(x, y, "right", 0)
	blockdebris:new(x, y, "left", 1)
	blockdebris:new(x, y, "left", 0)
	
	generatespritebatch()
end

function traceinfluence(b)
	if not b then return nil end
	
	if b.getcoin then
		return b
	elseif b.lastinfluence then
		return b.lastinfluence
	else
		print("CRITICAL: Couldn't trace an influence from", b)
		return b
	end
end

function getAngleFrame(angle, rotation)
	angle = angle + rotation

	if angle > math.pi then
		angle = angle - math.pi*2
	elseif angle < -math.pi then
		angle = angle + math.pi*2
	end

	local mouseabs = math.abs(angle)
	local angleframe
	
	if mouseabs < math.pi/8 then
		angleframe = 1
	elseif mouseabs >= math.pi/8 and mouseabs < math.pi/8*3 then
		angleframe = 2
	elseif mouseabs >= math.pi/8*3 and mouseabs < math.pi/8*5 then
		angleframe = 3
	elseif mouseabs >= math.pi/8*5 and mouseabs < math.pi/8*7 then
		angleframe = 4
	elseif mouseabs >= math.pi/8*7 then
		angleframe = 4
	end
	
	return angleframe
end