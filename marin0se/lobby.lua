function lobby_load(hostnick)
	objects = nil
	if guielements.hideip then
		lobby_showmagicdns = not guielements.hideip.var
	else
		lobby_showmagicdns = false
	end
	loadmappacks(true)
	gamestate = "lobby"
	guielements = {}
	guielements.chatentry = guielement:new("input", 4, 207, 43+7/8, sendchat, "", 0)
	guielements.chatentry.usecoolvetica = true
	guielements.sendbutton = guielement:new("button", 359, 207, "send", sendchat, 1)
	guielements.playerscroll = guielement:new("scrollbar", 389, 3, 104, 8, 50, 0)

	lobby_playerlist = {}

	LOBBY_HOSTNICK = hostnick
	
	if clientisnetworkhost then
		guielements.startbutton = guielement:new("button", 4, 80, "start game", server_start, 1)
	end
	lobby_playerlist[1] = {connected=true, hats=mariohats[playerconfig], colors=mariocolors[playerconfig], nick=hostnick}
	guielements.quitbutton = guielement:new("button", 100, 80, "quit to menu", network_quit, 1)
	
	magicdns_timer = 0
	magicdns_delay = 30
	guielements.livescheckbox = guielement:new("checkbox", 10, 10, toggleinflives, infinitelives)

	lobby_mappackselectionnumber = 1

	for x = 1, #mappacklist do
		if mappacklist[x] == mappack then
			lobby_mappackselectionnumber = x
			break
		end
	end

	lobby_numberofpages = 2
	lobby_currentpage = 1

	lobby_guielementspageactive = {{"livescheckbox", "mappackdecrease", "mappackincrease", "maxplayersincrease", "maxplayersdecrease"},
	{"shareportalscheckbox", "infinitetimecheckbox", "singularmariocheckbox", "classicmodecheckbox"}
	}


	guielements.mappackdecrease = guielement:new("button", 8, 23, "{", mappackdecrease, 0)
	guielements.mappackincrease = guielement:new("button", 78+(string.len(mappackname[lobby_mappackselectionnumber])+1)*8, 23, "}", mappackincrease, 0)

	guielements.maxplayersdecrease = guielement:new("button", 8, 45, "{", maxplayersdecrease, 0)
	guielements.maxplayersincrease = guielement:new("button", 128, 45, "}", maxplayersincrease, 0)



	guielements.showmagicdnsbutton = guielement:new("checkbox", 10, 67, toggleshowmagicdns, lobby_showmagicdns)

	guielements.changepagedecrease = guielement:new("button", 70, 95, "{", lobby_pagedecrease, 0)
	guielements.changepageincrease = guielement:new("button", 150, 95, "}", lobby_pageincrease, 0)

	guielements.shareportalscheckbox = guielement:new("checkbox", 10, 10, togglesharedportals, playersaresharingportals)
	guielements.shareportalscheckbox.active = false

	guielements.infinitetimecheckbox = guielement:new("checkbox", 10, 23, toggleinfinitetime, infinitetime)
	guielements.infinitetimecheckbox.active = false

	singularmariogamemode = false

	guielements.singularmariocheckbox = guielement:new("checkbox", 10, 36, togglesingularmario, singularmariogamemode)
	guielements.singularmariocheckbox.active = false

	classicmodeactive = false

	guielements.classicmodecheckbox = guielement:new("checkbox", 10, 49, toggleclassicmode, classicmodeactive)
	guielements.classicmodecheckbox.active = false



	lobby_currentmappackallowed = true

	lobby_maxplayers = 4

	hovertextdata = {{gui="singularmariocheckbox", hoverwidth= "1 mario, x portals", title="competitive mode", titlecolor={255, 0, 0}, text="see how far you can travel|with others controlling|your portals"},
	{gui="shareportalscheckbox", hoverwidth = "share portals", title="cooperative mode", titlecolor={0, 0, 255}, text="everyone shares 2 portals"}
	}

	pausemenuoptions = {"resume", "return to", "volume", "quit to", "quit to"}
	if clientisnetworkhost then
		pausemenuoptions2 = {"", "lobby", "", "menu", "desktop"}
	else
		pausemenuoptions2 = {"", "onlinemenu", "", "menu", "desktop"}
	end

