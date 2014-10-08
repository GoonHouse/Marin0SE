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
	net.assign("server")
end
local resyncconfig = false
local resynctimer = -5
local server_pingtimer = 0
local timeouttables = {}

function server_send(chan, data)
	if chan~="synccoords" and chan~="otherpointingangle" then
		print("SERVER-S: "..chan.." -- sending")
	end
	server_udp:send(von.serialize({chan=chan,data=data,client=networkclientnumber}))
end

function server_sendto(chan, data, ip, port)
	if chan~="synccoords" and chan~="otherpointingangle" then
		print("SERVER-S: "..chan.." -- sending to "..ip..":"..port)
	end
	server_udp:sendto(von.serialize({chan=chan,data=data,client=networkclientnumber}), ip, port)
end

function server_receive()
	local raw, msg = server_udp:receive()
	if raw==nil then return nil, nil end
	raw = von.deserialize(raw)
	--@TODO: use the ip and port to bind to a particular address
	return raw.chan, raw.data
end

function server_receivefrom()
	local raw
	raw, ip, port = server_udp:receivefrom()
	--@TODO: In the odd circumstance we are sent no data from somebody?
	if raw==nil then return false end
	raw = von.deserialize(raw)
	raw.data.rip = ip
	raw.data.rport = port
	--@TODO: use the ip and port to bind to a particular address
	return raw.chan, raw.data
end

function server_sendtootherpeers(chan, data, clientnumber)--10/10 most useful function
	if clientnumber ~= 1 then
		if _G["client_callback_" .. chan] then
			_G["client_callback_" .. chan](data)
		end
	end
	for x = 2, #server_peerlist do 
		if x ~= clientnumber then
			server_sendto(chan, data, server_peerlist[x].ip, server_peerlist[x].port)
		end
	end
end

function server_update(dt)
	local chan, data = server_receivefrom()
	while chan and data do
		if chan~="synccoords" and chan~="otherpointingangle" then
			print("SERVER-U: "..chan.." -- doing") 
		end
		_G["server_callback_" .. chan](data)
		chan, data = server_receivefrom()
	end
	
	if not server_startedgame then
		server_pingtimer = server_pingtimer + dt
		if server_pingtimer > 2 then
			for i, v in pairs(server_peerlist) do
				for j, k in pairs(server_peerlist) do
					if v.mostrecentping and k.ip and k.port then
						server_sendto("pingupdate", {id=i,ping=v.mostrecentping}, k.ip, k.port)
					end
				end
			end

			server_pingtimer = server_pingtimer - 2
			for x = 2, #server_peerlist do
				server_sendto("pingcheck", nil, server_peerlist[x].ip, server_peerlist[x].port)
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
			server_sendto("changemax", {lobby_maxplayers}, server_peerlist[x].ip, server_peerlist[x].port)
		end
	end
	
	server_coordsupdatetimer = server_coordsupdatetimer + dt

	server_angletimer = server_angletimer + dt

	if server_coordsupdatetimer > .03 and server_startedgame and objects then
		server_coordsupdatetimer = server_coordsupdatetimer - .03
		for i, v in pairs(server_peerlist) do
			for j, k in pairs(server_peerlist) do
				if j == 1 and i ~= j then
					server_sendto("synccoords", {
						id=j,
						x=objects["player"][1].x,
						y=objects["player"][1].y,
						speedx=objects["player"][1].speedx,
						speedy=objects["player"][1].speedy,
						dt=dt
					}, v.ip, v.port)
				elseif i ~= j and j ~= 1 and k.x and k.y and k.speedx and k.speedy and k.currentdt then
					server_sendto("synccoords", {
						id=j,
						x=k.x,
						y=k.y,
						speedx=k.speedx,
						speedy=k.speedy,
						dt=k.currentdt
					}, v.ip, v.port)
				end
			end
		end
	end

	if server_angletimer > .1 and server_startedgame and objects then
		server_angletimer = server_angletimer - .1
		for i, v in pairs(server_peerlist) do
			for j, k in pairs(server_peerlist) do
				if i ~= j and k.pointingangle and j ~= 1 then
					server_sendto("otherpointingangle", {id=j,pointingangle=k.pointingangle}, v.ip, v.port)
				elseif j == 1 and i ~= j then
					server_sendto("otherpointingangle", {id=j,pointingangle=objects["player"][1].pointingangle}, v.ip, v.port)
				end
			end
		end
	end
	
	if server_startedgame then
		for x = 1, #timeouttables do
			if timeouttables[x] > 20 then
				server_clientquit(nil, x)
			end
		end
	end
