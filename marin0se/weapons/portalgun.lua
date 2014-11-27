portalgun = class('portalgun', weapon)
function portalgun:init(parent)
	weapon.init(self,parent)
end

function portalgun:update(dt)
	weapon.update(self,dt)
	-- nothin'
end

function portalgun:draw()
	weapon.draw(self)
	
	-- @TODO: We could probably internalize a lot of these properties.
	local ply = self.parent
	if ply and ply.controlsenabled and ply.activeweapon == self and not ply.vine and table.contains(ply.portalsavailable, true) then
		local sourcex, sourcey = ply.x+6/16, ply.y+6/16
		--@DEV: commented out because stuff
		local cox, coy, side, tend, x, y = self:traceline(sourcex, sourcey, ply.pointingangle)
		local portalpossible = true
		if cox == false or self:getportalposition(1, cox, coy, side, tend) == false then
			portalpossible = false
		end
		
		-- DRAW THE DOTS
		love.graphics.setColor(255, 255, 255, 255)
		local dist = math.sqrt(((x-xscroll)*16*scale - (sourcex-xscroll)*16*scale)^2 + ((y-.5-yscroll)*16*scale - (sourcey-.5-yscroll)*16*scale)^2)/16/scale
		for i = 1, dist/portaldotsdistance+1 do
			if((i-1+portaldotstimer/portaldotstime)/(dist/portaldotsdistance)) < 1 then
				local xplus = ((x-xscroll)*16*scale - (sourcex-xscroll)*16*scale)*((i-1+portaldotstimer/portaldotstime)/(dist/portaldotsdistance))
				local yplus = ((y-.5-yscroll)*16*scale - (sourcey-.5-yscroll)*16*scale)*((i-1+portaldotstimer/portaldotstime)/(dist/portaldotsdistance))
				
				local dotx = (sourcex-xscroll)*16*scale + xplus
				local doty = (sourcey-.5-yscroll)*16*scale + yplus
				
				local radius = math.sqrt(xplus^2 + yplus^2)/scale
				
				local alpha = 255
				if radius < portaldotsouter then
					alpha = (radius-portaldotsinner) * (255/(portaldotsouter-portaldotsinner))
					if alpha < 0 then
						alpha = 0
					end
				end
				
				
				if portalpossible == false then
					love.graphics.setColor(255, 0, 0, alpha)
				else
					love.graphics.setColor(0, 255, 0, alpha)
				end
				
				love.graphics.draw(portaldotimg, math.floor(dotx-0.25*scale), math.floor(doty-0.25*scale), 0, scale, scale)
			end
		end
		
		-- DRAW CROSSHAIR
		love.graphics.setColor(255, 255, 255, 255)
		if cox ~= false then
			if portalpossible == false then
				love.graphics.setColor(255, 0, 0)
			else
				love.graphics.setColor(0, 255, 0)
			end
			
			local rotation = 0
			if side == "right" then
				rotation = math.pi/2
			elseif side == "down" then
				rotation = math.pi
			elseif side == "left" then
				rotation = math.pi/2*3
			end
			love.graphics.draw(portalcrosshairimg, math.floor((x-xscroll)*16*scale), math.floor((y-.5-yscroll)*16*scale), rotation, scale, scale, 4, 8)
		end
	end
end

function portalgun:shootPortal(i, mirrored)
	local sourcex, sourcey = self.parent.x+6/16, self.parent.y+6/16
	local direction = self.parent.pointingangle
	local world = self.parent.world
	local mirror = false
	local cox, coy, side, tendency, x, y = self:traceline(sourcex, sourcey, direction)
	if not world:inmap(cox,coy) then
		return
	end
	
	if self.parent.portalgundisabled then
		return
	end
	
	--check if available
	if not self.parent.portalsavailable[i] then
		return
	end
	
	--box
	if self.parent.pickup then
		return
	end
	
	--portalgun delay
	if self.parent.portaldelay > 0 then
		return
	else
		self.parent.portaldelay = portalgundelay
	end
	
	local otheri = 1
	local color = self.parent.portal2color
	if i == 1 then
		otheri = 2
		color = self.parent.portal1color
	end
	
	if not mirrored then
		self.parent.lastportal = i
	end
	
	local tile = world.map[cox][coy]
	if cox then
		mirror = tilequads[tile[1]]:getproperty("mirror", cox, coy)
		if tile["gels"] and tile["gels"][side] then
			local gelstat = tile["gels"][side]
			if mirror and table.contains(gelsthattarnishmirrors, enum_gels[gelstat]) then
				mirror = false
			end
		--	elseif mirror and enum_gels[gelstat] == "white" then
		--		mirror = false
		--	end
		end
	end
	
	self.parent.lastportal = i
	
	table.insert(self.parent.world.objects.portalprojectile, 
		portalprojectile:new(sourcex, sourcey, x, y, color, true, 
			{self.parent.portal, i, cox, coy, side, tendency, x, y},
			mirror, mirrored)
	)
	
	if not mirrored and cheats_active.portalknockback then
		local xadd = math.sin(self.parent.pointingangle)*30
		local yadd = math.cos(self.parent.pointingangle)*30
		self.parent.speedx = self.parent.speedx + xadd
		self.parent.speedy = self.parent.speedy + yadd
		self.parent.falling = true
		self.parent.animationstate = "falling"
		self.parent:setquad()
	end