end

function lobby_update(dt)
	runanimationtimer = runanimationtimer + dt
	while runanimationtimer > runanimationdelay do
		runanimationtimer = runanimationtimer - runanimationdelay
		runanimationframe = runanimationframe - 1
		if runanimationframe == 0 then
			runanimationframe = 3
		end
	end
	
	if clientisnetworkhost then
		magicdns_timer = magicdns_timer + dt
		while magicdns_timer > magicdns_delay do
			magicdns_timer = magicdns_timer - magicdns_delay
			--this needs to be changed so the delay is like 2 seconds until the external port is known
			magicdns_keep()
		end
	end
	for i, v in pairs(hovertextdata) do
		if _G["guielements"][v.gui] then
			local element = _G["guielements"][v.gui]
			if element.active then
				local mousex, mousey = love.mouse.getX(), love.mouse.getY()
				if mousex >= element.x*scale and mousex <= element.x*scale + 9*scale + 8*string.len(v.hoverwidth)*scale and mousey >= element.y*scale and mousey <= element.y*scale + 9*scale then
					v.showing = true
				else
					v.showing = false
				end
			end
		end
	end
end

function lobby_draw()
	--STUFF
	love.graphics.setColor(0, 0, 0, 200)
	love.graphics.rectangle("fill", 3*scale, 3*scale, 233*scale, 104*scale)
	
	love.graphics.setColor(255, 255, 255, 255)
	--[[if usemagic and adjective and noun and lobby_showmagicdns then
		properprintbackground("magicdns: " .. adjective .. " " .. noun, 4*scale, 98*scale, true)
	end--]]
	if clientisnetworkhost then
		guielements.startbutton:draw()
	end
	guielements.quitbutton:draw()
	
	--lobby_playerlist

	
	local missingpixels = math.max(0, (#lobby_playerlist*41-3)-104)
	
	love.graphics.setColor(0, 0, 0, 200)
	love.graphics.rectangle("fill", 239*scale, 3*scale, 150*scale, 104*scale)
	
	love.graphics.translate(0, -missingpixels*guielements.playerscroll.value*scale)
	
	local y = 1
	for i = 1, #lobby_playerlist do
		--if lobby_playerlist[i].connected then
			local ping = nil
			if networkclientnumber and networkclientnumber ~= 0 and lobby_playerlist[i] then
				if convertclienttoplayer(i) > 1 and lobby_playerlist[i].ping then
					ping = lobby_playerlist[i].ping
				end
			end
			local ypos = (y-1)*41*scale+3*scale-missingpixels*guielements.playerscroll.value*scale
			if ypos < 3*scale then
				ypos = 3*scale
			end
			if ypos < 107*scale then
				local height = 38*scale
				if ypos + 38*scale > 107*scale then
					height = math.abs(ypos-107*scale)
				end
				love.graphics.setScissor(239*scale, ypos, 161*scale, height)
				if lobby_playerlist[i] then
					if lobby_playerlist[i].colors and lobby_playerlist[i].hats and lobby_playerlist[i].nick then
						drawplayercard(239, (y-1)*41+3, lobby_playerlist[i].colors or mariocolors[i], lobby_playerlist[i].hats or mariohats[i], lobby_playerlist[i].nick or localnicks[math.random(#localnicks)], ping, focus)
					end
				end
				love.graphics.setScissor()
			end

			y = y + 1
		--end
	end
	
	love.graphics.translate(0, missingpixels*guielements.playerscroll.value*scale)
	guielements.playerscroll:draw()
	love.graphics.setScissor()
	
	--chat
	love.graphics.setColor(0, 0, 0, 200)
	love.graphics.rectangle("fill", 3*scale, 110*scale, 394*scale, 111*scale)
	love.graphics.setColor(255, 255, 255, 255)
	drawrectangle(4, 111, 392, 109)
	
	guielements.chatentry:draw()
	guielements.sendbutton:draw()
	
	--chat messages
	local height = 0
	for i = 1, math.min(#chatlog, 7) do


		local pid = 0
		for j = 1, #lobby_playerlist do
			if lobby_playerlist[j].nick == chatlog[i].id then
				pid = j
				break
			end
		end
		
		if pid ~= 0 then
			local nick = lobby_playerlist[pid].nick .. ":"
			
			local background = {255, 255, 255}
			
			local adds = 0
			for i = 1, 3 do
				adds = adds + lobby_playerlist[pid].colors[1][i]
			end
			
			if adds/3 > 40 then
				background = {0, 0, 0}
			end
			
			love.graphics.setColor(unpack(lobby_playerlist[pid].colors[1]))
			love.graphics.print(string.upper(nick), 8*scale, (190-(height*12))*scale)
			love.graphics.setColor(255, 255, 255)
			love.graphics.setFont(bigchatlogfont)
			love.graphics.print(chatlog[i].message, (8+(string.len(nick))*8)*scale, (190-(height*12))*scale)
			height = height + 1
		end

	end


	if guielements.livescheckbox.active then
		guielements.livescheckbox:draw()
		properprint("infinite lives", 20*scale, 11*scale)
	end

	if guielements.mappackincrease.active then
		guielements.mappackincrease:draw()
		guielements.mappackdecrease:draw()
		if lobby_currentmappackallowed then 
			love.graphics.setColor(0, 255, 0)
			properprint("all peers own this map", 20*scale, 36*scale)
		else
			love.graphics.setColor(255, 0, 0)
			properprint("not all peers own this map", 20*scale, 36*scale)
		end
		properprint("mappack:" .. string.lower(mappackname[lobby_mappackselectionnumber]), 20*scale, 25*scale)
	end



	love.graphics.setColor(255, 255, 255)
	if guielements.maxplayersincrease.active then
		guielements.maxplayersincrease:draw()
		guielements.maxplayersdecrease:draw()

		properprint("max players:" .. lobby_maxplayers, 20*scale, 47*scale)
	end

	if lobby_maxplayers > 4 then
		love.graphics.setColor(255, 0, 0)
		properprint("possibly", 154*scale, 47*scale)
		properprint("unstable", 154*scale, 58*scale)
	end
	love.graphics.setColor(0, 0, 0)
	if usemagic then
		guielements.showmagicdnsbutton:draw()
		properprint("show magicdns: ", 20*scale, 68*scale)
		love.graphics.setColor(0, 0, 255, 255)
		if usemagic and adjective and noun and lobby_showmagicdns then
			properprintbackground(adjective .. " " .. noun, 132*scale, 68*scale, true)
		else
			local constructedstring = ""
			for x = 1, string.len(adjective .. " " .. noun) do
				constructedstring = constructedstring .. "x"
			end
			properprintbackground(constructedstring, 132*scale, 68*scale, true)
		end
	end

	love.graphics.setColor(255, 255, 255, 255)
	properprint("page " .. lobby_currentpage .. "/" .. lobby_numberofpages, 83*scale, 97*scale)

	guielements.changepageincrease:draw()
	guielements.changepagedecrease:draw()

	if guielements.shareportalscheckbox.active then
		guielements.shareportalscheckbox:draw()
		properprint("share portals", 20*scale, 11*scale)
	end

	if guielements.infinitetimecheckbox.active then
		guielements.infinitetimecheckbox:draw()
		properprint("infinite time", 20*scale, 24*scale)
	end


	if guielements.singularmariocheckbox.active then
		guielements.singularmariocheckbox:draw()
		properprint("1 mario, " .. #lobby_playerlist*2 .. " portals", 20*scale, 37*scale)
	end

	if guielements.classicmodecheckbox.active then
		guielements.classicmodecheckbox:draw()
		properprint("classic mode", 20*scale, 50*scale)
	end

	for i, v in pairs(hovertextdata) do
		if _G["guielements"][v.gui] then
			local element = _G["guielements"][v.gui]
			if element.active and v.showing then
				local split = v.text:split("|")
				local longesttext = 1
				for x = 2, #split do
					if string.len(split[x]) > string.len(split[longesttext]) then
						longesttext = x
					end
				end
				local x, y, width, height = love.mouse.getX()/scale, love.mouse.getY()/scale, (string.len(split[longesttext])+1)*8, (#split+1)*10
				love.graphics.setColor(0, 0, 0, 255)
				love.graphics.rectangle("fill", (x-1)*scale, (y-1)*scale, (width+2)*scale, (height+2)*scale)
				love.graphics.setColor(255, 255, 255, 255)
				drawrectangle(x, y, width, height)
				love.graphics.setColor(v.titlecolor)
				properprintbackground(v.title, (x+2)*scale, (y+2)*scale, true)
				love.graphics.setColor(255, 255, 255)
				properprint(v.text, (x+2)*scale, (y+12)*scale)
			end
		end
	end

end

function sendchat()
	if string.len(guielements.chatentry.value) > 0 then 
		local stringtosend = lobby_playerlist[1].nick .. ":"
		network_sendchat(stringtosend .. guielements.chatentry.value)
		guielements.chatentry.value = ""
		guielements.chatentry.cursorpos = 1
		guielements.chatentry.inputting = true
	end
end

function toggleinflives()
	if clientisnetworkhost then
		infinitelives = not infinitelives
		guielements.livescheckbox.var = infinitelives
		local toggle = "0"
		if infinitelives then
			toggle = "1"
		end
		udp:send("inflives;1;" .. toggle)
	end
end

function mappackincrease()
	if clientisnetworkhost then
		lobby_mappackselectionnumber = lobby_mappackselectionnumber + 1
		if lobby_mappackselectionnumber > #mappacklist then
			lobby_mappackselectionnumber = 1
		end
		mappack = mappacklist[lobby_mappackselectionnumber]

		guielements.mappackincrease.x = 78+(string.len(mappackname[lobby_mappackselectionnumber])+1)*8

		loadbackground("1-1.txt")
		udp:send("changemappack;1;" .. mappackname[lobby_mappackselectionnumber])
		lobby_currentmappackallowed = false

		for x = 1, #allowedmappacklist do
			if allowedmappacklist[x] == mappackname[lobby_mappackselectionnumber] then
				lobby_currentmappackallowed = true
			end
		end
	end
end

function mappackdecrease()
	if clientisnetworkhost then
		lobby_mappackselectionnumber = lobby_mappackselectionnumber - 1
		if lobby_mappackselectionnumber < 1 then
			lobby_mappackselectionnumber = #mappacklist
		end
		mappack = mappacklist[lobby_mappackselectionnumber]

		guielements.mappackincrease.x = 78+(string.len(mappackname[lobby_mappackselectionnumber])+1)*8

		loadbackground("1-1.txt")
		udp:send("changemappack;1;" .. mappackname[lobby_mappackselectionnumber])

		lobby_currentmappackallowed = false

		for x = 1, #allowedmappacklist do
			if allowedmappacklist[x] == mappackname[lobby_mappackselectionnumber] then
				lobby_currentmappackallowed = true
			end
		end
	end
end

function lobby_globalmappacks(datatable)
	print("got all mappacks")
	allowedmappacklist = {}
	for x = 2, #datatable do 
		table.insert(allowedmappacklist, datatable[x])
	end

	lobby_currentmappackallowed = false

	for x = 1, #allowedmappacklist do
		if allowedmappacklist[x] == mappackname[lobby_mappackselectionnumber] then
			lobby_currentmappackallowed = true
		end
	end
end

function lobby_changemappack(datatable)
	for x = 1, #mappackname do
		if mappackname[x] == datatable[2] then
			mappack = mappacklist[x]
			loadbackground("1-1.txt")
			lobby_mappackselectionnumber = x
			guielements.mappackincrease.x = 78+(string.len(mappackname[lobby_mappackselectionnumber])+1)*8
			break
		end
	end
end

function maxplayersdecrease()
	if clientisnetworkhost then
		lobby_maxplayers = lobby_maxplayers - 1
		if lobby_maxplayers < 2 then
			lobby_maxplayers = 99
		end
		server_resyncmaxplayers = true
		guielements.maxplayersincrease.x = 128+(string.len(tostring(lobby_maxplayers))-1)*8

	end
end

function maxplayersincrease()
	if clientisnetworkhost then
		lobby_maxplayers = lobby_maxplayers + 1
		if lobby_maxplayers > 99 then
			lobby_maxplayers = 2
		end
		server_resyncmaxplayers = true
		guielements.maxplayersincrease.x = 128+(string.len(tostring(lobby_maxplayers))-1)*8

	end
end

function lobby_changemaxplayers(datatable)
	lobby_maxplayers = tonumber(datatable[2])
	guielements.maxplayersincrease.x = 128+(string.len(tostring(lobby_maxplayers))-1)*8
end

function toggleshowmagicdns()
	lobby_showmagicdns = not lobby_showmagicdns
	guielements.showmagicdnsbutton.var = lobby_showmagicdns
end

function lobby_pageincrease()
	lobby_currentpage = math.min(lobby_currentpage+1, lobby_numberofpages)
	for x = 1, #lobby_guielementspageactive do
		if x == lobby_currentpage then
			for i, v in pairs(lobby_guielementspageactive[x]) do
				_G["guielements"][v].active = true
			end
		else
			for i, v in pairs(lobby_guielementspageactive[x]) do
				_G["guielements"][v].active = false
			end
		end
	end

end

function lobby_pagedecrease()
	lobby_currentpage = math.max(lobby_currentpage-1, 1)
	for x = 1, #lobby_guielementspageactive do
		if x == lobby_currentpage then
			for i, v in pairs(lobby_guielementspageactive[x]) do
				_G["guielements"][v].active = true
			end
		else
			for i, v in pairs(lobby_guielementspageactive[x]) do
				_G["guielements"][v].active = false
			end
		end
	end
end

function togglesharedportals()
	if clientisnetworkhost then
		playersaresharingportals = not playersaresharingportals
		guielements.shareportalscheckbox.var = playersaresharingportals
		local toggle = "0"
		if playersaresharingportals then
			toggle = "1"
		end
		udp:send("sharingportals;1;" .. toggle)
	end
end

function lobby_changesharedportalsvalue(datatable)
	playersaresharingportals = (datatable[2] == "1")
	if guielements.shareportalscheckbox then
		guielements.shareportalscheckbox.var = playersaresharingportals
	end
end

function toggleinfinitetime()
	if clientisnetworkhost then
		infinitetime = not infinitetime
		guielements.infinitetimecheckbox.var = infinitetime
		local toggle = "0"
		if infinitetime then
			toggle = "1"
		end
		udp:send("infinitetimefunction;1;" .. toggle)
	end
end

function lobby_setinfinitetime(datatable)
	infinitetime = (datatable[2] == "1")
	if guielements.infinitetimecheckbox then
		guielements.infinitetimecheckbox.var = infinitetime
	end
end

function togglesingularmario()
	if clientisnetworkhost then
		singularmariogamemode = not singularmariogamemode
		guielements.singularmariocheckbox.var = singularmariogamemode
		lobby_sendcheckboxvalue(singularmariogamemode, "singularmario")
	end
end

function lobby_sendcheckboxvalue(togglevalue, identifierstring)
	local togglestring = "0"
	if togglevalue then
		togglestring = "1"
	end
	udp:send("checkboxvaluechange;1;" .. togglestring .. ";" .. identifierstring)
end

function lobby_synccheckboxvalue(datatable)
	if datatable[3] == "singularmario" then
		singularmariogamemode = (datatable[2] == "1")
		if guielements.singularmariocheckbox then
			guielements.singularmariocheckbox.var = singularmariogamemode
		end
	elseif datatable[3] == "classicmode" then
		classicmodeactive = (datatable[2] == "1")
		if guielements.classicmodecheckbox then
			guielements.classicmodecheckbox.var = classicmodeactive
		end
	end
end

function toggleclassicmode()
	if clientisnetworkhost then
		classicmodeactive = not classicmodeactive
		guielements.classicmodecheckbox.var = classicmodeactive
		lobby_sendcheckboxvalue(classicmodeactive, "classicmode")
	end
end

