tiletree = class('tiletree')

function tiletree:init(maps)
	self.active = false
	self.area = {12, 33, 399, 212}
	--original area {4, 37, 375, 167}
	--original scissor {5*scale, 38*scale, 373*scale, 165*scale}
	
	self.bgimg = transparencyimg
	self.bgimgdims = {16,16}
	self.bgquad = love.graphics.newQuad(0, 0, (self.area[3]-self.area[1])*scale, (self.area[4]-self.area[2])*scale, self.bgimgdims[1], self.bgimgdims[2])
	
	self.elements = {}
	self.viewtype = 1
	
	self.contentheight = 0
	self.contentwidth = 0
	
	self.offy = 0
	
	self.buildfrom = {"all", "smb", "portal", "custom", "animated", "entities", "enemies"}
	
	-- original
	--[[guielements["tilesall"] = guielement:new("button", 4, 20, "all", tilesall, 2) --72
	guielements["tilessmb"] = guielement:new("button", 37, 20, "smb", tilessmb, 2)
	guielements["tilesportal"] = guielement:new("button", 70, 20, "portal", tilesportal, 2)
	guielements["tilescustom"] = guielement:new("button", 127, 20, "custom", tilescustom, 2)
	guielements["tilesanimated"] = guielement:new("button", 184, 20, "animated", tilesanimated, 2)
	guielements["tilesentities"] = guielement:new("button", 257, 20, "entities", tilesentities, 2)
	guielements["tilesenemies"] = guielement:new("button", 330, 20, "enemies", tilesenemies, 2)
	
	guielements["tilesscrollbar"] = guielement:new("scrollbar", 381, 37, 167, 15, 40, 0, "ver", nil, nil, nil, nil, true)]]
	
	self.elements["scrollbarver"] = guielement:new("scrollbar", self.area[1]-10, self.area[2], self.area[4]-self.area[2], 10, 40, 0, "ver", nil, nil, nil, nil, true)
	self.elements["scrollbarhor"] = guielement:new("scrollbar", self.area[1], self.area[4], self.area[3]-self.area[1], 40, 10, 0, "hor", nil, nil, nil, nil, false)
	
	local args = {}
	for i, v in ipairs(self.buildfrom) do
		table.insert(args, v)
	end
	self.elements["selectdrop"] = guielement:new("dropdown", 15, 20, 15, function(i) self:selectview(i) end, 1, unpack(args))
	self.elements["statustext"] = guielement:new("text", 150, 22, "")
	self.elements["newbutton"] = guielement:new("button", 3, 20, "+", self.newmap, nil, {self})
	--self.elements["savebutton"] = guielement:new("button", 150, 19, "save", self.save, 1, {self})
	
	--self.elements["addtriggerbutton"] = guielement:new("button", 0, 0, "+", self.addtrigger, nil, {self}, nil, 8)
	--self.elements["addtriggerbutton"].textcolor = {0, 200, 0}
	
	--self.elements["addconditionbutton"] = guielement:new("button", 0, 0, "+", self.addcondition, nil, {self}, nil, 8)
	--self.elements["addconditionbutton"].textcolor = {0, 200, 0}
	
	--self.elements["addactionbutton"] = guielement:new("button", 0, 0, "+", self.addaction, nil, {self}, nil, 8)
	--self.elements["addactionbutton"].textcolor = {0, 200, 0}
	
	self:generate()
end

function tiletree:activate()
	self.active = true
	for k,v in pairs(self.elements) do
		v.active = true
	end
	
	self:generate()
end

function tiletree:deactivate()
	self.active = false
	for k,v in pairs(self.elements) do
		v.active = false
	end
end

