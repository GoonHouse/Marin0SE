local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, editortool)
local thisclass = _G[classname]

function thisclass:init()
	editortool.init(self, classname)
	self.dragdraw = false
	self.linking = false
	
	self.startx = 0
	self.starty = 0
	self.startt = {}
end

function thisclass:cancel()
	editortool.cancel(self)
	
	self.startx=0
	self.starty=0
	self.startt=false
	self.linking=false
end

function thisclass:change(...)
	local arg={...}
	print("inside linker changer:")
	table.print(arg)
	self.startx = arg[1] or 0
	self.starty = arg[2] or 0
	self.startt = arg[3] or false
	self.linking = arg[4] or false
end

function thisclass:update(dt)
	-- we can always show our status, probably
	local x, y = getMousePos()
	local tilex,tiley = getMouseTile(x, y+8*scale)
	self.status="("..tilex..","..tiley..")"
	
	if self:canFire() and not self.linking then
		print("beginlink")
		--changeTool("linker")
		--editorignoretap = true
		--[[rightclickactive = true
		rightclickoldX = x
		rightclickoldY = y
		linktoolt = t
		rightclicka = 1
		closerightclickmenu()
		self.linking = true]]
	elseif self:canFire() and self.linking then 
		print("endlink")
		local startx, starty = self.startx, self.starty
		print("start", startx, starty)
		-- I don't know why it has to be like this, but it does.
		local endx, endy = getMouseTile(x, y+8*scale)
		print("end", endx, endy)
		
		local edittable = {{x=startx, y=starty}}
		
		--@NOTE: I don't actually think this belongs here.
		--if selectionwidth then
		--	local selectionlist = selectiongettiles(selectionx, selectiony, selectionwidth, selectionheight)
			
		--	for i = 1, #selectionlist do
		--		local v = selectionlist[i]
				-- @WARNING: This code is probably broken because I removed the groundlighttable and made it an "r" value.
		--		if (map[v.x][v.y][2] == map[startx][starty][2] or (entitylist[map[v.x][v.y][2]] and table.contains("groundlight", entitylist[map[v.x][v.y][2]].t) and table.contains("groundlight", entitylist[map[startx][starty][2]].t))) and (v.x ~= startx or v.y ~= starty) then
		--			table.insert(edittable, {x=v.x, y=v.y})
		--		end
		--	end
		--end
		
		
		for i = 1, #edittable do
			local x, y = edittable[i].x, edittable[i].y
			if x ~= endx or y ~= endy then
				print("actually doing something")
				local r = map[endx][endy]
				print("here's what r has for us:")
				table.print(r)
				print("conditions check:", #r > 1, table.contains(outputsi, r[2]))
				
				--LIST OF NUMBERS THAT ARE ACCEPTED AS INPUTS (buttons, laserdetectors)
				if #r > 1 and table.contains( outputsi, r[2] ) then
					print("where did this r come from")
					--@NOTE: If we want to change the format of linkable entities, we do it here!
					r = map[x][y]
					
					local i = 1
					while (r[i] ~= "link" or r[i+1] ~= self.startt) and i <= #r do
						i = i + 1
					end
					
					map[x][y][i] = "link"
					map[x][y][i+1] = self.startt
					map[x][y][i+2] = endx
					map[x][y][i+3] = endy
					linktoolfadeouttime = linktoolfadeouttimeslow
				else
					print("didn't do the important thing, sorry")
				end
			end
		end
		self:cancel()
		
		previousTool()
	end
end

function thisclass:draw()
	editortool.draw(self)
	
	if self.linking then
		local tx, ty
		local x1, y1
		local x2, y2
		
		if rightclickm then
			print("did first")
			tx = rightclickm.tx
			ty = rightclickm.ty
			x1, y1 = math.floor((tx-xscroll-.5)*16*scale), math.floor((ty-yscroll-1)*16*scale)
		-- i have no idea what this does, but it WILL break things
		else
			tx = self.startx
			ty = self.starty
			x1, y1 = math.floor((tx-xscroll-.5)*16*scale), math.floor((ty-yscroll-1)*16*scale)
		end
		
		-- draw all the existing links
		local drawtable = {}
		
		for i = 1, #map[tx][ty] do
			if map[tx][ty][i] == "link" then
				x2, y2 = math.floor((map[tx][ty][i+2]-xscroll-.5)*16*scale), math.floor((map[tx][ty][i+3]-yscroll-1)*16*scale)
				
				local t = map[tx][ty][i+1]
				table.insert(drawtable, {x1, y1, x2, y2, t})
			end
		end
		
		table.sort(drawtable, function(a,b) return math.abs(a[3]-a[1])>math.abs(b[3]-b[1]) end)
		
		for i = 1, #drawtable do
			local x1, y1, x2, y2, t = unpack(drawtable[i])
			love.graphics.setColor(127, 127, 255*(i/#drawtable), 255*rightclicka)
			
			if math.mod(i, 2) == 0 then
				drawlinkline2(x1, y1, x2, y2)
			else
				drawlinkline(x1, y1, x2, y2)
			end
			
			properprintbackground(t, math.floor(x2-string.len(t)*4*scale), y2+10*scale, true, {0, 0, 0, 255*rightclicka})
		end
		
		-- draw the current line that we're dragging around
		if self.startt then
			local x1, y1 = math.floor((self.startx-xscroll-.5)*16*scale), math.floor((self.starty-yscroll-1)*16*scale)
			local x2, y2 = getMousePos()
			
			love.graphics.setColor(255, 172, 47, 255)
			
			drawlinkline(x1, y1, x2, y2)
			
			love.graphics.setColor(200, 140, 30, 255)
			
			love.graphics.draw(linktoolpointerimg, x2-math.ceil(scale/2), y2, 0, scale, scale, 3, 3)
			
			properprintbackground(self.startt, math.floor(x2+4*scale), y2-4*scale, true)
		end
	end
end