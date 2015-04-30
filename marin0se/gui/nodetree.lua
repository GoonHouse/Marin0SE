nodetree = class('nodetree')

function nodetree:init(anims, anims2)
	self.active = true
	self.lines = {}
	self.area = {12, 33, 399, 212}
	self.lineinset = 14
	self.itemlist = anims2
	self.elements = {}
	self.viewtype = 1
	self.buildfrom = anims
	
	self.elements["scrollbarver"] = guielement:new("scrollbar", self.area[1]-10, self.area[2], self.area[4]-self.area[2], 10, 40, 0, "ver", nil, nil, nil, nil, true)
	self.elements["scrollbarhor"] = guielement:new("scrollbar", self.area[1], self.area[4], self.area[3]-self.area[1], 40, 10, 0, "hor", nil, nil, nil, nil, false)
	
	local args = {}
	--table.insert(args, self)
	for i, v in ipairs(self.buildfrom) do
		table.insert(args, string.sub(v.name, 1, -6))
	end
	self.elements["selectdrop"] = guielement:new("dropdown", 15, 20, 15, function(i) self:selectview(i) end, 1, unpack(args))
	self.elements["newbutton"] = guielement:new("button", 3, 20, "+", self.newanimation, nil, {self})
	self.elements["savebutton"] = guielement:new("button", 150, 19, "save", self.save, 1, {self})
	
	self.elements["addtriggerbutton"] = guielement:new("button", 0, 0, "+", self.addtrigger, nil, {self}, nil, 8)
	self.elements["addtriggerbutton"].textcolor = {0, 200, 0}
	
	self.elements["addconditionbutton"] = guielement:new("button", 0, 0, "+", self.addcondition, nil, {self}, nil, 8)
	self.elements["addconditionbutton"].textcolor = {0, 200, 0}
	
	self.elements["addactionbutton"] = guielement:new("button", 0, 0, "+", self.addaction, nil, {self}, nil, 8)
	self.elements["addactionbutton"].textcolor = {0, 200, 0}
	
	self:generate()
end

function nodetree:activate()
	self.active = true
	for k,v in pairs(self.elements) do
		v.active = true
	end
	
	self:generate()
end

function nodetree:deactivate()
	self.active = false
	for k,v in pairs(self.elements) do
		v.active = false
	end
end

function nodetree:generate()
	-- viewtype unused
	if not self.buildfrom[self.viewtype] then
		self:newanimation()
	end
	--print("absurd")
	--table.print(self.buildfrom[self.viewtype])
	local holder = self.buildfrom[self.viewtype]

	self.lines = {}
	self.lines.triggers = {}
	for i, v in pairs(holder.triggers) do
		table.insert(self.lines.triggers, animationguiline:new(v, "trigger", self))
	end
	self.lines.conditions = {}
	for i, v in pairs(holder.conditions) do
		table.insert(self.lines.conditions, animationguiline:new(v, "condition", self))
	end
	self.lines.actions = {}
	for i, v in pairs(holder.actions) do
		table.insert(self.lines.actions, animationguiline:new(v, "action", self))
	end
end

function nodetree:newanimation()
	local s = {}
	s.triggers = {}
	s.conditions = {}
	s.actions = {}
	
	local i = 1
	while love.filesystem.exists("mappacks/" .. mappack .. "/animations/animation" .. i .. ".json") do
		i = i + 1
	end
	love.filesystem.createDirectory("mappacks/" .. mappack .. "/animations/")
	love.filesystem.write("mappacks/" .. mappack .. "/animations/animation" .. i .. ".json", JSON:encode_pretty(s))
	
	table.insert(self.buildfrom, animation:new("mappacks/" .. mappack .. "/animations/animation" .. i .. ".json", "animation" .. i .. ".json"))
	self.viewtype = #self.buildfrom
	
	self:updatedropdown()
end

function nodetree:updatedropdown()
	local args = {}
	--table.insert(args, self)
	for i, v in ipairs(self.buildfrom) do
		table.insert(args, string.sub(v.name, 1, -6))
	end
	
	self.elements["selectdrop"] = guielement:new("dropdown", 15, 20, 15, function(i) self:selectview(i) end, self.viewtype, unpack(args))
end

function nodetree:deleteline(t, tabl)
	for i, v in ipairs(self.lines[t .. "s"]) do
		if v == tabl then
			table.remove(self.lines[t .. "s"], i)
		end
	end
end

function nodetree:movedownline(t, tabl)
	for i, v in ipairs(self.lines[t .. "s"]) do
		if v == tabl then
			if i ~= #self.lines[t .. "s"] then
				self.lines[t .. "s"][i], self.lines[t .. "s"][i+1] = self.lines[t .. "s"][i+1], self.lines[t .. "s"][i]
				break
			end
		end
	end
end

function nodetree:moveupline(t, tabl)
	for i, v in ipairs(self.lines[t .. "s"]) do
		if v == tabl then
			if i ~= 1 then
				self.lines[t .. "s"][i], self.lines[t .. "s"][i-1] = self.lines[t .. "s"][i-1], self.lines[t .. "s"][i]
				break
			end
		end
	end
end

function nodetree:selectview(i)
	--print("selectview", self, i)
	self.elements["selectdrop"].var = i
	self:save()
	self.viewtype = i
	self:generate()
end

