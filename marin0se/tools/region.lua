local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, editortool)
local thisclass = _G[classname]

function thisclass:init()
	editortool.init(self, classname)
	self.dragdraw = false
	self.editing = false
end

function thisclass:cancel()
	editortool.cancel(self)
	
	self.startx=0
	self.starty=0
	self.startt=false
	self.regioning=false
	self.regiondragging = nil
	rightclickactive = false
end

function thisclass:change(...)
	local arg={...}
	print("inside region changer:")
	table.print(arg)
	self.startx = arg[1] or 0
	self.starty = arg[2] or 0
	self.startt = arg[3] or false
	self.regioning = arg[4] or false
	
	editorignoretap = true
	editorignorerelease = true
	--get width n shit
	local j
	
	for i = 3, #map[self.startx][self.starty] do
		local s = tostring(map[self.startx][self.starty][i]):split(":")
		if s[1] == self.startt then
			j = i
			break
		end
	end
	
	if j then
		local s = map[self.startx][self.starty][j]:split(":")
		
		local rx, ry = s[2], s[3]
		
		if string.sub(rx, 1, 1) == "m" then
			rx = -tonumber(string.sub(rx, 2))
		end
		if string.sub(ry, 1, 1) == "m" then
			ry = -tonumber(string.sub(ry, 2))
		end
		self.regiondragging = regiondrag:new(self.startx+rx, self.starty+ry, s[4], s[5])
	else
		print("Error! Unknown t :(")
	end
end

function thisclass:canFire()
	--print("click", tostring(controls.tap.editorSelect), "active", tostring(self.active), "noignore", tostring(not editorignoretap), "nomenuopen", tostring(not editormenuopen), "notest", tostring(not testlevel))
	return controls.tap.editorSelect and self.active and not editormenuopen and not testlevel
end

function thisclass:canUnfire()
	return controls.release.editorSelect and self.active and not editormenuopen and not testlevel
end

function thisclass:update(dt)
	-- we can always show our status, probably
	local x, y = getMousePos()
	local tilex,tiley = getMouseTile(x, y+8*scale)
	self.status="("..tilex..","..tiley..")|("..x..","..y..")"
	
	if controls.tap.editorSelect then
		print("checks", controls.tap.editorSelect, editorignoretap, self.active, not editormenuopen, not testlevel, self.regiondragging)
	end
	if controls.release.editorSelect then
		print("unchecks", controls.release.editorSelect, editorignoretap, self.active, not editormenuopen, not testlevel, self.regiondragging)
	end
	if self:canFire() and self.regiondragging and self.regiondragging:checkGrab(x, y) then
		print("do first")
		--previousTool()
		local t = self.startt
		local x, y = self.startx, self.starty
		
		local j
		
		for i = 3, #map[x][y] do
			local s = tostring(map[x][y][i]):split(":")
			if s[1] == t then
				j = i
				break
			end
		end
		
		local rx, ry = self.regiondragging.x-x+1, self.regiondragging.y-y+1
		
		if rx < 0 then
			rx = "m" .. -rx
		end
		
		if ry < 0 then
			ry = "m" .. -ry
		end
		
		map[x][y][j] = t .. ":" .. rx .. ":" .. ry .. ":" .. self.regiondragging.width .. ":" .. self.regiondragging.height
		
		--self.regioning = false
		--self.regiondragging = nil
		rightclickactive = false
		
		--[[if self.regiondragging:checkGrab(x, y) then
			print("doodleburg")
		end]]
		
	elseif self:canUnfire() and self.regiondragging then
		print("do other")
		self.regiondragging:releaseGrab()
	elseif self.regiondragging and self.regiondragging:update(dt) and self.regiondragging:checkGrab(x, y) then
		self.regiondragging = nil
	end
end

function thisclass:draw()
	editortool.draw(self)
	
	if self.regiondragging then
		self.regiondragging:draw()
	end
end