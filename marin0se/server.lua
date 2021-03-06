--[[ NORMALIZATION:
	clientid == the id of the client according to lube
	playerid == the id of a player in the server_peerlist
]]

server_sendhistory = {}
server_recvhistory = {}

function server_load()
	local socket = require "socket"
	-- begin
	local port = 27020
	server = lube.udpServer()
	server:setPing(true, 0.1, "pingu")
	server.callbacks.recv = server_recv
	server.callbacks.connect = server_connect
	server.callbacks.disconnect = server_disconnect
	print("[LUBE|server] starting...")
	server:listen(tonumber(port))
	game.isServer = true
	print("[LUBE|server] listening on port " .. port)

	server_startedgame = false
	server_coordsupdatetimer = 0
	server_angletimer = 0
	server_peerlist = {}

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
server_coordsupdatedelta = .05
server_clientidlookup = {}

function server_send(cmd, pl, targets)
	local digest = Tserial.pack({cmd=cmd,pl=pl})
	if type(targets)=="number" then
		targets={targets}
	elseif targets==nil then
		targets={}
		for i=1,#server_peerlist do
			table.insert(targets, i)
		end
	end
	--print("DEBUG: "..cmd.." & "..von.serialize(pl).." & "..von.serialize(players))
	for k,v in pairs(targets) do
		if server_sendhistory[server_peerlist[v].clientid]==nil then
			server_sendhistory[server_peerlist[v].clientid]={}
		end
		if server_sendhistory[server_peerlist[v].clientid][cmd]~=digest or bypassdupecheck then
			server_sendhistory[server_peerlist[v].clientid][cmd] = digest
			if v~=1 --[[networkclientnumber]] then
				--if chan~="synccoords" and chan~="otherpointingangle" then
				--[[print("DEBUG: k "..tostring(k))
				print("DEBUG: v "..tostring(v))
				print("DEBUG: cmd "..cmd)
				print("DEBUG: server_peerlist "..von.serialize(server_peerlist))]]
				if server_peerlist[v]==nil then print("INVISIBLE PEER?!") end
				--[[print("DEBUG: server_peerlist[v] "..von.serialize(server_peerlist[v]))
				print("DEBUG: server_peerlist[v].nick "..server_peerlist[v].nick)
				print("DEBUG: server_peerlist[v].clientid "..server_peerlist[v].clientid)]]
				--print("[LUBE|server] Sending command '"..cmd.."' to "..server_peerlist[v].nick.."("..server_peerlist[v].clientid.."|"..v..")")
				--end
				server:send(digest, server_peerlist[v].clientid)
			else
				print("[LUBE|server] Running broadcasted command '"..cmd.."' on self.")
				if _G["client_callback_" .. cmd] then
					_G["client_callback_" .. cmd](pl)
				end
			end
		--else
			--print("SERVER-WARNING-SENDDUPE")
		end
	end
end

function server_connect(clientid)
  print("[LUBE|server] Client " .. clientid .. " connected!")
end

function server_disconnect(clientid)
  print("[LUBE|server] Client " .. clientid .. " disconnected!")
end
function server_getpidfromcid(clientid)
	return server_clientidlookup[clientid]
end
function server_recv(rdata, clientid)
	local data = Tserial.unpack(rdata, true)
	data.pl.clientid = clientid
	data.pl.playerid = server_getpidfromcid(clientid)
	if data.pl.playerid == nil then
		print("WARNING: playerid in inbound message '"..data.cmd.."' was nil.")
	end
	if server_recvhistory[clientid]==nil then
		server_recvhistory[clientid]={}
	end
	if server_recvhistory[clientid][data.cmd]~=rdata or bypassdupecheck then
		server_recvhistory[clientid][data.cmd] = rdata
		print("[LUBE|server] Running client->server command '"..data.cmd.."' from client("..tostring(clientid).."|"..tostring(data.pl.playerid)..")!")
		print("SERVER-DEBUG: "..Tserial.pack(data.pl,true))
		assert(_G["server_callback_"..data.cmd]~=nil, "Received invalid client->server command '"..data.cmd.."'!")
		_G["server_callback_" .. data.cmd](data.pl)
	--else
		--print("SERVER-WARNING-RECVDUPE")
	end
