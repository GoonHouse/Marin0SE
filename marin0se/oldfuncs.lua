function server_syncping()
	for i, v in pairs(server_peerlist) do
		for j, k in pairs(server_peerlist) do
			if v.mostrecentping and k.ip and k.port then
				server_udp:sendto("pingupdate;" .. i .. ";" .. v.mostrecentping, k.ip, k.port)
			end
		end
	end
end
function server_syncconfig()
	for i, v in pairs(server_peerlist) do
		for j, k in pairs(server_peerlist) do
			if j ~= i then
				if v.hattable then
					server_sendto("hats", {tbl=v.hattable}, k.ip, k.port)
				end
				if v.colortable then
					server_sendto("color", {tbl=v.colortable}, k.ip, k.port)
				end
				if v.nick then
					server_sendto("nick", {nick=v.nick,id=i}, k.ip, k.port)
				end

				if v.portalcolors then
					server_sendto("portalcolor", {tbl=v.portalcolors}, k.ip, k.port)
				end
			end
		end
	end

	server_sendto("globalmappacks",
		{tbl=server_globalmappacklist},
		server_peerlist[1].ip,
		server_peerlist[1].port)

	for x = 2, #server_peerlist do
		server_sendto("changemappack", {mappack=server_mappack}, server_peerlist[x].ip, server_peerlist[x].port)
	end

	for x = 2, #server_peerlist do
		server_sendto("changemax", {max=lobby_maxplayers}, server_peerlist[x].ip, server_peerlist[x].port)
	end
end





-- callbacks
function server_pingback(datatable, clientnumber)
	if server_peerlist[clientnumber].personalpingtimer and not server_startedgame then
		server_peerlist[clientnumber].countingping = false
		server_peerlist[clientnumber].mostrecentping = round(server_peerlist[clientnumber].personalpingtimer*1000)
	end
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




function network_sendchat(data)
	client_send("chat", {message=data.newstring})
	table.insert(chatlog, 1, {id=data.id, message=data.message})
end



