maptree = class('maptree')

function maptree:init(maps)
	self.active = false
	self.lines = {} --unused
	self.area = {12, 33, 399, 212}
	--{4, 21, 381, 220} old map area
	self.lineinset = 14 --unused
	self.maplist = {}
	self.existingmaps = {} --not sure what it's for
	--self.itemlist = anims2
	self.elements = {}
	self.viewtype = 1
	self.buildfrom = maps --entirely unused
	
	-- original
	--[[guielements["savebutton2"] = guielement:new("button", 10, 140, "save", savelevel, 2)
	guielements["savebutton2"].bordercolor = {255, 0, 0}
	guielements["savebutton2"].bordercolorhigh = {255, 127, 127}--]]
	--guielements["mapscrollbar"] = guielement:new("scrollbar", 381, 21, 199, 15, 40, 0, "ver", nil, nil, nil, nil, true)]]
	
	self.elements["scrollbarver"] = guielement:new("scrollbar", self.area[1]-10, self.area[2], self.area[4]-self.area[2], 10, 40, 0, "ver", nil, nil, nil, nil, true)
	self.elements["scrollbarhor"] = guielement:new("scrollbar", self.area[1], self.area[4], self.area[3]-self.area[1], 40, 10, 0, "hor", nil, nil, nil, nil, false)
	
	--[[local args = {}
	--table.insert(args, self)
	for i, v in ipairs(self.buildfrom) do
		table.insert(args, string.sub(v.name, 1, -6))
	end]]
	--self.elements["selectdrop"] = guielement:new("dropdown", 15, 20, 15, function(i) self:selectview(i) end, 1, unpack(args))
	self.elements["newbutton"] = guielement:new("button", 3, 20, "+", self.newmap, nil, {self})
	self.elements["mapname"] = guielement:new("input", 15, 20, 15, nil, currentmap, 0)
	--self.elements["savebutton"] = guielement:new("button", 150, 19, "save", self.save, 1, {self})
	
	--self.elements["addtriggerbutton"] = guielement:new("button", 0, 0, "+", self.addtrigger, nil, {self}, nil, 8)
	--self.elements["addtriggerbutton"].textcolor = {0, 200, 0}
	
	--self.elements["addconditionbutton"] = guielement:new("button", 0, 0, "+", self.addcondition, nil, {self}, nil, 8)
	--self.elements["addconditionbutton"].textcolor = {0, 200, 0}
	
	--self.elements["addactionbutton"] = guielement:new("button", 0, 0, "+", self.addaction, nil, {self}, nil, 8)
	--self.elements["addactionbutton"].textcolor = {0, 200, 0}
	
	self:generate()
end

function maptree:activate()
	self.active = true
	for k,v in pairs(self.elements) do
		v.active = true
	end
	
	self:generate()
end

function maptree:deactivate()
	self.active = false
	for k,v in pairs(self.elements) do
		v.active = false
	end
end

function maptree:changemap(mapname)
	print("WHOA: I was told to change to ", mapname)
	--print("NOTICE: Map changed because a map icon was clicked.")
	currentmap = mapname
	marioworld = 1
	mariolevel = 1
	mariosublevel = 0
	editorloadopen = false
	self.elements["mapname"].value = mapname
	loadlevel(mapname)
	startlevel()
end

function maptree:generate()
	self.existingmaps = {}
	
	local mapdir = "mappacks/" .. mappack .. "/"
	local maplist = love.filesystem.getDirectoryItems(mapdir)
	self.maplist = {}
	local yadd = 0
	local xadd = 0
	
	for k,v in pairs(maplist) do
		if v:sub(-4) == ".txt" and love.filesystem.isFile(mapdir..v) and v~="settings.txt" then
			local curmapname = v:sub(0, -5)
			self.elements["map_"..curmapname.."_label"] = guielement:new("text", 4, yadd+21, curmapname)
			self.elements["map_"..curmapname.."_label"].starty = yadd+21
			
			yadd = yadd + 10
			
			if love.filesystem.exists(mapdir..curmapname..".png") then
				self.elements["map_"..curmapname.."_button"] = guielement:new("button", 4+xadd, yadd+21, love.graphics.newImage(mapdir..curmapname..".png"), function(cmap) self:changemap(cmap) end, 0, {curmapname})
			else
				self.elements["map_"..curmapname.."_button"] = guielement:new("button", 4+xadd, yadd+21, "no preview", function() self:changemap(curmapname) end, 0)
			end
			self.elements["map_"..curmapname.."_button"].starty = yadd+21
			self.maplist[curmapname] = {
				label=self.elements["map_"..curmapname.."_label"],
				button=self.elements["map_"..curmapname.."_button"]
			}
			yadd = yadd + 20
		end
	end
	self.mapsymissing = math.max(0, yadd-200)