end
function server_update2(dt)
	if true then
		if chan == "changemappack" then
			server_mappack = data.mappack
			for x = 2, #server_peerlist do
				server_sendto("changemappack", {mappack=server_mappack}, server_peerlist[x].ip, server_peerlist[x].port)
			end
		end

		local clientnumber = tonumber(data.clientid)
		if not server_peerlist[clientnumber] and not server_startedgame and clientnumber and ip and port then
			--If there's no clientnumber then resend the data
			for i, v in pairs(server_peerlist) do
				server_sendto("clientnumber", {id=i}, v.ip, v.port)
			end
		elseif not server_peerlist[clientnumber] and server_startedgame and clientnumber then
			if clientnumber > #server_peerlist then
				clientnumber = #server_peerlist
			end
		end

		_G["server_" .. chan](clientnumber, data)
		
		if not server_startedgame then
			chan, data, ip, port = server_receivefrom()
		else
			if clientnumber and server_peerlist[clientnumber] then
				timeouttables[clientnumber] = 0 
			end
			chan, data = server_receive()
		end
	end

	if resynctimer >= 0 then
		resynctimer = resynctimer + dt
		if resynctimer > .4 then
			resynctimer = -5
			resyncconfig = true
		end
	end

	--[[if resyncconfig then
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
	end]]


	--[[for i, v in pairs(server_peerlist) do
		for j, k in pairs(server_peerlist) do
			if i~= j and i~= "qcode is best" and j ~= "qcode is best" then
				if v.immediatelysyncangle then
					server_udp:sendto("otherpointingangle;" .. i .. ";" .. v.pointingangle, k.ip, k.port)
				end
			end
		end
	end]]


	


	--socket.sleep(0.01)
end


function server_start()
	print("server_start")
	if server_startedgame then
		for x = 1, #server_peerlist do
			timeouttables[x] = timeouttables[x] + dt
		end
	end
	
	if lobby_currentmappackallowed and #server_peerlist > 1 then
		for i, v in pairs(server_peerlist) do
			server_sendto("startgame", {numplayers=#server_peerlist}, v.ip, v.port)
		end
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

-- GREAT BIG LIST OF CALLBACKS
function server_callback_connect(data)
	if #server_peerlist < lobby_maxplayers then
		--Send swarm of information to a client that connects
		print("inserting "..ip)
		--@TODO: We need to *not* have this prebuilt entities table.
		table.insert(server_peerlist, {ip=ip, port=port, nick=data.nick, mushrooms={}, chatmessages={}, cheepvertable={}, boxes={}, coins={}, plants={}, spikethrows={}, bullets={}, enemiestospawn={}, goombas={}, seesaws={}, koopastomps = {}, koopasyncs={}, spawnedfires = {}, castlefires = {}, platforms = {}, squidstates = {}, squids={}, fishspawns={}, upfiresyncs={}, hammers={}, brojumps={}, shottedobjects={}})
		local connecttable = {
			clientid = #server_peerlist,
			inflives = server_inflivesvalue,
			sharingportals = server_sharingportalsvalue,
			infinitetime = server_infinitetime,
			checkboxes = {}
		}
		if server_peerlist[1].checkboxvalues then
			print("yep", #server_peerlist[1].checkboxvalues)
			for k, v in pairs(server_peerlist[1].checkboxvalues) do
				connecttable.checkboxes[k]=v
			end
		end
		resyncconfig = true
		server_sendto("connected", connecttable, data.rip, data.rport)
		hook.Call("ServerClientConnected", #server_peerlist, data.rip, data.rport)
		return
	else
		server_sendto("rejected", {reason="full"}, data.rip, data.rport)
	end
end
function server_callback_nextlevel(data)
	finishedlevel = false
	for _, v in pairs(server_peerlist) do
		v.x = 1.5
		v.y = 13
		v.speedx = 0
		v.speedy = 0
	end
	--@DEV: we'll leave this alone for right now
	for i, v in pairs(server_peerlist) do
		for j, k in pairs(server_peerlist) do
			if i ~= j then
				if v.x and v.y and v.speedx and v.speedy and v.currentdt then
					server_sendto("synccoords", {id=i, x=v.x, y=v.y, speedx=v.speedx, speedy=v.speedy, v.currentdt}, k.ip, k.port)
				end
			end
		end
	end
end
