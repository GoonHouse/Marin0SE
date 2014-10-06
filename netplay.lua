local alternatesynctimer = -5
networkynccedconfig = false
seesawisync = {}

function network_load(ip, port)
	local port = port
	if not port then
		port = 27020
	end
	marioworld = 1
	mariolevel = 1
	udp = socket.udp()
	udp:settimeout(0)
	print(ip, tonumber(ip))
	udp:setpeername(ip, port)
	print(ip, port, tostring(udp))
	local thing = tostring(udp)
	print(thing)
	local split = thing:split(":")
	print(split[1])
	if split[1] == "udp{connected}" then
		udp:send("connect;" .. guielements.nickentry.value)
	else
		notice.new("server not found ", notice.red, 5)
	end
	

	networktimeouttimer = 0
	networkwarningssent = 0

	local sendthing = "return { nick=\""
	sendthing = sendthing .. guielements.nickentry.value .. "\"}"

	love.filesystem.write("savenick.txt", sendthing)

	network_removeplayertimeouttables = {}
	for x = 1, math.max(players, 4) do
		network_removeplayertimeouttables[x] = 0
	end
end

function network_update(dt)
	local data, msg = udp:receive()
	if objects then
		networktimeouttimer = networktimeouttimer + dt
		for x = 2, math.max(players, 4) do
			network_removeplayertimeouttables[x] = network_removeplayertimeouttables[x]+dt
		end
	end
	while data ~= nil do
		datatable = data:split(";")
		if datatable[1] == "reject" then
			if datatable[2] == "full" then
				notice.new("server is full", notice.red, 5)
			end
			onlinemp = false
			udp:close()
			return
		end
		if datatable[1] ~= "synccoords" and datatable[1] ~= "otherpointingangle" then
			--print(datatable[1])
		end

		if data == "endgame" then
			gamefinished = true
			love.audio.stop()
			gamestate = "lobby"
			objects = nil
			loadbackground("1-1.txt")
			lobby_maxplayers = 4
			local showmagicdns = lobby_showmagicdns
			lobby_load(LOBBY_HOSTNICK)
			guielements.showmagicdnsbutton.var = showmagicdns
			lobby_showmagicdns = showmagicdns
			networksynccedconfig = false
			return
		end


		if datatable[1] == "hats" then
			local table = {}
			for x = 1, #datatable-2 do
				table[x] = tonumber(datatable[x+2])
			end
			mariohats[convertclienttoplayer(tonumber(datatable[2]))] = table
			print("received player " .. convertclienttoplayer(tonumber(datatable[2])) .. "\'s hats")
			if not lobby_playerlist[convertclienttoplayer(tonumber(datatable[2]))] then
				lobby_playerlist[convertclienttoplayer(tonumber(datatable[2]))] = {}
			end
			lobby_playerlist[convertclienttoplayer(tonumber(datatable[2]))].hats = mariohats[convertclienttoplayer(tonumber(datatable[2]))]

			if objects then
				if objects["player"][convertclienttoplayer(tonumber(datatable[2]))] then
					objects["player"][convertclienttoplayer(tonumber(datatable[2]))].hats = mariohats[convertclienttoplayer(tonumber(datatable[2]))]
				end
			end


		elseif datatable[1] == "color" then
			mariocolors[convertclienttoplayer(tonumber(datatable[2]))] = {{datatable[3], datatable[4], datatable[5]}, {datatable[6], datatable[7], datatable[8]}, {datatable[9], datatable[10], datatable[11]}}
			print("received player " .. convertclienttoplayer(tonumber(datatable[2])) .. "\'s colors")

			if not lobby_playerlist[convertclienttoplayer(tonumber(datatable[2]))] then
				lobby_playerlist[convertclienttoplayer(tonumber(datatable[2]))] = {}
			end
			lobby_playerlist[convertclienttoplayer(tonumber(datatable[2]))].colors = mariocolors[convertclienttoplayer(tonumber(datatable[2]))]

			if objects then
				if objects["player"][convertclienttoplayer(tonumber(datatable[2]))] then
					objects["player"][convertclienttoplayer(tonumber(datatable[2]))].colors = mariocolors[convertclienttoplayer(tonumber(datatable[2]))]
				end
			end

		elseif datatable[1] == "portalcolor" then
			portalcolor[convertclienttoplayer(tonumber(datatable[2]))][1] = {datatable[3], datatable[4], datatable[5]}
			portalcolor[convertclienttoplayer(tonumber(datatable[2]))][2] = {datatable[6], datatable[7], datatable[8]}

			if objects then
				if objects["player"][convertclienttoplayer(tonumber(datatable[2]))] then
					objects["player"][convertclienttoplayer(tonumber(datatable[2]))].portal1color = portalcolor[convertclienttoplayer(tonumber(datatable[2]))][1]
					objects["player"][convertclienttoplayer(tonumber(datatable[2]))].portal2color = portalcolor[convertclienttoplayer(tonumber(datatable[2]))][2]
				end
			end

		end



		

		if not objects then
			if datatable[1] == "synccoords" and levelscreentimer < 0.01 then
				connectionstate = "starting game..."
				players = #lobby_playerlist
				game_load()
			end

			network_generallobbysyncs(datatable)
			return
		end

		if datatable[2] and tonumber(datatable[2]) then
			network_removeplayertimeouttables[convertclienttoplayer(tonumber(datatable[2]))] = 0
		end

		if _G["network_" .. datatable[1]] and datatable[1] ~= "clientnumber" then
			_G["network_" .. datatable[1]](datatable)
		end
		if networktimeouttimer > 10 then
			notice.new("connection re-established", notice.red, 5)
		end
		networktimeouttimer = 0


	

		data, msg = udp:receive()
	end

	if networkclientnumber and networkclientnumber ~= 0 and not networksynccedconfig then
		networksynccedconfig = true
		local string = "hats;" .. networkclientnumber
		for x = 1, #mariohats[playerconfig] do
			string = string .. ";" .. mariohats[playerconfig][x]
		end
		udp:send(string)
		local string = "color;" .. networkclientnumber
		local v = mariocolors[playerconfig]
		for set = 1, 3 do
			for color = 1, 3 do
				string = string .. ";" .. mariocolors[playerconfig][set][color]
			end
		end		
		udp:send(string)

		local string = "mappacklist;" .. networkclientnumber
		for x = 1, #mappackname do
			string = string .. ";" .. mappackname[x]
		end

		udp:send(string)

		local string = "portalcolor;" .. networkclientnumber
		for x = 1, 2 do
			for y = 1, 3 do
				string = string .. ";" .. portalcolor[playerconfig][x][y]
			end
		end

		udp:send(string)
	end

	if not objects then
		return
	end
	networkupdatetimer = networkupdatetimer + dt
	if networkupdatetimer > networkupdatelimit then 
		networkupdatetimer = networkupdatetimer - networkupdatelimit
		--print(dt)
		udp:send("move;" .. networkclientnumber .. ";" .. round(objects["player"][1].x, 2) .. ";" .. round(objects["player"][1].y, 2) .. ";" .. round(objects["player"][1].speedx, 2) .. ";" .. round(objects["player"][1].speedy, 2) .. ";" .. round(love.timer.getDelta(), 4))
		--print(dt)
	end

	angletimer = angletimer + dt
	if angletimer > .1 and not clientisnetworkhost then
		angletimer = 0
		udp:send("pointingangle;" .. networkclientnumber .. ";" .. round(objects["player"][1].pointingangle, 2))
	elseif angletimer > .5 and clientisnetworkhost then
		if alternatesynctimer < 0 then
			alternatesynctimer = 0
		end
	end

	enemyupdatetimer = enemyupdatetimer + dt
	if enemyupdatetimer > 1 and clientisnetworkhost then
		enemyupdatetimer = 0
		for i, v in pairs(objects["goomba"]) do
			udp:send("goombasync;" .. networkclientnumber .. ";" .. round(v.x, 2) .. ";" .. round(v.y, 2) .. ";" .. round(v.speedx, 2) .. ";" .. i)
		end


		for i, v in pairs(objects["squid"]) do
			local closestplayer = v.closestplayer
			if closestplayer == 1 then
				closestplayer = 2
			else
				closestplayer = 1
			end
			udp:send("squidsync;" .. networkclientnumber .. ";" .. round(v.x, 2) .. ";" .. round(v.y, 2) .. ";" .. closestplayer .. ";" .. i)
		end
		if objects["bowser"][1] then
			udp:send("bowsersync;" .. networkclientnumber .. ";" .. round(objects["bowser"][1].x, 2) .. ";" .. round(objects["bowser"][1].y, 2) .. ";" .. round(objects["bowser"][1].targetx, 2) .. ";" .. round(objects["bowser"][1].speedy, 2))
		end

		local castlefirestosend = {}

		for i, v in pairs(objects["castlefire"]) do
			for x = 2, players do
				local k = objects["player"][x]
				if v.x > k.x - width*.75 and v.x < k.x + width*.35 then
					table.insert(castlefirestosend, i)
					break
				end
			end
		end

		for x = 1, #castlefirestosend do
			udp:send("cfiresync;" .. networkclientnumber .. ";" .. round(objects["castlefire"][castlefirestosend[x]].angle, 2) .. ";" .. castlefirestosend[x])
		end
		local platformstosend = {}

		for i, v in pairs(objects["platform"]) do
			for x = 2, players do
				local k = objects["player"][x]
				if v.x > k.x - width*.75 and v.x < k.x + width*.35 then
					table.insert(platformstosend, i)
					break
				end
			end
		end

		for x = 1, #platformstosend do
			local v = objects["platform"][platformstosend[x]]
			if v.dir == "right" or v.dir == "up" then
				udp:send("pformsync;" .. networkclientnumber .. ";" .. round(v.timer, 3) .. ";" .. platformstosend[x])
			--elseif v.dir == "fall" then
				--udp:send("pformsync" .. networkclientnumber .. ";" .. round(v.y, 2) .. ";" .. platformstosend[x] .. ";fall")
			end
		end

	--[[	local upfirestosend = getobjectsonscreen("upfire")

		for x = 1, #upfirestosend do
			udp:send("upfiresync;" .. networkclientnumber .. ";" .. round(objects["upfire"][upfirestosend[x.y, 2) .. ";" .. round(objects["upfire"][upfirestosend[x].speedy, 2) .. ";" .. upfirestosend[x])
		end--]]

	end

	if alternatesynctimer >= 0 then
		alternatesynctimer = alternatesynctimer + dt
	end

	if alternatesynctimer > 1 then
		alternatesynctimer = 0
		if clientisnetworkhost then
			for i, v in pairs(objects["koopa"]) do
				local size = "1"
				if v.flying then
					size = "2"
				elseif v.small then
					size = "0"
				end
				udp:send("koopasync;" .. networkclientnumber .. ";" .. round(v.x, 2) .. ";" .. round(v.y, 2) .. ";" .. round(v.speedx, 2) .. ";" .. size .. ";" .. i)
			end

			for i, v in pairs(objects["box"]) do
				local string = "boxsync;" .. networkclientnumber .. ";" .. round(v.x, 2) .. ";" .. round(v.y, 2) .. ";" .. i
				if v.parent then
					string = string .. ";" .. v.parent.playernumber
				end
				udp:send(string)
			end

			for i, v in pairs(objects["mushroom"]) do
				udp:send("mushroomsync;" .. networkclientnumber .. ";" .. round(v.x, 2) .. ";" .. round(v.y, 2) .. ";" .. round(v.speedx, 2) .. ";" .. i)
			end
		elseif lastplayeronplatform then
			for i, v in pairs(seesawisync) do
				udp:send("seesaw;" .. networkclientnumber .. ";" .. round(objects["seesawplatform"][v].y, 2) .. ";" .. v)
			end
		end 
 	end

	--Any thing that needs to be sent on a trigger
	for x = #networksendqueue, 1, -1 do
		udp:send(networksendqueue[x])
		table.remove(networksendqueue, x)
	end
	if networktimeouttimer > 20 then
		network_quit()
		notice.new("timed out", notice.red, 6)
	end

	if networktimeouttimer > 10+networkwarningssent and networktimeouttimer < 20 then
		networkwarningssent = networkwarningssent + 1
		notice.new("connection problem ... disconnecting in " .. 10-networkwarningssent, notice.red, 2)
	end

	for x = 2, players do
		if network_removeplayertimeouttables[x] > 15 then
			table.remove(objects["player"], x)
			players = players - 1
		end
	end

end

function getobjectsonscreen(objectstring)
	local objectstosend = {}

	for i, v in pairs(objects[objectstring]) do
		for x = 2, players do
			local k = objects["player"][x]
			if v.x > k.x - width * .75 and v.x < k.x + width then
				table.insert(objectstosend, i)
				break
			end
		end
	end

	return objectstosend
end

function network_pingcheck(datatable)
	udp:send("pingback;" .. networkclientnumber)
end

function network_quit(datatable)


	onlinemp = false
	if not clientisnetworkhost then
		udp:send("clientquit;" .. networkclientnumber)
	else
		server_shutserver()
	end


	if clientisnetworkhost then
		magicdns_remove()
	end


	gamestate = "menu"
	players = 1
	menu_load()
	guielements = {}

	if datatable then
		notice.new("host shut server", notice.red, 6)
	end

	udp:close()


end

function network_generallobbysyncs(datatable)

	if datatable[1] == "connected" then
		networksynccedconfig = false
		local nick = guielements.nickentry.value
		lobby_load(nick)
		print("connected")

	elseif datatable[1] == "startgame" then
		connectionstate = "starting game..."
		players = tonumber(datatable[2])
		game_load()

	elseif datatable[1] == "clientnumber" then
		networkclientnumber = tonumber(datatable[2])
		print("my client number is " .. networkclientnumber)


	elseif datatable[1] == "chat" then
		if not objects then
			network_chat(datatable)
		end


	elseif datatable[1] == "nick" then
		if not lobby_playerlist[convertclienttoplayer(tonumber(datatable[2]))] then
			lobby_playerlist[convertclienttoplayer(tonumber(datatable[2]))] = {}
		end
		lobby_playerlist[convertclienttoplayer(tonumber(datatable[2]))].nick = datatable[3]


	elseif datatable[1] == "pingupdate" then
		if not lobby_playerlist[convertclienttoplayer(tonumber(datatable[2]))] then
			lobby_playerlist[convertclienttoplayer(tonumber(datatable[2]))] = {}
		end
		lobby_playerlist[convertclienttoplayer(tonumber(datatable[2]))].ping = datatable[3]


	elseif datatable[1] == "pingcheck" then
		network_pingcheck()
	elseif datatable[1] == "inflives" then
		network_inflives(datatable)
	elseif datatable[1] == "sharetheportals" then
		lobby_changesharedportalsvalue(datatable)
	elseif datatable[1] == "setinfinitetime" then
		lobby_setinfinitetime(datatable)
	elseif datatable[1] == "synccheckboxvalue" then
		lobby_synccheckboxvalue(datatable)
	elseif datatable[1] == "globalmappacks" then
		lobby_globalmappacks(datatable)
	elseif datatable[1] == "changemappack" then
		lobby_changemappack(datatable)
	elseif datatable[1] == "changemax" then
		lobby_changemaxplayers(datatable)
	elseif datatable[1] == "removepeer" then
		table.remove(lobby_playerlist, tonumber(datatable[2]))
		--[[players = players - 1
		table.remove(objects["player"], tonumber(datatable[2]))--]]
	elseif datatable[1] == "quit" then
		network_quit(datatable)
	end
end

function network_synccoords(datatable)
	if objects then
		objects["player"][convertclienttoplayer(tonumber(datatable[2]))].x = tonumber(datatable[3])
		objects["player"][convertclienttoplayer(tonumber(datatable[2]))].y = tonumber(datatable[4])
		objects["player"][convertclienttoplayer(tonumber(datatable[2]))].speedx = tonumber(datatable[5])
		objects["player"][convertclienttoplayer(tonumber(datatable[2]))].speedy = tonumber(datatable[6])
		objects["player"][convertclienttoplayer(tonumber(datatable[2]))].currentdt = tonumber(datatable[7])
		local currentdt = tonumber(datatable[7])
	end


	--[[if not clientisnetworkhost then
		for i, v in pairs(objects["goomba"]) do
			v.currentdt = currentdt
		end
		for i, v in pairs(objects["koopa"]) do
			v.currentdt = currentdt
		end
	end--]]
end

function network_portal(datatable)
	createportal(convertclienttoplayer(tonumber(datatable[2])), tonumber(datatable[3]), tonumber(datatable[4]), tonumber(datatable[5]), datatable[6], tonumber(datatable[7]), tonumber(datatable[8]), tonumber(datatable[9]), tonumber(datatable[10]), tonumber(datatable[11]), true)
end

function network_shoot(datatable)
	shootportal(convertclienttoplayer(tonumber(datatable[2])), tonumber(datatable[3]), tonumber(datatable[4]), tonumber(datatable[5]), tonumber(datatable[6]), true)
end

function network_hitblock(datatable)
	hitblock(tonumber(datatable[3]), tonumber(datatable[4]), objects["player"][convertclienttoplayer(tonumber(datatable[2]))], true)
end

function network_death(datatable)
	objects["player"][convertclienttoplayer(tonumber(datatable[2]))]:die(datatable[3], true)
end

function network_powerup(datatable)
	local x, y = math.floor(datatable[3]), math.floor(datatable[4])
	if datatable[5] then
		--star
		objects["player"][convertclienttoplayer(tonumber(datatable[2]))]:star(nil, true)
		if #objects["star"] == 1 then
			objects["star"][1].destroy = true
		end

		local triggered
		for i, v in pairs(objects["star"]) do
			if math.floor(v.x) == x and math.floor(v.y) == y then
				v.destroy = true
				triggered = true
			end
		end
	

		if not triggered then
			for i, v in pairs(objects["player"]) do
				if i ~= 1 then
					for j, k in pairs(objects["mushroom"]) do
						if aabb(v.x-1/2, v.y, v.width+1, v.height, k.x, k.y, k.width, k.height) then
							k.destroy = true
						end
					end
				end
			end
		end

	else
		objects["player"][convertclienttoplayer(tonumber(datatable[2]))]:grow()
		local triggered
		if #objects["mushroom"] == 1 and #objects["flower"] == 0 then
			objects["mushroom"][1].destroy = true
			objects["mushroom"][1].drawable = false
			triggered = true
		end
		if #objects["flower"] == 1 and #objects["mushroom"] == 0 then
			objects["flower"][1].destroy = true
			objects["flower"][1].drawable = false
			triggered = true
		end
		if not triggered then
			for i, v in pairs(objects["mushroom"]) do
				if math.floor(v.x) == x and math.floor(v.y) == y then
					v.destroy = true
					v.drawable = false
					triggered = true
				end
			end
		end

		if not triggered then
			for i, v in pairs(objects["player"]) do
				if i ~= 1 then
					for j, k in pairs(objects["mushroom"]) do
						if aabb(v.x-1/2, v.y, v.width+1, v.height, k.x, k.y, k.width, k.height) then
							k.destroy = true
							k.drawable = false
							triggered = true
						end
					end
				end
			end
		end

		if not triggered then
			for i, v in pairs(objects["flower"]) do
				if math.floor(v.x) == x and math.floor(v.y) == y then
					v.destroy = true
					v.drawable = false
					triggered = true
				end
			end
		end

		if not triggered then
			for i, v in pairs(objects["player"]) do
				if i ~= 1 then
					for j, k in pairs(objects["flower"]) do
						if aabb(v.x-4/16, v.y, v.width+1/2, v.height, k.x, k.y, k.width, k.height) then
							k.destroy = true
							k.drawable = false
							triggered = true
						end
					end
				end
			end
		end
	end
end

function network_poisonmushed(datatable)
	if #objects["poisonmush"] == 1 then
		objects["poisonmush"][1].destroy = true
		triggered = true
	end

	for i, v in pairs(objects["poisonmush"]) do
		--print(math.floor(v.x), x, math.floor(v.y), y)
		if math.floor(v.x) == x or math.floor(v.y) == y then
			v.destroy = true
		end
	end
	
end

function network_lives(datatable)
	for x = 1, players do
		mariolives[x] = tonumber(datatable[x+1])
	end
	local x, y = tonumber(datatable[players+2]), tonumber(datatable[players+3])

	local triggered

	if #objects["oneup"] == 1 then
		objects["oneup"][1].destroy = true
		triggered = true
	end

	for i, v in pairs(objects["oneup"]) do
		--print(math.floor(v.x), x, math.floor(v.y), y)
		if math.floor(v.x) == x or math.floor(v.y) == y then
			v.destroy = true
		end
	end

	if not triggered then
		for i, v in pairs(objects["player"]) do
			if i ~= 1 then
				for j, k in pairs(objects["oneup"]) do
					if aabb(v.x-4/16, v.y, v.width+1/2, v.height, k.x, k.y, k.width, k.height) then
						v.destroy = true
					end
				end
			end
		end
	end

	table.insert(scrollingscores, scrollingscore:new("1up", x, y))
	playsound(oneupsound)
	respawnplayers()
end

function network_otherpointingangle(datatable)
	objects["player"][convertclienttoplayer(tonumber(datatable[2]))].pointingangle = tonumber(datatable[3])
end

function network_goombakill(datatable)
	local x, y = math.floor(datatable[3]), math.floor(datatable[4])
	local triggered

	local goombaobject
	for i, v in pairs(objects["goomba"]) do
		if math.floor(v.x) == x and math.floor(v.y) == y then
			goombaobject = v
			triggered = true
		end
	end

	if not triggered then
		for i, v in pairs(objects["player"]) do
			if i ~= 1 then
				for j, k in pairs(objects["goomba"]) do
					if aabb(v.x-4/16, v.y-1, v.width+1/2, v.height+2, k.x, k.y, k.width, k.height) then
						goombaobject = k
						triggered = true
					end
				end
			end
		end
	end

	if triggered then
		if datatable[5] == "stomp" then
			objects["player"][convertclienttoplayer(tonumber(datatable[2]))]:stompenemy("goomba", goombaobject, true)
		else
			goombaobject:shotted(nil, true)
		end
	end
end

function network_jump(datatable)
	objects["player"][convertclienttoplayer(tonumber(datatable[2]))]:jump(true)
end

function network_reloadportals(datatable)
	objects["player"][convertclienttoplayer(tonumber(datatable[2]))]:removeportals()
end

function network_fireball(datatable)
	objects["player"][convertclienttoplayer(tonumber(datatable[2]))]:fire(datatable[3], datatable[4], datatable[5], objects["player"][convertclienttoplayer(tonumber(datatable[2]))])
end

function network_koopastomp(datatable)
	local x, y = math.floor(datatable[3]), math.floor(datatable[4])
	local triggered

	local koopaobject
	for i, v in pairs(objects["koopa"]) do
		if math.floor(v.x) == x and math.floor(v.y) == y then
			koopaobject = v
			triggered = true
		end
	end

	local distances = {}
	local sqrt = math.sqrt

	if not triggered then
		local v = objects["player"][convertclienttoplayer(tonumber(datatable[2]))]
		for j, k in pairs(objects["koopa"]) do
			local distancecalculation = sqrt((k.x-v.x)^2 +(k.y-v.y)^2)
			table.insert(distances, {distance=distancecalculation, id=j})
			if aabb(v.x-1/2, v.y-1, v.width+1, v.height+2, k.x, k.y, k.width, k.height) then
				koopaobject = k
				triggered = true
			end
		end
	end

	if not triggered then
		local farthestdistance = 1
		for x = 2, #distances do
			if distances[x].distance > distances[farthestdistance].distance then
				farthestdistance = x
			end
		end
		koopaobject = objects["koopa"][farthestdistance]
		if koopaobject then
			triggered = true
		end
	end



	if triggered then
		objects["player"][convertclienttoplayer(tonumber(datatable[2]))]:stompenemy("koopa", koopaobject, true)
	end
end

function network_spawnenemy(datatable)
	spawnenemy(tonumber(datatable[2]), tonumber(datatable[3]), true)
end

function network_duck(datatable)
	objects["player"][convertclienttoplayer(tonumber(datatable[2]))]:duck(datatable[3] == "true")
end

function network_pipe(datatable)
	local location = tonumber(datatable[6])
	if not location then
		location = datatable[6]
	end

	objects["player"][convertclienttoplayer(tonumber(datatable[2]))]:pipe(tonumber(datatable[3]), tonumber(datatable[4]), datatable[5], location)
end

function network_goombasync(datatable)
	local i = tonumber(datatable[5])
	if objects["goomba"][i] then
	 	objects["goomba"][i].x = tonumber(datatable[2])
		objects["goomba"][i].y = tonumber(datatable[3])
		objects["goomba"][i].speedx = tonumber(datatable[4])
	else
		objects["goomba"][i] = goomba:new(tonumber(datatable[2]), tonumber(datatable[3]), "goomba")
		objects["goomba"][i].speedx = tonumber(datatable[4])
	end
end

function network_mushroomsync(datatable)
	local i = objects["mushroom"][tonumber(datatable[5])]
	if i then
		i.x = tonumber(datatable[2])
		i.y = tonumber(datatable[3])
		i.speedx = tonumber(datatable[4])
	end
end

function network_koopasync(datatable)
	local i = tonumber(datatable[6])
	if objects["koopa"][i] then
	 	objects["koopa"][i].x = tonumber(datatable[2])
		objects["koopa"][i].y = tonumber(datatable[3])
		objects["koopa"][i].speedx = tonumber(datatable[4])
		if datatable[5] == "2" then
			objects["koopa"][i].flying = true
			objects["koopa"][i].small = false
		elseif datatable[5] == "1" then
			objects["koopa"][i].flying = false
			objects["koopa"][i].small = false
		else
			objects["koopa"][i].small = true
			objects["koopa"][i].flying = false
		end
	end
end


function network_chat(datatable)
	chatmessagegradient = 180
	local chatdata = datatable[2]:split(":")
	table.insert(chatlog, 1, {id=chatdata[1], message=chatdata[2]})
end

function network_finish(datatable)
	mariotime = tonumber(datatable[3])
	if datatable[4] == "flag" then
		objects["player"][convertclienttoplayer(tonumber(datatable[2]))]:flag(true)
	else
		objects["player"][convertclienttoplayer(tonumber(datatable[2]))]:axe(true)
	end
end

function network_firespawn(datatable)
	local newfire = fire:new(tonumber(datatable[2]), tonumber(datatable[3])) 
	newfire.x = tonumber(datatable[2])
	newfire.y = tonumber(datatable[3])
	newfire.targety = tonumber(datatable[4])
	table.insert(objects["fire"], newfire)
end

function network_bowsersync(datatable)
	if objects["bowser"][1] then
		objects["bowser"][1].x = tonumber(datatable[2])
		objects["bowser"][1].y = tonumber(datatable[3])
		objects["bowser"][1].targetx = tonumber(datatable[4])
		objects["bowser"][1].speedy = tonumber(datatable[5])
	end
end

function network_bowserjump(datatable)
	if objects["bowser"][1] then
		objects["bowser"][1].speedy = tonumber(datatable[2])
		objects["bowser"][1].jump = true
	end
end

function network_cfiresync(datatable)
	if objects["castlefire"][tonumber(datatable[3])] then
		objects["castlefire"][tonumber(datatable[3])].angle = tonumber(datatable[2])
	end
end

function network_pformsync(datatable)
	--print(datatable[4])
	if objects["platform"][tonumber(datatable[3])] then
		if datatable[4] ~= "fall" then
			objects["platform"][tonumber(datatable[3])].timer = tonumber(datatable[2])
		else
			objects["platform"][tonumber(datatable[3])].y = tonumber(datatable[2])
		end
	end
end

function network_createpform(datatable)
	table.insert(objects["platform"], platform:new(tonumber(datatable[2]), tonumber(datatable[3]), datatable[4], tonumber(datatable[5])))
end

function network_squidstate(datatable)
	local object = objects["squid"][tonumber(datatable[2])]
	if object then
		object.state = datatable[3]
		if datatable[3] == "upward" then
			object.upx = tonumber(datatable[5])
			object.direction = datatable[4]
		elseif datatable[3] == "downward" then
			object.quad = squidquad[2]
			object.downy = tonumber(datatable[5])
			object.direction = datatable[4]
			object.speedx = 0
		elseif datatable[3] == "idle" then
			object.quad = squidquad[1]
		end
	end

end

function network_squidsync(datatable)
	if objects["squid"][tonumber(datatable[5])] then
		objects["squid"][tonumber(datatable[5])].x = tonumber(datatable[2])
		objects["squid"][tonumber(datatable[5])].y = tonumber(datatable[3])
		objects["squid"][tonumber(datatable[5])].closestplayer = tonumber(datatable[4])
	end
end

function network_fishspawn(datatable)
	local fish = flyingfish:new()
	fish.x = tonumber(datatable[2])
	fish.speedx = tonumber(datatable[3])
	table.insert(objects["flyingfish"], fish)
end

function network_upfireup(datatable)
	if objects["upfire"][tonumber(datatable[2])] then
		objects["upfire"][tonumber(datatable[2])].y = objects["upfire"][tonumber(datatable[2])].coy + upfirestarty
		objects["upfire"][tonumber(datatable[2])].speedy = -upfireforce
	end
end

function network_hammer(datatable)
	table.insert(objects["hammer"], hammer:new(tonumber(datatable[2]), tonumber(datatable[3]), datatable[4]))
end

function network_brojump(datatable)
	local broobject = objects["hammerbro"][tonumber(datatable[3])]
	if broobject then
		if datatable[2] == "up" then
			broobject.speedy = -hammerbrojumpforce
			broobject.mask[2] = true
			broobject.jumping = "up"
		else
			broobject.speedy = -hammerbrojumpforcedown
			broobject.mask[2] = true
			broobject.jumping = "down"
			broobject.jumpingy = broobject.y
		end
	end
end

function network_objectshotted(datatable)
	local x, y = tonumber(datatable[2]), tonumber(datatable[3])
	local triggered

	local object
	for i, v in pairs(objects[datatable[5]]) do
		if math.floor(v.x) == x and math.floor(v.y) == y then
			object = v
			triggered = true
			break
		end
	end

	if not triggered and objects[name] then
		for j, k in pairs(objects[name]) do
			if aabb(x-4/16, y-1, 1.5, 4, k.x, k.y, k.width, k.height) then
				object = k
				triggered = true
				break
			end
		end
	end

	if triggered then
		object:shotted(datatable[4], true)
	end

end

function network_seesaw(datatable)
	if objects["seesawplatform"][tonumber(datatable[3])] and not lastplayeronplatform then
		objects["seesawplatform"][tonumber(datatable[3])].y = tonumber(datatable[2])
	end
end

function network_spikespawn(datatable)
	table.insert(objects["goomba"], goomba:new(tonumber(datatable[2]), tonumber(datatable[3]), "spikeyfall"))
end

function network_spiketurn(datatable)
	if objects["goomba"][tonumber(datatable[2])] then
		objects["goomba"][tonumber(datatable[2])].speedx = goombaspeed
		objects["goomba"][tonumber(datatable[2])].animationdirection = "left"
	end
end

function network_mazevar(datatable)
	for x = 1, players do
		objects["player"][x].mazevar = tonumber(datatable[2])
	end
end

function network_bulletspawn(datatable)
	table.insert(objects["bulletbill"], bulletbill:new(tonumber(datatable[2]), tonumber(datatable[3]), datatable[4]))
end

function network_plantout(datatable)
	if objects["plant"][tonumber(datatable[2])] then
		objects["plant"][tonumber(datatable[2])].timer2 = 0
	end
end

function network_redplantout(datatable)
	if objects["redplant"][tonumber(datatable[2])] then
		objects["redplant"][tonumber(datatable[2])].timer2 = 0
	end
end

function network_reddownplantout(datatable)
	if objects["reddownplant"][tonumber(datatable[2])] then
		objects["reddownplant"][tonumber(datatable[2])].timer2 = 0
	end
end

function network_downplantout(datatable)
	if objects["downplant"][tonumber(datatable[2])] then
		objects["downplant"][tonumber(datatable[2])].timer2 = 0
	end
end

function getifmainmario(b)
	for i, v in pairs(objects["player"]) do
		if v == b and i ~= 1 then
			return false
		end
	end
	return true
end

function sendobjectshotted(object, name, dir)
	table.insert(networksendqueue, "objectshotted;" .. networkclientnumber .. ";" .. math.floor(object.x) .. ";" .. math.floor(object.y) .. ";" .. dir .. ";" .. name)
end

function convertclienttoplayer(clientnumber)
	--print(clientnumber, networkclientnumber)
	if clientnumber < networkclientnumber then 
		return clientnumber+1
	elseif clientnumber == networkclientnumber then
		return 1
	elseif clientnumber > networkclientnumber then
		return clientnumber
	end
end

function network_sendchat(newstring)
	udp:send("chat;" .. networkclientnumber .. ";" .. newstring)
	local split = newstring:split(":")
	table.insert(chatlog, 1, {id=split[1], message=split[2]})
end

function network_use(datatable)
	if objects["player"][convertclienttoplayer(tonumber(datatable[2]))] then
		objects["player"][convertclienttoplayer(tonumber(datatable[2]))]:use()
	end
end

function network_inflives(datatable)
	infinitelives = (datatable[2] == "1")
	if guielements.livescheckbox then
		guielements.livescheckbox.var = infinitelives
	end
end

function network_boxsync(datatable)
	if objects["box"][tonumber(datatable[4])] then
		objects["box"][tonumber(datatable[4])].x = tonumber(datatable[2])
		objects["box"][tonumber(datatable[4])].y = tonumber(datatable[3])
		if datatable[5] then
			objects["box"][tonumber(datatable[4])]:used(convertclienttoplayer(tonumber(datatable[5])))
		end
	else
		objects["box"][tonumber(datatable[4])] = box:new(tonumber(datatable[2]), tonumber(datatable[3]))
		objects["box"][tonumber(datatable[4])].x = tonumber(datatable[2])
		objects["box"][tonumber(datatable[4])].y = tonumber(datatable[3])
		if datatable[5] then
			objects["box"][tonumber(datatable[4])]:used(convertclienttoplayer(tonumber(datatable[5])))
		end
	end
end


function network_coins(datatable)
	local x, y = tonumber(datatable[2]), tonumber(datatable[3])
	if inmap(x, y) and tilequads[map[x][y][1]].coin then
		collectcoin(x, y)
	end 
end

function network_cheepver(datatable)
	local v = objects["cheep"][tonumber(datatable[3])]
	if v then
		if datatable[2] == "1" then
			v.verticalmoving = true
		end
	end
end