end

function maptree:newmap()
	savemap(currentmap)
	savemap(self.elements["mapname"].value)
	self:changemap(self.elements["mapname"].value)
end

function maptree:draw()
	-- original draw had this commented out
	--[[love.graphics.setColor(255, 255, 255)
	for i = 1, 8 do
		properprint("w" .. i, ((i-1)*49 + 19)*scale, 23*scale)
	end
	properprint("do not forget to save your current map before|changing!", 5*scale, 120*scale)--]]
	
	-- original draw method
	--[[local scroll = guielements["mapscrollbar"].value * mapsymissing
	love.graphics.setScissor(mapbuttonarea[1]*scale, mapbuttonarea[2]*scale, (mapbuttonarea[3]-mapbuttonarea[1])*scale, (mapbuttonarea[4]-mapbuttonarea[2])*scale)
	
	for i, v in pairs(mapbuttons) do
		v.y = v.starty - scroll
		v:draw()
	end
	love.graphics.setScissor()]]
	
	-- nodetree compliant draw
	if self.active then
		love.graphics.setScissor(self.area[1]*scale, self.area[2]*scale, (self.area[3]-self.area[1])*scale, (self.area[4]-self.area[2])*scale)
		local completeheight = self.area[4]-self.area[2] --(self.area[3]-self.area[1])*scale
		local completewidth = 0
		for k,v in pairs(self.elements) do
			if k:sub(0,4) == "map_" then
				completeheight = completeheight+v.height
				if completewidth < 32+v.width then
					completewidth = 32+v.width
				end
			end
		end
		
		--local offy = math.max(0, self.elements["scrollbarver"].value/1*(completeheight-(self.area[4]-self.area[2])))-14
		local offy = self.elements["scrollbarver"].value*completeheight*scale
		
		local offx = math.max(0, self.elements["scrollbarhor"].value/1*(completewidth-(self.area[3]-self.area[1])))
		
		love.graphics.setColor(255, 255, 255)
		local y = self.area[2]+1-offy
		y = y + 2
		
		for k,v in pairs(self.elements) do
			if k:sub(0,4) == "map_" then
				v.x = self.area[1]+self.lineinset+offx
				v.y = self.area[2] + v.starty - (offy/scale) - 16
				--y = y + v.height
				--v.y = v.starty - scroll
				v:draw()
			else
				v:draw()
			end
		end
		
		love.graphics.setScissor()
		
		love.graphics.setColor(90, 90, 90)
		drawrectangle(self.area[1]-10, self.area[4], 10, 10)
		
		for k, v in pairs(self.elements) do
			if k:sub(0,4) ~= "map_" then
				v:draw()
			end
		end
	end
	
	-- this is commented out because it was included above I guess
	--[[if self.active then
		for i, v in pairs(self.lines) do
			for k, w in pairs(v) do
				for anotherletter, fuck in pairs(w.elements) do
					if fuck.gui and fuck.gui.priority then
						fuck.gui:draw()
					end
				end
			end
		end
	end]]
end

function maptree:update(dt)
	for i, v in pairs(self.elements) do
		--for k, w in pairs(v) do
			v:update(dt)
		--end
	end
end

function maptree:keypressed(key)
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

function maptree:mousepressed(x, y, button)
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

function maptree:mousereleased(x, y, button)
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