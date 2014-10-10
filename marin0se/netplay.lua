local alternatesynctimer = -5
networkynccedconfig = false
seesawisync = {}

function client_send(cmd, pl)
	if cmd=="move" then return false end
	--if chan~="synccoords" and cmd~="otherpointingangle" then
	--print("[LUBE|client] Issuing server command '"..cmd.."'!")
	--end
	client:send(Tserial.pack({cmd=cmd,pl=pl}),true)
end

function network_load(ip, port)
	ip = ip or "localhost"
	port = port or 27020
	marioworld = 1
	mariolevel = 1
	
	print("[LUBE|client] connecting...")
	client = lube.udpClient()
	client.callbacks.recv = client_recv
	local suc, err = client:connect(ip, tonumber(port))
	if suc then
		game.isClient = true
		--[[ Upon connection, probe the server to get a unique ID. ]]
		print("[LUBE|client] probing server")
		client_send("connect", {nick=guielements.nickentry.value,mappacks=mappacklist})
	else
		print("[LUBE|client] connection failed")
		print("[LUBE|client] failure code: "..tostring(err))
		notice.new("server not found ", notice.red, 5)
	end
	

	networktimeouttimer = 0
	networkwarningssent = 0

	love.filesystem.write("savenick.txt", "return { nick=\"" .. guielements.nickentry.value .. "\"}")

	network_removeplayertimeouttables = {}
	for x = 1, math.max(players, 4) do
		network_removeplayertimeouttables[x] = 0
	end
end
function client_recv(rdata)
	local data = Tserial.unpack(rdata, true)
	--print("[LUBE|client] Running server->client command '"..data.cmd.."'!")
	--print("DEBUG: "..Tserial.pack(data,true))
	assert(_G["client_callback_"..data.cmd]~=nil, "Received invalid server->client command '"..data.cmd.."'!")
	_G["client_callback_" .. data.cmd](data.pl)
end
function network_update(dt)
	client:update(dt)
	if objects then
		networkupdatetimer = networkupdatetimer + dt
		if networkupdatetimer > networkupdatelimit then 
			networkupdatetimer = networkupdatetimer - networkupdatelimit
			client_send("move", {
				--[[@WARNING: 
					We don't want to trust the player to be who they say they are, so
					give the server a function to map a clientid to a playerid.
				]]
				x=objects["player"][1].x,
				y=objects["player"][1].y,
				speedx=objects["player"][1].speedx,
				speedy=objects["player"][1].speedy,
				pointingangle=objects["player"][1].pointingangle,
				dt=love.timer.getDelta()
			})
		end
	end