end

function portalgun:primaryFire()
	if self.parent and weapon.primaryFire(self) then
		self:shootPortal(1)
	else
		print("DEBUG: Tried to shoot portal1 with orphaned weapon?!")
	end
end

function portalgun:secondaryFire()
	if self.parent and weapon.secondaryFire(self) then
		self:shootPortal(2)
	else
		print("DEBUG: Tried to shoot portal with orphaned weapon?!")
	end
end

function portalgun:traceline(sourcex, sourcey, radians, reportal)
	local currentblock = {}
	local x, y = sourcex, sourcey
	local world = self.parent.world
	currentblock[1] = math.floor(x)
	currentblock[2] = math.floor(y+1)
	
	local emancecollide = false
	for i, v in pairs(world.objects["emancipationgrill"]) do
		if v:getTileInvolved(currentblock[1]+1, currentblock[2]) then
			emancecollide = true
		end
	end
	
	local doorcollide = false
	for i, v in pairs(world.objects["door"]) do
		if v.dir == "hor" then
			if v.open == false and (v.cox == currentblock[1] or v.cox == currentblock[1]+1) and v.coy == currentblock[2] then
				doorcollide = true
			end
		else
			if v.open == false and v.cox == currentblock[1]+1 and (v.coy == currentblock[2] or v.coy == currentblock[2]+1) then
				doorcollide = true
			end
		end
	end
	
	if emancecollide or doorcollide then
		return false, false, false, false, x, y
	end
	
	local side
	local lastaxe = world.objects.axe[#world.objects.axe]
	while currentblock[1]+1 > 0 and
	currentblock[1]+1 <= self.parent.world.map.width and
	-- we'll just get rid of this and see what happens
	(world.flagx == false or currentblock[1]+1 <= world.flagx or radians > 0) and
	(not lastaxe or currentblock[1]+1 <= lastaxe.cox) and 
	(currentblock[2] > 0 or currentblock[2] >= math.floor(sourcey+0.5)) and 
	currentblock[2] < world.map.height+1 do --while in map range
		local oldy = y
		local oldx = x
		
		--calculate X and Y diff..
		local ydiff, xdiff
		local side1, side2
		
		if inrange(radians, -math.pi/2, math.pi/2, true) then --up
			ydiff = (y-(currentblock[2]-1)) / math.cos(radians)
			y = currentblock[2]-1
			side1 = "down"
		else
			ydiff = (y-(currentblock[2])) / math.cos(radians)
			y = currentblock[2]
			side1 = "up"
		end
		
		if inrange(radians, 0, math.pi, true) then --left
			xdiff = (x-(currentblock[1])) / math.sin(radians)
			x = currentblock[1]
			side2 = "right"
		else
			xdiff = (x-(currentblock[1]+1)) / math.sin(radians)
			x = currentblock[1]+1
			side2 = "left"
		end
		
		--smaller diff wins
		
		if xdiff < ydiff then
			y = oldy - math.cos(radians)*xdiff
			side = side2
		else
			x = oldx - math.sin(radians)*ydiff
			side = side1
		end
		
		if side == "down" then
			currentblock[2] = currentblock[2]-1
		elseif side == "up" then
			currentblock[2] = currentblock[2]+1
		elseif side == "left" then
			currentblock[1] = currentblock[1]+1
		elseif side == "right" then
			currentblock[1] = currentblock[1]-1
		end
		
		local collide, tileno = world:getTile(currentblock[1]+1, currentblock[2])
		local emancecollide = false
		for i, v in pairs(world.objects.emancipationgrill) do
			if v:getTileInvolved(currentblock[1]+1, currentblock[2]) then
				emancecollide = true
			end
		end
		
		local doorcollide = false
		for i, v in pairs(world.objects.door) do
			if v.dir == "hor" then
				if v.open == false and (v.cox == currentblock[1] or v.cox == currentblock[1]+1) and v.coy == currentblock[2] then
					doorcollide = true
				end
			else
				if v.open == false and v.cox == currentblock[1]+1 and (v.coy == currentblock[2] or v.coy == currentblock[2]+1) then
					doorcollide = true
				end
			end
		end
		
		-- < 0 rechts
		
		--Check for ceilblocker
		if y < 0 then
			if entitylist[world.map[currentblock[1]][1][2]] and entitylist[world.map[currentblock[1]][1][2]].t == "ceilblocker" then
				return false, false, false, false, x, y
			end
		end
		
		--@DEPRECIATED: getproperty doesn't work like dis no mo
		if collide == true and tilequads[world.map[currentblock[1]+1][currentblock[2]][1]]:getproperty("grate", currentblock[1]+1, currentblock[2]) == false then
			break
		elseif emancecollide or doorcollide then
			return false, false, false, false, x, y
		elseif (radians <= 0 and x > xscroll + width) or (radians >= 0 and x < xscroll) then
			return false, false, false, false, x, y
		end
	end
	
	if currentblock[1]+1 > 0 and currentblock[1]+1 <= world.map.width and (currentblock[2] > 0 or currentblock[2] >= math.floor(sourcey+0.5))  and currentblock[2] < world.map.height+1 and currentblock[1] ~= nil then
		local tendency
	
		--get tendency
		if side == "down" or side == "up" then
			if math.mod(x, 1) > 0.5 then
				tendency = 1
			else
				tendency = -1
			end
		elseif side == "left" or side == "right" then
			if math.mod(y, 1) > 0.5 then
				tendency = 1
			else
				tendency = -1
			end
		end
		
		return currentblock[1]+1, currentblock[2], side, tendency, x, y
	else
		return false, false, false, false, x, y
	end
end

function portalgun:getportalposition(i, x, y, side, tendency)
	--returns the "optimal" position according to the parsed arguments (or false if no possible position was found)
	
	--@DEV: This whole funciton smells of copypaste so we can probably heavily factor this down
	local world = self.parent.world
	local xplus, yplus = 0, 0
	if side == "up" then
		yplus = -1
	elseif side == "right" then
		xplus = 1
	elseif side == "down" then
		yplus = 1
	elseif side == "left" then
		xplus = -1
	end
	
	if side == "up" or side == "down" then
		if tendency == -1 then
			if world:getTile(x-1, y, true, true, side) == true and world:getTile(x, y, true, true, side) == true and world:getTile(x-1, y+yplus, nil, false, side, true) == false and world:getTile(x, y+yplus, nil, false, side, true) == false then
				if side == "up" then
					return x-1, y
				else
					return x, y
				end
			elseif world:getTile(x, y, true, true, side) == true and world:getTile(x+1, y, true, true, side) == true and world:getTile(x, y+yplus, nil, false, side, true) == false and world:getTile(x+1, y+yplus, nil, false, side, true) == false then
				if side == "up" then
					return x, y
				else
					return x+1, y
				end
			end
		else
			if world:getTile(x, y, true, true, side) == true and world:getTile(x+1, y, true, true, side) == true and world:getTile(x, y+yplus, nil, false, side, true) == false and world:getTile(x+1, y+yplus, nil, false, side, true) == false then
				if side == "up" then
					return x, y
				else
					return x+1, y
				end
			elseif world:getTile(x-1, y, true, true, side) == true and world:getTile(x, y, true, true, side) == true and world:getTile(x-1, y+yplus, nil, false, side, true) == false and world:getTile(x, y+yplus, nil, false, side, true) == false then
				if side == "up" then
					return x-1, y
				else
					return x, y
				end
			end
		end
	else
		if tendency == -1 then
			if world:getTile(x, y-1, true, true, side) == true and world:getTile(x, y, true, true, side) == true and world:getTile(x+xplus, y-1, nil, false, side, true) == false and world:getTile(x+xplus, y, nil, false, side, true) == false then
				if side == "right" then
					return x, y-1
				else
					return x, y
				end
			elseif world:getTile(x, y, true, true, side) == true and world:getTile(x, y+1, true, true, side) == true and world:getTile(x+xplus, y, nil, false, side, true) == false and world:getTile(x+xplus, y+1, nil, false, side, true) == false then
				if side == "right" then
					return x, y
				else
					return x, y+1
				end
			end
		else
			if world:getTile(x, y, true, true, side) == true and world:getTile(x, y+1, true, true, side) == true and world:getTile(x+xplus, y, nil, false, side, true) == false and world:getTile(x+xplus, y+1, nil, false, side, true) == false then
				if side == "right" then
					return x, y
				else
					return x, y+1
				end
			elseif world:getTile(x, y-1, true, true, side) == true and world:getTile(x, y, true, true, side) == true and world:getTile(x+xplus, y-1, nil, false, side, true) == false and world:getTile(x+xplus, y, nil, false, side, true) == false then
				if side == "right" then
					return x, y-1
				else
					return x, y
				end
			end
		end
	end
	
	return false
end