function server_load()
	local socket = require "socket"
	-- begin
	server_udp = socket.udp()
	server_udp:settimeout(0)
	server_peerlist = {}
	server_udp:setsockname('*', 27020)
	server_startedgame = false
	server_coordsupdatetimer = 0
	server_angletimer = 0

	server_startgametimer = 0
	clientisnetworkhost = true

	server_inflivesvalue = infinitelives
	server_sharingportalsvalue = playersaresharingportals
	server_infinitetime = infinitetime
	server_mappack = mappack

	server_globalmappacklist = mappackname

	lobby_maxplayers = 10
end
local resyncconfig = false
local resynctimer = -5
local server_pingtimer = 0
local timeouttables = {}

function server_update(dt)
	local data, ip, port
	if not server_startedgame then
		data, ip, port = server_udp:receivefrom()
	else
		data = server_udp:receive()
	end
	if server_startedgame then
		for x = 1, #server_peerlist do
			timeouttables[x] = timeouttables[x] + dt
		end
	end


	while data do
		--print(data)
		datatable = data:split(";")
		if datatable[1] == "connect" and ip and port then
			if #server_peerlist < lobby_maxplayers then
				--Send swarm of information to a client that connects
				server_udp:sendto("connected", ip, port)
				print("inserted")
				print(ip)
				table.insert(server_peerlist, {ip=ip, port=port, nick=datatable[2], mushrooms={}, chatmessages={}, cheepvertable={}, boxes={}, coins={}, plants={}, spikethrows={}, bullets={}, enemiestospawn={}, goombas={}, seesaws={}, koopastomps = {}, koopasyncs={}, spawnedfires = {}, castlefires = {}, platforms = {}, squidstates = {}, squids={}, fishspawns={}, upfiresyncs={}, hammers={}, brojumps={}, shottedobjects={}})
				server_udp:sendto("clientnumber;" .. #server_peerlist, ip, port)
				local toggle = "0"
				if server_inflivesvalue then
					toggle = "1"
				end
				server_udp:sendto("inflives;" .. toggle, ip, port)

				local toggle = "0"
				if server_sharingportalsvalue then
					toggle = "1"
				end
				server_udp:sendto("sharetheportals;" .. toggle, ip, port)

				local toggle = "0"
				if server_infinitetime then
					toggle = "1"
				end
				server_udp:sendto("setinfinitetime;" .. toggle, ip, port)

				print(#server_peerlist .. "'s nick is " .. datatable[2])
				print(server_peerlist[1].checkboxvalues)
				if server_peerlist[1].checkboxvalues then
					print("yep", #server_peerlist[1].checkboxvalues)
					for i, v in pairs(server_peerlist[1].checkboxvalues) do
						print("syncing value " .. v .. " as " .. i)
						server_udp:sendto("synccheckboxvalue;" .. v .. ";" .. i, ip, port)
					end
				end
				resyncconfig = true
				return
			else
				server_udp:sendto("reject;full", ip, port)
			end
		elseif data == "nextlevel" then
			finishedlevel = false
			for i, v in pairs(server_peerlist) do
				v.x = 1.5
				v.y = 13
				v.speedx = 0
				v.speedy = 0
			end

			for i, v in pairs(server_peerlist) do
				for j, k in pairs(server_peerlist) do
					if i ~= j then
						sendcoords(v, k, i)
					end
				end
			end
		elseif datatable[1] == "changemappack" then
			server_mappack = datatable[3]
			for x = 2, #server_peerlist do
				server_udp:sendto("changemappack;" .. server_mappack, server_peerlist[x].ip, server_peerlist[x].port)
			end
		end





		local clientnumber = tonumber(datatable[2])
		if not server_peerlist[clientnumber] and not server_startedgame and clientnumber and ip and port then
			--If there's no clientnumber then resend the data
			for i, v in pairs(server_peerlist) do
				for j, k in pairs(v) do
					--print(j, k)
				end
				local ip, port = v.ip, v.port
				server_udp:sendto("clientnumber;" .. i, ip, port)
			end
		elseif not server_peerlist[clientnumber] and server_startedgame and clientnumber then
			if clientnumber > #server_peerlist then
				clientnumber = #server_peerlist
			end
		end

		if _G["server_" .. datatable[1]] and type(_G["server_" .. datatable[1]]) == "function" and clientnumber and server_peerlist[clientnumber] then
			_G["server_" .. datatable[1]](datatable, clientnumber)
		end
		if not server_startedgame then
			data, ip, port = server_udp:receivefrom()
		else
			if clientnumber and server_peerlist[clientnumber] then
				timeouttables[clientnumber] = 0 
			end
			data = server_udp:receive()
		end
	end

	if resynctimer >= 0 then
		resynctimer = resynctimer + dt
		if resynctimer > .4 then
			resynctimer = -5
			resyncconfig = true
		end
	end

	if resyncconfig then
		local hasdata = true
		for i, v in pairs(server_peerlist) do
			if not v.hattable or not v.colortable or not v.portalcolors then
				hasdata = false
				break
			end
		end
		if hasdata then
			print("synced config")
			server_syncconfig()
			resyncconfig = false
		end
	end



	--[[if #server_peerlist > 1 and not server_startedgame then
		server_startgametimer = server_startgametimer + dt
		if server_startgametimer > 1 then
			for i, v in pairs(server_peerlist) do
				server_udp:sendto("startgame", v.ip, v.port)

				for j, k in pairs(server_peerlist) do
					if j ~= i then
						local string = "hats;" .. i 
						for x = 1, #v.hattable do
							string = string .. ";" .. v.hattable[x]
						end
						server_udp:sendto(string, k.ip, k.port)
						if v.colortable then
							local string = "color;" .. i
							for set = 1, 3 do
								for color = 1, 3 do
									string = string .. ";" .. v.colortable[set][color]
								end
							end
							server_udp:sendto(string, k.ip, k.port)
						end
					end
				end
			end
			server_startedgame = true
		end
	end--]]

	if not server_startedgame then
		server_pingtimer = server_pingtimer + dt
		if server_pingtimer > 2 then
			server_syncping()

			server_pingtimer = server_pingtimer - 2
			for x = 2, #server_peerlist do
				server_udp:sendto("pingcheck", server_peerlist[x].ip, server_peerlist[x].port)
				server_peerlist[x].countingping = true
				server_peerlist[x].personalpingtimer = 0
			end
		end
	end

	for x = 2, #server_peerlist do
		if server_peerlist[x].countingping then
			server_peerlist[x].personalpingtimer = server_peerlist[x].personalpingtimer + dt
		end
	end

	if server_resyncmaxplayers then
		server_resyncmaxplayers = false
		for x = 2, #server_peerlist do
			server_udp:sendto("changemax;" .. lobby_maxplayers, server_peerlist[x].ip, server_peerlist[x].port)
		end
	end


	for i, v in pairs(server_peerlist) do
		for j, k in pairs(server_peerlist) do
			if i~= j and i~= "qcode is best" and j ~= "qcode is best" then
				if v.immediatelysyncangle then
					server_udp:sendto("otherpointingangle;" .. i .. ";" .. v.pointingangle, k.ip, k.port)
				end
			end
		end
	end


	server_coordsupdatetimer = server_coordsupdatetimer + dt

	server_angletimer = server_angletimer + dt

	if server_coordsupdatetimer > .03 and server_startedgame and objects then
		server_coordsupdatetimer = server_coordsupdatetimer - .03
		for i, v in pairs(server_peerlist) do
			for j, k in pairs(server_peerlist) do
				--[[if j == 1 and i ~= j then
					server_udp:sendto("synccoords;" .. j .. ";" .. round(objects["player"][1].x, 2) .. ";" .. round(objects["player"][1].y, 2) .. ";" .. round(objects["player"][1].speedx, 2) .. ";" .. round(objects["player"][1].speedy, 2) .. ";" .. round(dt, 4), v.ip, v.port)
				--elseif i ~= j and j ~= 1 and k.x and k.y and k.speedx and k.speedy and k.currentdt then
					--server_udp:sendto("synccoords;" .. j .. ";" .. k.x .. ";" .. k.y .. ";" .. k.speedx .. ";" .. k.speedy .. ";" .. k.currentdt, v.ip, v.port)
				end--]]
			end
		end
	end

	if server_angletimer > .1 and server_startedgame and objects then
		server_angletimer = server_angletimer - .1
		for i, v in pairs(server_peerlist) do
			for j, k in pairs(server_peerlist) do
				--print(i, j)
				if i ~= j and k.pointingangle and j ~= 1 then
					--print(i, j, k.x, k.y)
					server_udp:sendto("otherpointingangle;" .. j .. ";" .. k.pointingangle, v.ip, v.port)
				elseif j == 1 and i ~= j then
					server_udp:sendto("otherpointingangle;" .. j .. ";" .. round(objects["player"][1].pointingangle, 2), v.ip, v.port)
				end
			end
		end
	end

--[[	if server_startedgame then
		for x = 1, #timeouttables do
			if timeouttables[x] > 20 then
				server_clientquit(nil, x)
			end
		end
	end0--]]


	--socket.sleep(0.01)
end

function server_pingback(datatable, clientnumber)
	if server_peerlist[clientnumber].personalpingtimer and not server_startedgame then
		server_peerlist[clientnumber].countingping = false
		server_peerlist[clientnumber].mostrecentping = round(server_peerlist[clientnumber].personalpingtimer*1000)
	end
end

function server_start()
	print("server_start")
	if lobby_currentmappackallowed and #server_peerlist > 1 then
		for i, v in pairs(server_peerlist) do
			server_udp:sendto("startgame;" .. #server_peerlist, v.ip, v.port)
		end
		server_syncconfig()
		server_startedgame = true

		for x = 1, #server_peerlist do
			timeouttables[x] = 0
		end
	end
end

function server_shutserver()
	for x = 2, #server_peerlist do
		server_udp:sendto("quit", server_peerlist[x].ip, server_peerlist[x].port)
	end

	--udp:close()
	clientisnetworkhost = false
	--server_udp:close()
	onlinemp = false
end

function server_clientquit(datatable, clientnumber)
	print(clientnumber)
	if server_peerlist[clientnumber].nick then
		print("client " .. server_peerlist[clientnumber].nick  .. " is quitting")
	else
		print("client " .. clientnumber .. " is quitting")
	end
	for x = 1, #server_peerlist do
		server_udp:sendto("clientnumber;" .. x, server_peerlist[x].ip, server_peerlist[x].port)
		server_udp:sendto("removepeer;" .. clientnumber, server_peerlist[x].ip, server_peerlist[x].port)
	end
	local playertoremove = clientnumber
	table.remove(server_peerlist, clientnumber)
	resyncconfig = true

	if server_startedgame and #server_peerlist < 2 then
		network_quit()
		notice.new("all players left", notice.red, 6)
	end
end

function server_syncconfig()
	for i, v in pairs(server_peerlist) do
		for j, k in pairs(server_peerlist) do
			if j ~= i then
				if v.hattable then
					local string = "hats;" .. i 
					for x = 1, #v.hattable do
						string = string .. ";" .. v.hattable[x]
					end
					server_udp:sendto(string, k.ip, k.port)
				end
				if v.colortable then
					local string = "color;" .. i
					for set = 1, 3 do
						for color = 1, 3 do
							string = string .. ";" .. v.colortable[set][color]
						end
					end
					server_udp:sendto(string, k.ip, k.port)
				end
				if v.nick then

					server_udp:sendto("nick;" .. i .. ";" .. v.nick, k.ip, k.port)
				end

				if v.portalcolors then
					print("sending " .. i .. "'s portalcolors")
					local string = "portalcolor;" .. i
					for set = 1, 2 do
						for value = 1, 3 do
							string = string .. ";" .. v.portalcolors[set][value]
						end
					end
					server_udp:sendto(string, k.ip, k.port)
				end
			end
		end
	end

	local stringtosend = "globalmappacks"

	for x = 1, #server_globalmappacklist do
		stringtosend = stringtosend .. ";" .. server_globalmappacklist[x]
	end

	server_udp:sendto("globalmappacks;" .. stringtosend, server_peerlist[1].ip, server_peerlist[1].port)

	for x = 2, #server_peerlist do
		server_udp:sendto("changemappack;" .. server_mappack, server_peerlist[x].ip, server_peerlist[x].port)
	end

	for x = 2, #server_peerlist do
		server_udp:sendto("changemax;" .. lobby_maxplayers, server_peerlist[x].ip, server_peerlist[x].port)
	end
end

function server_syncping()
	for i, v in pairs(server_peerlist) do
		for j, k in pairs(server_peerlist) do
			if v.mostrecentping and k.ip and k.port then
				server_udp:sendto("pingupdate;" .. i .. ";" .. v.mostrecentping, k.ip, k.port)
			end
		end
	end
end

function server_hats(datatable, clientnumber)
	print("received " .. clientnumber .. "'s hats")
	server_peerlist[clientnumber].hattable = {}
	for x = 3, #datatable do 
		table.insert(server_peerlist[tonumber(datatable[2])].hattable, datatable[x])
	end
end

function server_color(datatable, clientnumber)
	print("received " .. clientnumber .. "'s colors")
	server_peerlist[clientnumber].colortable = {{datatable[3], datatable[4], datatable[5]}, {datatable[6], datatable[7], datatable[8]}, {datatable[9], datatable[10], datatable[11]} }
end

function server_portalcolor(datatable, clientnumber)
	print("server got " .. clientnumber .. "'s portal colors")
	server_peerlist[clientnumber].portalcolors = {}
	server_peerlist[clientnumber].portalcolors[1] = {datatable[3], datatable[4], datatable[5]}
	server_peerlist[clientnumber].portalcolors[2] = {datatable[6], datatable[7], datatable[8]}
end

function server_mappacklist(datatable, clientnumber)
	server_peerlist[clientnumber].mappacktable = {}
	for x = 3, #datatable do
		table.insert(server_peerlist[clientnumber].mappacktable, {mappack=datatable[x]})
	end

	for x = 1, #server_peerlist do
		if server_peerlist[x].mappacktable then
			for y = 1, #server_peerlist[x].mappacktable do
				server_peerlist[x].mappacktable[y].matchedwith = 1
			end
		end
	end



	local v = server_peerlist[1]
	print("there are " .. #server_peerlist .. " peers")
	if #server_peerlist > 1 then
		server_globalmappacklist = {}
		for j, k in pairs(server_peerlist) do
			if j ~= 1 then
				for x = 1, #v.mappacktable do
					if k.mappacktable then
						for y = 1, #k.mappacktable do
							if v.mappacktable[x].mappack == k.mappacktable[y].mappack then
								v.mappacktable[x].matchedwith = v.mappacktable[x].matchedwith + 1
							end
						end
					end
				end
			end
		end
	else
		server_globalmappacklist = mappackname
		server_mappack = mappackname[lobby_mappackselectionnumber]
	end


	for x = 1, #v.mappacktable do
		if v.mappacktable[x].matchedwith == #server_peerlist then
			print(v.mappacktable[x].matchedwith, v.mappacktable[x].mappack)
			table.insert(server_globalmappacklist, v.mappacktable[x].mappack)
		end
	end
end

function server_move(datatable, clientnumber)
	--[[server_peerlist[clientnumber].x = datatable[3]
	server_peerlist[clientnumber].y = datatable[4]
	server_peerlist[clientnumber].speedx = datatable[5]
	server_peerlist[clientnumber].speedy = datatable[6]
	server_peerlist[clientnumber].currentdt = datatable[7]--]]
	local sendstring = "synccoords;" .. clientnumber .. ";" .. datatable[3] .. ";" .. datatable[4] .. ";" .. datatable[5] .. ";" .. datatable[6] .. ";" .. datatable[7]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_portal(datatable, clientnumber)
	--[[server_peerlist[clientnumber].portali = datatable[3]
	server_peerlist[clientnumber].portalcox = datatable[4]
	server_peerlist[clientnumber].portalcoy = datatable[5]
	server_peerlist[clientnumber].portalside = datatable[6]
	server_peerlist[clientnumber].portaltendency = datatable[7]
	server_peerlist[clientnumber].portalx = datatable[8]
	server_peerlist[clientnumber].portaly = datatable[9]
	server_peerlist[clientnumber].portalnewx = datatable[10]
	server_peerlist[clientnumber].portalnewy = datatable[11]
	server_peerlist[clientnumber].placenewportal = true--]]

	local sendstring = "portal;" .. clientnumber .. ";" .. datatable[3] .. ";" .. datatable[4] .. ";" .. datatable[5] .. ";" .. datatable[6] .. ";" .. datatable[7] .. ";" .. datatable[8] .. ";" .. datatable[9] .. ";" .. datatable[10] .. ";" .. datatable[11]
	server_sendtootherpeers(sendstring, clientnumber)


end

function server_shoot(datatable, clientnumber)
	--[[server_peerlist[clientnumber].shooti = datatable[3]
	server_peerlist[clientnumber].shootx = datatable[4]
	server_peerlist[clientnumber].shooty = datatable[5]
	server_peerlist[clientnumber].shootdirection = datatable[6]
	server_peerlist[clientnumber].shootnewportal = true--]]
	local sendstring = "shoot;" .. clientnumber .. ";" .. datatable[3] .. ";" .. datatable[4] .. ";" .. datatable[5] .. ";" .. datatable[6]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_hitblock(datatable, clientnumber)
--[[
	server_peerlist[clientnumber].hitblockx = datatable[3]
	server_peerlist[clientnumber].hitblocky = datatable[4]

	server_peerlist[clientnumber].hitnewblock = true--]]
	local sendstring = "hitblock;" .. clientnumber .. ";" .. datatable[3] .. ";" .. datatable[4]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_death(datatable, clientnumber)

	--[[server_peerlist[clientnumber].diedhow = datatable[3]
	server_peerlist[clientnumber].justdied = true--]]

	local sendstring = "death;" .. clientnumber .. ";" .. datatable[3]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_powerup(datatable, clientnumber)
	--[[server_peerlist[clientnumber].newmushroomx = datatable[3]
	server_peerlist[clientnumber].newmushroomy = datatable[4]
	--Nil for mushroom or flower, star for star
	server_peerlist[clientnumber].powerupname = datatable[5]
	server_peerlist[clientnumber].mariogrow = true--]]

	local sendstring = "powerup;" .. clientnumber .. ";" .. datatable[3].. ";" .. datatable[4]
	if datatable[5] then
		sendstring = sendstring .. ";" .. datatable[5]
	end

	server_sendtootherpeers(sendstring, clientnumber)

end

function server_1up(datatable, clientnumber)
	--[[server_peerlist[clientnumber].newmariolives = {}
	for x = 1, #server_peerlist do
		--print("yep " .. x)
		server_peerlist[clientnumber].newmariolives[x] = datatable[x+2]
	end
			--print(data)
	server_peerlist[clientnumber].newoneupx = datatable[#server_peerlist+3]
	server_peerlist[clientnumber].newoneupy = datatable[#server_peerlist+4]
	server_peerlist[clientnumber].synclives = true--]]

	local sendstring = "lives;"
	for x = 1, #server_peerlist do
		sendstring = sendstring .. datatable[x+2] .. ";"
	end
	sendstring = sendstring .. datatable[#server_peerlist+3] .. ";" .. datatable[#server_peerlist+4]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_poisonmushed(datatable, clientnumber)
	local sendstring = "poisonmushed;" .. clientnumber .. ";" .. datatable[3].. ";" .. datatable[4]
	if datatable[5] then
		sendstring = sendstring .. ";" .. datatable[5]
	end
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_pointingangle(datatable, clientnumber)
	server_peerlist[clientnumber].pointingangle = datatable[3]
	if datatable[4] == "now" then
		server_peerlist[clientnumber].immediatelysyncangle = true
	end
end

function server_goombakill(datatable, clientnumber)
	--[[
	server_peerlist[clientnumber].newgoombakill = true
	server_peerlist[clientnumber].newgoombax = datatable[3]
	server_peerlist[clientnumber].newgoombay = datatable[4]
	server_peerlist[clientnumber].goombakilltype = datatable[5]--]]

	local sendstring = "goombakill;" .. clientnumber .. ";" .. datatable[3] .. ";" .. datatable[4] .. ";" .. datatable[5]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_jump(datatable, clientnumber)
	--server_peerlist[clientnumber].newjump = true

	local sendstring = "jump;" .. clientnumber
	server_sendtootherpeers(sendstring, clientnumber)

end

function server_reload(datatable, clientnumber)
	--server_peerlist[clientnumber].newreload = true
	local sendstring = "reloadportals;" .. clientnumber
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_fireball(datatable, clientnumber)
	--[[server_peerlist[clientnumber].newfire = true
	server_peerlist[clientnumber].newfireballx = datatable[3]
	server_peerlist[clientnumber].newfirebally = datatable[4]
	server_peerlist[clientnumber].newfireballdir = datatable[5]--]]

	local sendstring = "fireball;" .. clientnumber .. ";" .. datatable[3] .. ";" .. datatable[4] .. ";" .. datatable[5]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_koopastomp(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].koopastomps, {x=datatable[3], y=datatable[4], hitx=datatable[5]})

	local sendstring = "koopastomp;" .. clientnumber .. ";" .. datatable[3] .. ";" .. datatable[4]
	if datatable[5] then
		sendstring = sendstring .. ";" .. datatable[5]
	end
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_spawnenemy(datatable, clientnumber)
	--[[if not server_peerlist[clientnumber].enemiestospawn then
		server_peerlist[clientnumber].enemiestospawn = {}
	end
	--print(data)
	table.insert(server_peerlist[clientnumber].enemiestospawn, {x=datatable[3], y=datatable[4]})--]]
	local sendstring = "spawnenemy;" .. datatable[3] .. ";" .. datatable[4]
	server_sendtootherpeers(sendstring, clientnumber)
	--print(server_peerlist[clientnumber].enemiestospawn[#server_peerlist[clientnumber].enemiestospawn].x, server_peerlist[clientnumber].enemiestospawn[#server_peerlist[clientnumber].enemiestospawn].y)
end

function server_duck(datatable, clientnumber)
	--[[server_peerlist[clientnumber].syncduck = true
	server_peerlist[clientnumber].duckstate = datatable[3]--]]

	local sendstring = "duck;" .. clientnumber .. ";" .. datatable[3]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_pipe(datatable, clientnumber)
	--[[server_peerlist[clientnumber].pipex = datatable[3]
	server_peerlist[clientnumber].pipey = datatable[4]
	server_peerlist[clientnumber].pipedir = datatable[5]
	server_peerlist[clientnumber].pipei = datatable[6]
	server_peerlist[clientnumber].newpipe = true--]]

	local sendstring = "pipe;" .. clientnumber .. ";" .. datatable[3] .. ";" .. datatable[4] .. ";" .. datatable[5] .. ";" .. datatable[6]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_goombasync(datatable, clientnumber)
	--[[if not server_peerlist[clientnumber].goombas then
		server_peerlist[clientnumber].goombas = {}
	end
	table.insert(server_peerlist[clientnumber].goombas, {x=datatable[3], y=datatable[4], speedx=datatable[5], tablelocation=datatable[6]})
	if finishedlevel then
		server_peerlist[clientnumber].goombas = {}
	end
--]]
	if not finishedlevel then
		local sendstring = "goombasync;" .. datatable[3] .. ";" .. datatable[4] .. ";" .. datatable[5] .. ";" .. datatable[6]
		server_sendtootherpeers(sendstring, clientnumber)
	end
end

function server_chat(datatable, clientnumber)
	--[[if not server_peerlist[clientnumber].chatmessages then
		server_peerlist[clientnumber].chatmessages = {}
	end
	table.insert(server_peerlist[clientnumber].chatmessages, datatable[3])--]]

	local sendstring = "chat;" .. datatable[3]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_finish(datatable, clientnumber)	
	--server_peerlist[clientnumber].grabbedflag = true
	finishedlevel = true
	--[[server_peerlist[clientnumber].mariotime = datatable[3]
	server_peerlist[clientnumber].finishleveltype = datatable[4]--]]

	local sendstring = "finish;" .. clientnumber .. ";" .. datatable[3] .. ";" .. datatable[4]
	server_sendtootherpeers(sendstring, clientnumber)

end

function server_firespawn(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].spawnedfires, {x=datatable[3], y=datatable[4], targety=datatable[5]})
	local sendstring = "firespawn;" .. datatable[3] .. ";" .. datatable[4] .. ";" .. datatable[5]
end

function server_bowsersync(datatable, clientnumber)
	--[[server_peerlist[clientnumber].syncbowser = true
	server_peerlist[clientnumber].bowserx = datatable[3]
	server_peerlist[clientnumber].bowsery = datatable[4]
	server_peerlist[clientnumber].bowsertargetx = datatable[5]
	server_peerlist[clientnumber].bowserspeedy = datatable[6]--]]
	local sendstring = "bowsersync;" .. datatable[3] .. ";" .. datatable[4] .. ";" .. datatable[5] .. ";" .. datatable[6]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_bowserjump(datatable, clientnumber)
	--[[server_peerlist[clientnumber].bowserjump = true
	server_peerlist[clientnumber].bowserspeedy = datatable[3]--]]

	local sendstring = "bowserjump;" .. datatable[3]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_cfiresync(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].castlefires, {angle=datatable[3], i=datatable[4]})
	local sendstring = "cfiresync;" .. datatable[3] .. ":" .. datatable[4]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_pformsync(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].platforms, {timer=datatable[3], i=datatable[4], name=datatable[5]})
	--server_peerlist[clientnumber].platforms[#server_peerlist[clientnumber].platforms].name = datatable[5] or "timer"
	local sendstring = "pformsync;" ..datatable[3] .. ";" .. datatable[4] .. ";" .. (datatable[5] or "timer")
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_createpform(datatable, clientnumber)
--	table.insert(server_peerlist[clientnumber].platforms, {x=datatable[3], y=datatable[4], dir=datatable[5], size=datatable[6]})
	local sendstring = "createpform;" .. datatable[3] .. ";" .. datatable[4] .. ";" .. datatable[5] .. ";" .. datatable[6]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_squidstate(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].squidstates, {i = datatable[3], state=datatable[4], dir=datatable[5], target=datatable[6]})
	local sendstring = "squidstate;" .. datatable[3] .. ";" .. datatable[4]
	if datatable[5] then
		sendstring = sendstring .. ";" .. datatable[5]
	end
	if datatable[6] then
		sendstring = sendstring .. ";" .. datatable[6]
	end
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_squidsync(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].squids, {x=datatable[3], y=datatable[4], player=datatable[5], i=datatable[6]})
	local sendstring = "squidsync;" .. datatable[3] .. ";" .. datatable[4] .. ";" .. datatable[5] .. ";" .. datatable[6]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_fishspawn(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].fishspawns, {x=datatable[3], speedx=datatable[4]})
	local sendstring = "fishspawn;" .. datatable[3] .. ";" .. datatable[4]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_upfireup(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].upfiresyncs, {object=datatable[3]})
	local sendstring = "upfireup;" .. datatable[3]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_hammer(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].hammers, {x=datatable[3], y=datatable[4], dir=datatable[5]})
	local sendstring = "hammer;" .. datatable[3] .. ";" .. datatable[4] .. ";" .. datatable[5]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_brojump(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].brojumps, {dir=datatable[3], objectnumber=datatable[4]})
	local sendstring = "brojump;" .. datatable[3] .. ";" .. datatable[4]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_objectshotted(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].shottedobjects, {x=datatable[3], y=datatable[4], dir=datatable[5], name=datatable[6]})
	local sendstring = "objectshotted;" .. datatable[3] .. ";" .. datatable[4] .. ";" .. datatable[5] .. ";" .. datatable[6]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_koopasync(datatable, clientnumber)
	--[[table.insert(server_peerlist[clientnumber].koopasyncs, {x=datatable[3], y=datatable[4], speedx=datatable[5], size=datatable[6], i=datatable[7]})
	if finishedlevel then
		server_peerlist[clientnumber].koopasyncs = {}
	end--]]
	if not finishedlevel then
		local sendstring = "koopasync;" .. datatable[3] .. ";" .. datatable[4] .. ";" .. datatable[5] .. ";" .. datatable[6] .. ";" .. datatable[7]
		server_sendtootherpeers(sendstring, clientnumber)
	end