function nodetree:save()
	notice.new("animations saved!")
	local out = {}
	
	local typelist = {"triggers", "conditions", "actions"}
	for h, w in ipairs(typelist) do
		out[w] = {}
		for i, v in ipairs(self.lines[w]) do
			out[w][i] = {}
			for j, k in ipairs(v.elements) do
				if k.gui then
					local val = ""
					if k.gui.type == "dropdown" then
						if j == 1 then
							--find normal name
							for l, m in pairs(self.itemlist) do
								if m.nicename == k.gui.entries[k.gui.var] then
									val = l
									break
								end
							end
						else
							val = k.gui.entries[k.gui.var]
						end
					elseif k.gui.type == "input" then
						val = k.gui.value
					end
					table.insert(out[w][i], val)
				end
			end
		end
	end
	
	self.buildfrom[self.viewtype].triggers = out.triggers
	self.buildfrom[self.viewtype].conditions = out.conditions
	self.buildfrom[self.viewtype].actions = out.actions
	
	local json = JSON:encode_pretty(out)
	love.filesystem.write(self.buildfrom[self.viewtype].filepath, json)
end

function nodetree:addtrigger()
	table.insert(self.lines.triggers, animationguiline:new({}, "trigger", self))
end

function nodetree:addcondition()
	table.insert(self.lines.conditions, animationguiline:new({}, "condition", self))
end

function nodetree:addaction()
	table.insert(self.lines.actions, animationguiline:new({}, "action", self))
end

function nodetree:draw()
	if #self.buildfrom > 0 then
		love.graphics.setScissor(self.area[1]*scale, self.area[2]*scale, (self.area[3]-self.area[1])*scale, (self.area[4]-self.area[2])*scale)
		local completeheight = 14+#self.lines.triggers*13+12+#self.lines.conditions*13+12+#self.lines.actions*13
		local offy = math.max(0, self.elements["scrollbarver"].value/1*(completeheight-(self.area[4]-self.area[2])))
		local completewidth = 0
		for i, v in pairs(self.lines) do
			for k, w in pairs(v) do
				local width = 32+self.lineinset
				for j, z in pairs(w.elements) do
					width = width + w.elements[j].width
				end
				if width > completewidth then
					completewidth = width
				end
			end
		end
		
		local offx = -math.max(0, self.elements["scrollbarhor"].value/1*(completewidth-(self.area[3]-self.area[1])))
		
		love.graphics.setColor(255, 255, 255)
		
		local y = self.area[2]+1-offy
		y = y + 2
		
		self.elements["addtriggerbutton"].x = self.area[1]+2+offx
		self.elements["addtriggerbutton"].y = y-2
		self.elements["addtriggerbutton"]:draw()
		
		properprint("triggers:", (self.area[1]+13+offx)*scale, y*scale)
		y = y + 10
		
		for i, v in pairs(self.lines.triggers) do
			v:draw((self.area[1]+self.lineinset+offx), y)
			y = y + 13
		end
		y = y + 2
		
		self.elements["addconditionbutton"].x = self.area[1]+2+offx
		self.elements["addconditionbutton"].y = y-2
		self.elements["addconditionbutton"]:draw()
		
		properprint("conditions:", (self.area[1]+13+offx)*scale, y*scale)
		y = y + 10
		
		for i, v in pairs(self.lines.conditions) do
			v:draw((self.area[1]+self.lineinset+offx), y)
			y = y + 13
		end
		y = y + 2
		
		self.elements["addactionbutton"].x = self.area[1]+2+offx
		self.elements["addactionbutton"].y = y-2
		self.elements["addactionbutton"]:draw()
		
		properprint("actions:", (self.area[1]+13+offx)*scale, y*scale)
		y = y + 10
		
		for i, v in pairs(self.lines.actions) do
			v:draw((self.area[1]+self.lineinset+offx), y)
			y = y + 13
		end
		
		for i, v in pairs(self.lines) do
			for k, w in pairs(v) do
				for anotherletter, fuck in pairs(w.elements) do
					if fuck.gui and not fuck.gui.priority then
						fuck.gui:draw()
					end
				end
			end
		end
		
		love.graphics.setScissor()
		
		love.graphics.setColor(90, 90, 90)
		drawrectangle(self.area[1]-10, self.area[4], 10, 10)
	end
	
	for i, v in pairs(self.elements) do
		v:draw()
	end
	
	-- this is commented out because it was included above I guess
	if self.active then
		for i, v in pairs(self.lines) do
			for k, w in pairs(v) do
				for anotherletter, fuck in pairs(w.elements) do
					if fuck.gui and fuck.gui.priority then
						fuck.gui:draw()
					end
				end
			end
		end
	end
end

function nodetree:update(dt)
	for i, v in pairs(self.lines) do
		for k, w in pairs(v) do
			w:update(dt)
		end
	end
end

function nodetree:keypressed(key)
	for i, v in pairs(self.elements) do
		if v:keypress(string.lower(key)) then
			--return
			-- do we /really/ wanna do this?
		end
	end
	
	for k,v in pairs(self.lines) do
		for k2,v2 in pairs(v) do
			v2:keypressed(key)
		end
	end
end

function nodetree:mousepressed(x, y, button)
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
	
	if self.lines and self.active and not self.elements["selectdrop"].extended then
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
	end
end

function nodetree:mousereleased(x, y, button)
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
	
	if self.lines and self.active then
		for i, v in pairs(self.lines) do
			for k, w in pairs(v) do					
				w:unclick(x, y, button)
			end
		end
	end
end