end
function network_update2(dt)
	local chan, data = client_receive()
	if objects then
		networktimeouttimer = networktimeouttimer + dt
		for x = 2, math.max(players, 4) do
			network_removeplayertimeouttables[x] = network_removeplayertimeouttables[x]+dt
		end
	end
	while chan and data do
		print("CLIENT: Responding to message '"..chan.."'...")
		if chan == "rejected" then
			if data.reason == "full" then
				notice.new("server is full", notice.red, 5)
			else
				notice.new(data.reason, notice.red, 5)
			end
			onlinemp = false
			udp:close()
			--@TODO: Wrap this.
			return
		elseif chan == "endgame" then
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

		if not objects then

			network_generallobbysyncs(data)
			return
		end

		--@TODO: Still don't know what this does.
		--[[if datatable[2] and tonumber(datatable[2]) then
			network_removeplayertimeouttables[convertclienttoplayer(tonumber(datatable[2]))] = 0
		end]]

		_G["client_" .. chan](data)
		if networktimeouttimer > 10 then
			notice.new("connection re-established", notice.red, 5)
		end
		networktimeouttimer = 0

		chan, data = client_receive()
	end

	if not objects then
		return
	end
	
	

	enemyupdatetimer = enemyupdatetimer + dt
	if enemyupdatetimer > 1 and clientisnetworkhost then
		enemyupdatetimer = 0
		-- not sure if this is even used?!
	end

	if alternatesynctimer >= 0 then
		alternatesynctimer = alternatesynctimer + dt
	end

	if alternatesynctimer > 1 then
		alternatesynctimer = 0
		if clientisnetworkhost then
			for k, v in pairs(objects["enemy"]) do
				local synctable = {
					id=v.a[1],
					t=v.t,
					x=v.x,
					y=v.y,
					speedx=v.speedx,
					speedy=v.speedy,
				}
				if v.t == "squid" then
					-- I don't know why we do this, we just do.
					synctable.closestplayer = (v.closestplayer%2)+1
				elseif v.t == "bowser" then
					targetx = v.targetx
				elseif v.t == "koopa" then
					flying = v.flying
					small = v.small
				end
				client_send("enemysync", synctable)
			end
			
			local oddsyncs = {"castlefire", "platform", "upfire", "box", "mushroom", "seesawplatform"}
			for _, p in pairs(oddsyncs) do
				local objs = getobjectsonscreen(p)
				for k,v in pairs(objs) do
					local oddsynctable = {
						name=p,
						id=i,
						x=v.x,
						y=v.y,
						speedx=v.speedx,
						speedy=v.speedy,
					}
					if p=="castlefire" then
						oddsynctable.angle = v.angle
					elseif p=="platform" then
						oddsynctable.timer = v.timer
					elseif p=="box" and v.parent then
						oddsynctable.parent = v.parent.playernumber
					end
					client_send("oddsync", {name=p, id=i, angle=v.angle})
				end
			end
		elseif lastplayeronplatform then
			--oddsync seesaw
		end
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


function getifmainmario(b)
	for i, v in pairs(objects["player"]) do
		if v == b and i ~= 1 then
			return false
		end
	end
	return true
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
-- GREAT BIG LIST OF CALLBACKS
function client_callback_connected(pl)
	networksynccedconfig = false
	local nick = guielements.nickentry.value
	lobby_load(nick)
	networkclientnumber = pl.yourpid
	print("connected, my client number is " .. networkclientnumber)
end
function client_callback_startgame(pl)
	connectionstate = "starting game..."
	players = pl.numplayers
	game_load()
end
function client_callback_synccoords(pl)
	local pid = pl.playerid
	local tid = pl.target
	--if pl.playerid == nil then
		-- this means we were called synccoords as a direct response to someone's move command
	--end
	if tid == networkclientnumber then
		print("WARNING: we tried to update ourselves from network")
		return false
	end
	pl.target = nil
	pl.playerid = nil
	--print("pid="..tostring(pid)..", tid="..tostring(tid)..", ncn="..tostring(networkclientnumber))
	--@DEV: If everything goes wrong, it's because of the above line.
	for k,v in pairs(pl) do
		objects["player"][convertclienttoplayer(tid)][k] = v
	end
end
function client_callback_synccontrol(pl)
	local pid = pl.playerid
	local tid = pl.target
	--if pl.playerid == nil then
		-- this means we were called synccoords as a direct response to someone's move command
	--end
	--print("XDEBUG: "..Tserial.pack(pl,true))
	--print("WE ARE: "..tostring(networkclientnumber).."TID: "..tostring(tid).."CID: "..tostring(convertclienttoplayer(tid)))
	if tid == networkclientnumber then
		print("WARNING: we tried to update ourselves from network")
		return false
	end
	--[[pl.target = nil
	pl.playerid = nil]]
	print("pid="..tostring(pid)..", tid="..tostring(tid)..", ncn="..tostring(networkclientnumber))
	if pl.direction == "press" then
		objects["player"][convertclienttoplayer(tid)]:controlPress(pl.control, true)
	elseif pl.direction == "release" then
		objects["player"][convertclienttoplayer(tid)]:controlRelease(pl.control, true)
	end
end