end

function server_seesaw(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].seesaws, {y=datatable[3], i=datatable[4]})
	local sendstring = "seesaw;" .. datatable[3] .. ";" .. datatable[4]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_spikethrow(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].spikethrows, {x=datatable[3], y=datatable[4]})
	local sendstring = "spikespawn;" .. datatable[3] .. ";" .. datatable[4]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_spiketurn(datatable, clientnumber)
	--[[server_peerlist[clientnumber].newspiketurn = true
	server_peerlist[clientnumber].newspiketurnobject = datatable[3]--]]
	local sendstring = "spiketurn;" .. datatable[3]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_mazevar(datatable, clientnumber)
	--[[server_peerlist[clientnumber].newmazevar = true
	server_peerlist[clientnumber].newmazevarnumber = datatable[3]--]]
	local sendstring = "mazevar;" .. datatable[3]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_bullet(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].bullets, {x=datatable[3], y=datatable[4], dir=datatable[5]})
	local sendstring = "bulletspawn;" .. datatable[3] .. ";" .. datatable[4] .. ";" .. datatable[5]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_plantout(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].plants, {id=datatable[3]})
	local sendstring = "plantout;" .. datatable[3]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_redplantout(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].plants, {id=datatable[3]})
	local sendstring = "redplantout;" .. datatable[3]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_reddownplantout(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].plants, {id=datatable[3]})
	local sendstring = "reddownplantout;" .. datatable[3]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_downplantout(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].plants, {id=datatable[3]})
	local sendstring = "downplantout;" .. datatable[3]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_inflives(datatable)
	server_inflivesvalue = (datatable[3] == "1")
	for i, v in pairs(server_peerlist) do
		if i ~= 1 then
			server_udp:sendto("inflives;" .. datatable[3], v.ip, v.port)
		end
	end