function tiletree:selectview(i)
	--print("selectview", i, self.buildfrom[i])
	self.elements["selectdrop"].var = i
	self.viewtype = i
	if i==1 then --all
		self.tileliststart = 1
		self.tilelistcount = smbtilecount + portaltilecount + customtilecount -1
		self.contentheight = math.max(0, math.ceil((self.tilelistcount+1)/22)*17 - 1 - (17*9) - 12)
		editentities = false
		editenemies = false
	elseif i==2 then --smb
		animatedtilelist = false
		self.tileliststart = 1
		self.tilelistcount = smbtilecount-1
		self.contentheight = math.max(0, math.ceil((self.tilelistcount+1)/22)*17 - 1 - (17*9) - 12)
		editentities = false
		editenemies = false
	elseif i==3 then --portal
		animatedtilelist = false
		self.tileliststart = smbtilecount + 1
		self.tilelistcount = portaltilecount - 1
		
		self.contentheight = math.max(0, math.ceil((self.tilelistcount+1)/22)*17 - 1 - (17*9) - 12)
		editentities = false
		editenemies = false
	elseif i==4 then --custom
		animatedtilelist = false
		self.tileliststart = smbtilecount + portaltilecount + 1
		self.tilelistcount = customtilecount - 1
		
		self.contentheight = math.max(0, math.ceil((self.tilelistcount+1)/22)*17 - 1 - (17*9) - 12)
		editentities = false
		editenemies = false
	elseif i==5 then --animated
		animatedtilelist = true
		self.tileliststart = 1
		self.tilelistcount = animatedtilecount - 1
		
		self.contentheight = math.max(0, math.ceil((self.tilelistcount+1)/22)*17 - 1 - (17*9) - 12)
		editentities = false
		editenemies = false
	elseif i==6 then --entities
		animatedtilelist = false
		editentities = true
		editenemies = false
		
		currenttile = 1
		
		self:generateentitylist()
	elseif i==7 then --enemies
		animatedtilelist = false
		self.contentheight = math.max(0, math.ceil((#enemiesdata)/22)*17 - 1 - (17*9) - 12)
		editentities = true
		editenemies = true
		
		currenttile = enemies[1]
	end
end

function tiletree:generateentitylist()
	entitylistitems = {}
	for i, v in ipairs(entitylist) do
		if v.t ~= "" and not v.hidden then
			local cat = v.category or "misc"
			
			local cati = 0
			for j = 1, #entitylistitems do
				if entitylistitems[j].t == cat then
					cati = j
					break
				end
			end
			
			if cati == 0 then
				table.insert(entitylistitems, {t=cat, entries={}})
				cati = #entitylistitems
			end
			
			table.insert(entitylistitems[cati].entries, entitylistitem:new(v.t, i))
		end
	end
	
	--sort categories
	table.sort(entitylistitems, function(a, b) return a.t > b.t end)
	
	--calculate X and Y positions..
	local yadd = -3
	for i, v in ipairs(entitylistitems) do
		table.sort(v.entries, function(a, b) return a.t < b.t end)
		
		--Category name space
		yadd = yadd + 14
		
		for j, k in ipairs(v.entries) do
			local x, y = math.mod(j-1, 22)+1, math.ceil(j/22)
			k.x = (x-1)*17
			k.y = (y-1)*17+yadd
		end
		
		yadd = yadd + math.ceil(#v.entries/22)*17
	end
	
	yadd = yadd + 2
	
	self.contentheight = math.max(0, yadd - 1 - (17*9) - 12)
end

function tiletree:generate()
	self:selectview(self.viewtype)
end

function tiletree:updatedropdown() --unused
	local args = {}
	--table.insert(args, self)
	for i, v in ipairs(self.buildfrom) do
		table.insert(args, v)
	end
	
	self.elements["selectdrop"] = guielement:new("dropdown", 15, 20, 15, function(i) self:selectview(i) end, self.viewtype, unpack(args))
end

function tiletree:draw()
	--TILES
	if self.active then
		local id=self.buildfrom[self.viewtype]
		love.graphics.setColor(255, 255, 255)
		
		-- draw an obnoxious checkerboard to illustrate transparency
		love.graphics.draw(self.bgimg, self.bgquad, self.area[1]*scale, self.area[2]*scale, 0)
		
		love.graphics.setScissor(self.area[1]*scale, self.area[2]*scale, (self.area[3]-self.area[1])*scale, (self.area[4]-self.area[2])*scale)
		--love.graphics.setScissor(5*scale, 38*scale, 373*scale, 165*scale)
		
		local offy = self.offy
		--local offx = -math.max(0, self.elements["scrollbarhor"].value/1*(completewidth-(self.area[3]-self.area[1])))
		
		love.graphics.setColor(255, 255, 255)
		--local y = self.area[2]+1-offy
		--y = y + 2
		
		--v.x = self.area[1]+self.lineinset+offx
		--v.y = v.starty - offy
		
		-- draw each individual tile
		if id=="enemies" then
			for i = 1, #enemies do
				local v = enemiesdata[enemies[i]]
				local compx = math.mod((i-1), 22)*17*scale+self.area[1]*scale
				local compy = math.floor((i-1)/22)*17*scale+self.area[2]*scale
				  
				love.graphics.setScissor(compx, compy, 16*scale, 16*scale)
				love.graphics.draw(v.graphic, v.quad, compx, compy-offy, 0, scale, scale)
				love.graphics.setScissor()
			end
		elseif id=="entities" then
			for i, v in ipairs(entitylistitems) do
				local compx = (self.area[1])*scale
				local compy = (v.entries[1].y+self.area[2])*scale
				properprint(v.t, compx, compy-offy-(8*scale))
				for j, k in ipairs(v.entries) do
					local ecompx = (k.x+self.area[1])*scale
					local ecompy = (k.y+self.area[2])*scale
					love.graphics.draw(entityquads[k.i].image, entityquads[k.i].quad, ecompx, ecompy-offy, 0, scale, scale)
					k:calibrate(self.area[1], self.area[2], self.offy)
					if k:gethighlight(mouse.getX(), mouse.getY()) then
						love.graphics.setColor(255, 255, 255, 127)
						love.graphics.rectangle("fill", ecompx, ecompy-offy, 16*scale, 16*scale)
						love.graphics.setColor(255, 255, 255, 255)
					end
				end
			end
		elseif id=="animated" then
			for i = 1, self.tilelistcount+1 do
				local compx = math.mod((i-1), 22)*17*scale+self.area[1]*scale
				local compy = math.floor((i-1)/22)*17*scale+self.area[2]*scale
				
				love.graphics.draw(tilequads[i+self.tileliststart-1+10000].image, tilequads[i+self.tileliststart-1+10000]:quad(), compx, compy-offy, 0, scale, scale)
			end
		else
			-- standard tile sets
			for i = 1, self.tilelistcount+1 do
				local compx = math.mod((i-1), 22)*17*scale+self.area[1]*scale
				local compy = math.floor((i-1)/22)*17*scale+self.area[2]*scale
				
				love.graphics.draw(tilequads[i+self.tileliststart-1].image, tilequads[i+self.tileliststart-1]:quad(), compx, compy-offy, 0, scale, scale)
			end
		end
		
		-- draw selection
		local tile = self:gettilelistpos(mouse.getX(), mouse.getY())
		if id~="entities" then
			if tile and tile <= self.tilelistcount+1 then
				local compx = (self.area[1]+math.mod((tile-1), 22)*17)*scale
				local compy = (self.area[2]+math.floor((tile-1)/22)*17)*scale

				love.graphics.setColor(255, 255, 255, 127)
				love.graphics.rectangle("fill", compx, compy-offy, 16*scale, 16*scale)
			end
		elseif id=="enemies" then
			if tile and tile <= #enemies then
				local compx = (self.area[1]+math.mod((tile-1), 22)*17)*scale
				local compy = (self.area[2]+math.floor((tile-1)/22)*17)*scale
				
				love.graphics.setColor(255, 255, 255, 127)
				love.graphics.rectangle("fill", compx, compy, 16*scale, 16*scale)
			end
		end
		
		-- hover context string
		if true then
			love.graphics.setScissor()
			love.graphics.setColor(255, 255, 255)
			if id=="enemies" and enemies[tile] then --X
				--properprint(enemies[tile], 3*scale, 205*scale)
				self.elements["statustext"].value = enemies[tile]
			elseif id=="entities" then
				local ent = self:getentityhighlight(mouse.getX(), mouse.getY())
				if ent then
					self.elements["statustext"].value = entitylist[ent.i].description or ""
					--local newstring = entitylist[ent.i].description or ""
					--if string.len(newstring) > 49 then
						--newstring = string.sub(newstring, 1, 49) .. "|" .. string.sub(newstring, 50, 98)
					--end
					--properprint(newstring, 3*scale, 205*scale)
				end
			elseif id=="animated" and tile and animatedtiles[tile] then
				--properprint("frames: " .. #animatedtiles[tile].delays, 3*scale, 205*scale)
				local t = 0
				for i = 1, #animatedtiles[tile].delays do
					t = t + animatedtiles[tile].delays[i]
				end
				self.elements["statustext"].value = "frames: "..#animatedtiles[tile].delays..", time: "..t
				--properprint("total time: " .. t, 3*scale, 215*scale)
			elseif tile and tilequads[tile+self.tileliststart-1] then
				local bstring=""
				if tilequads[tile+self.tileliststart-1]:getproperty("collision") then
					--properprint("collision: true", 3*scale, 205*scale)
					bstring=bstring.."solid, "
				--else
					--properprint("collision: false", 3*scale, 205*scale)
				end
				
				if tilequads[tile+self.tileliststart-1]:getproperty("collision") and tilequads[tile+self.tileliststart-1]:getproperty("portalable") then
					bstring=bstring.."portal, "
					--properprint("portalable: true", 3*scale, 215*scale)
				--else
					--properprint("portalable: false", 3*scale, 215*scale)
				end
				self.elements["statustext"].value =bstring
			--else
				--print("WARNING: Tried to draw tile index beyond what is known.")
			end
		end
		
		-- draw the rest of the elements
		love.graphics.setScissor()
		for k, v in pairs(self.elements) do
			v:draw()
		end
		
		--tooltip tooltip uber alles
		if entitylistitems then
			for i, v in ipairs(entitylistitems) do
				for j, k in ipairs(v.entries) do
					--k:calibrate(self.area[1], self.area[2], self.offy)
					--should still be calibrated
					if k:gethighlight(mouse.getX(), mouse.getY()) then
						--love.graphics.setScissor()
						if entitytooltipobject then
							entitytooltipobject:draw(math.max(0, tooltipa))
						end
						--love.graphics.setScissor(self.area[1]*scale, self.area[2]*scale, (self.area[3]-self.area[1])*scale, (self.area[4]-self.area[2])*scale)
					end
				end
			end
		end
	end
end

function tiletree:update(dt)
	--self.tilesoffset = self.elements["scrollbarver"].value * self.contentheight * scale
	self.offy = self.elements["scrollbarver"].value * self.contentheight * scale
	--(math.max(0, self.elements["scrollbarver"].value/1*(self.contentheight-(self.area[4]-self.area[2])))*scale)
	
	local id=self.buildfrom[self.viewtype]
	for i, v in pairs(self.elements) do
		v:update(dt)
	end
	
	if id=="entities" then
		local x, y = mouse.getPosition()
		local tile = self:getentityhighlight(x, y)
		
		if tile ~= prevtile then
			if tile and tooltipimages[tile.i] then
				entitytooltipobject = entitytooltip:new(tile)
			end
		end
		
		if tile and tooltipimages[tile.i] then
			entitytooltipobject:update(dt)
			tooltipa = math.min(255, tooltipa + dt*4000)
		else
			tooltipa = math.max(-1000, tooltipa - dt*4000)
		end
		
		prevtile = tile
	end
end

function tiletree:keypressed(key)
	for i, v in pairs(self.elements) do
		if v:keypress(string.lower(key)) then
			--return
			-- do we /really/ wanna do this?
		end
	end
	
	--[[for k,v in pairs(self.lines) do
		for k2,v2 in pairs(v) do
			v2:keypressed(key)
		end
	end]]
end

function tiletree:gettilelistpos(x, y)
	--new area      {12, 33, 399, 212}
	--original area {4, 37, 375, 167}
	
	--new scissor      {12*scale, 33*scale, 387*scale, 179*scale)
	--original scissor {5*scale, 38*scale, 373*scale, 165*scale}
	
	if x >= self.area[1]*scale and y >= self.area[2]*scale and x < (self.area[3])*scale and y < (self.area[4])*scale then
		x = (x - self.area[1]*scale)/scale
		y = y + self.offy
		y = (y - self.area[2]*scale)/scale
		
		out = math.floor(x/17)+1
		out = out + math.floor(y/17)*22 --@MAGIC: where does 22 come from? I don't know
		
		return out
	end
	
	return false
end

function tiletree:getentityhighlight(x, y)
	if entitylistitems then
		for i, v in ipairs(entitylistitems) do
			for j, k in ipairs(v.entries) do
				k:calibrate(self.area[1], self.area[2], self.offy)
				if k:gethighlight(x, y) then
					return k
				end
			end
		end
	else
		print("WARNING: Editor called tiletree.lua:getentityhighlight() but 'entitylistitems' was not defined.")
	end
end

function tiletree:control_update(dt)
	local x, y = getMousePos()
	local id=self.buildfrom[self.viewtype]
	
	if controls.tap.editorSelect and not testlevel and editormenuopen and editorstate == "tiles" then
		if id=="enemies" then
			local tile = self:gettilelistpos(x, y, offy)
			if tile and tile <= #enemies then
				currenttile = enemies[tile]
				editorclose()
				allowdrag = false
			end
		elseif id=="entities" then
			tile = self:getentityhighlight(x, y)
			if tile then
				currenttile = tile.i
				editorclose()
				allowdrag = false
			end
		else
			local tile = self:gettilelistpos(x, y)
			-- all tiles
			if tile and tile <= self.tilelistcount+1 then
				if id=="animated" then
					currenttile = tile + self.tileliststart-1+10000
				else
					currenttile = tile + self.tileliststart-1
				end
				
				changeTool("paintdraw", currenttile)
				activeeditortool.allowdrag = false
				
				editorclose()
				allowdrag = false
			end
		end
	end
end

function tiletree:mousepressed(x, y, button)
	for i, v in pairs(self.elements) do
		if v.priority then
			if v:click(x, y, button) then
				return
			end
		end
	end
	
	for i, v in pairs(self.elements) do
		if not v.priority then
			if v:click(x, y, button) then
				return
			end
		end
	end
	
	
	-- original
	--[[if mapbuttons then
		for i, v in pairs(mapbuttons) do
			v:click(x, y, button)
		end
	end]]
	
	-- ex
	--[[if self.lines and self.active and not self.elements["selectdrop"].extended then
		local b = false
		for i, v in pairs(self.lines) do
			for k, w in pairs(v) do
				if w:haspriority() then
					w:click(x, y, button)
					return
				end
			end
		end
		
		if x >= self.area[1]*scale and y >= self.area[2]*scale and x < self.area[3]*scale and y < self.area[4]*scale then
			self.elements["addtriggerbutton"]:click(x, y, button)
			self.elements["addconditionbutton"]:click(x, y, button)
			self.elements["addactionbutton"]:click(x, y, button)
			
			for i, v in pairs(self.lines) do
				for k, w in pairs(v) do						
					if w:click(x, y, button) then
						return
					end
				end
			end
		end
	end]]
end

function tiletree:mousereleased(x, y, button)
	for i, v in pairs(self.elements) do
		if v.priority then
			if v:unclick(x, y, button) then
				return
			end
		end
	end
	
	for i, v in pairs(self.elements) do
		if not v.priority then
			if v:unclick(x, y, button) then
				return
			end
		end
	end
	
	--[[if self.lines and self.active then
		for i, v in pairs(self.lines) do
			for k, w in pairs(v) do					
				w:unclick(x, y, button)
			end
		end
	end]]
end