end

function server_update(dt)
	server:update(dt)
	--[[if not server_startedgame then
		server_pingtimer = server_pingtimer + dt
		if server_pingtimer > 2 then
			for k, v in pairs(server_peerlist) do
				server_send("pingupdate", {id=k,ping=v.mostrecentping})
			end

			server_pingtimer = server_pingtimer - 2
			for x = 2, #server_peerlist do
				server_sendto("pingcheck", nil, server_peerlist[x].ip, server_peerlist[x].port)
				server_peerlist[x].countingping = true
				server_peerlist[x].personalpingtimer = 0
			end
		end
	end]]

	--[[for x = 2, #server_peerlist do
		if server_peerlist[x].countingping then
			server_peerlist[x].personalpingtimer = server_peerlist[x].personalpingtimer + dt
		end
	end]]

	--[[if server_resyncmaxplayers then
		server_resyncmaxplayers = false
		for x = 2, #server_peerlist do
			server_sendto("changemax", {lobby_maxplayers}, server_peerlist[x].ip, server_peerlist[x].port)
		end
	end]]
	
	server_coordsupdatetimer = server_coordsupdatetimer + dt
	if server_coordsupdatetimer > server_coordsupdatedelta and server_startedgame and objects then
		server_coordsupdatetimer = server_coordsupdatetimer - server_coordsupdatedelta
		for k, v in pairs(server_peerlist) do
			local tosend={}
			for i=1,#server_peerlist do
				table.insert(tosend, i)
			end
			tosend[k]=nil
			server_send("synccoords", {
				target=k,
				x=objects["player"][k].x,
				y=objects["player"][k].y,
				speedx=objects["player"][k].speedx,
				speedy=objects["player"][k].speedy,
				pointingangle=objects["player"][k].pointingangle, 
				--@DEV: ^ This is here until I write an easier way to manage timers.
				--dt=dt,
			}, tosend)
		end
	end

	--[[if server_angletimer > .1 and server_startedgame and objects then
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
	end]]
	
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
	
	if lobby_currentmappackallowed --[[and #server_peerlist > 1]] then --debug
		server_send("startgame", {numplayers=#server_peerlist})
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
function server_callback_connect(pl)
	if #server_peerlist < lobby_maxplayers then
		--Send swarm of information to a client that connects
		--@TODO: We need to *not* have this prebuilt entities table.
		table.insert(server_peerlist, {clientid=pl.clientid, nick=pl.nick, mappacks=pl.mappacks})
		local respondto = #server_peerlist
		server_clientidlookup[pl.clientid]=respondto
		server_sendhistory[pl.clientid] = {}
		server_recvhistory[pl.clientid] = {}
		local connecttable = {
			yourpid = respondto,
			mappacks = mappacklist,
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
		--@DEV: don't let this get in the way for now
		--resyncconfig = true
		server_send("connected", connecttable, respondto)
		hook.Call("ServerClientConnected", respondto, pl.clientid)
		return
	else
		server_send("rejected", {reason="lobby full"}, pl.clientid)
	end
end
function server_callback_coordsupdate(pl)
	local sendto={}
	for i=1,#server_peerlist do
		table.insert(sendto, i)
	end
	sendto[pl.playerid]=nil
	pl.target = pl.playerid
	--@TODO: Make the above available in the form of "everyonebut(pls)"
	server_send("synccoords", pl, sendto)
end
function server_callback_controlupdate(pl)
	local sendto={}
	for i=1,#server_peerlist do
		table.insert(sendto, i)
	end
	sendto[pl.playerid]=nil
	pl.target = pl.playerid
	--print("ZDEBUG: "..von.serialize(pl))
	--@TODO: Make the above available in the form of "everyonebut(pls)"
	server_send("synccontrol", pl, sendto)
end