end

function server_sharingportals(datatable)
	server_sharingportalsvalue = (datatable[3] == "1")
	for i, v in pairs(server_peerlist) do
		if i ~= 1 then
			server_udp:sendto("sharetheportals;" .. datatable[3], v.ip, v.port)
		end
	end
end

function server_infinitetimefunction(datatable)
	server_infinitetime = (datatable[3] == "1")
	for i, v in pairs(server_peerlist) do
		if i ~= 1 then
			server_udp:sendto("setinfinitetime;" .. datatable[3], v.ip, v.port)
		end
	end
end

function server_checkboxvaluechange(datatable, clientnumber)
	if not server_peerlist[clientnumber].checkboxvalues then
		server_peerlist[clientnumber].checkboxvalues = {}
	end
	server_peerlist[clientnumber].checkboxvalues[datatable[4]] = datatable[3]

	for i, v in pairs(server_peerlist) do
		if i ~= 1 then
			server_udp:sendto("synccheckboxvalue;" .. datatable[3] .. ";" .. datatable[4], v.ip, v.port)
		end
	end
end

function server_use(datatable, clientnumber)
	--server_peerlist[clientnumber].newuse = true
	local sendstring = "use;" .. clientnumber
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_boxsync(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].boxes, {x=datatable[3], y=datatable[4], id=datatable[5], parentnumber=datatable[6]})
	local sendstring = "boxsync;" .. datatable[3] .. ";" .. datatable[4] .. ";" .. datatable[5]
	if datatable[6] then
		sendstring = sendstring .. ";" .. datatable[6]
	end
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_coin(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].coins, {x=datatable[3], y=datatable[4]})
	local sendstring = "coins;" .. datatable[3] .. ";" .. datatable[4]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_mushroomsync(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].mushrooms, {x=datatable[3], y=datatable[4], speedx=datatable[5], id=datatable[6]})
	local sendstring = "mushroomsync;" .. datatable[3] .. ";" .. datatable[4] .. ";" .. datatable[5] .. ";" .. datatable[6]
	server_sendtootherpeers(sendstring, clientnumber)
end

function server_cheepver(datatable, clientnumber)
	--table.insert(server_peerlist[clientnumber].cheepvertable, {move=datatable[3], id=datatable[4]})
	local sendstring = "cheepver;" .. datatable[3] .. ";" .. datatable[4]
	server_sendtootherpeers(sendstring, clientnumber)
end

function sendcoords(v, k, i)
	if v.x and v.y and v.speedx and v.speedy and v.currentdt then
		server_udp:sendto("synccoords;" .. i .. ";" .. v.x .. ";" .. v.y .. ";" .. v.speedx .. ";" .. v.speedy .. ";" .. v.currentdt, k.ip, k.port)
	end
end

function server_endgame()
	for x = 2, #server_peerlist do
		server_udp:sendto("endgame", server_peerlist[x].ip, server_peerlist[x].port)
	end
	resynctimer = 0
end

function server_sendtootherpeers(string, clientnumber)--10/10 most useful function
	if clientnumber ~= 1 then
		local split = string:split(";")
		if _G["network_" .. split[1]] then
			_G["network_" .. split[1]](split)
		end
	end
	for x = 2, #server_peerlist do 
		if x ~= clientnumber then
			server_udp:sendto(string, server_peerlist[x].ip, server_peerlist[x].port)
		end
	end
end





