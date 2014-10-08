local alternatesynctimer = -5
networkynccedconfig = false
seesawisync = {}

function client_send(chan, data)
	if chan~="synccoords" and chan~="otherpointingangle" then
		print("CLIENT-S: "..chan.." -- sending")
	end
	udp:send(von.serialize({chan=chan,data=data,client=networkclientnumber}))
end

function client_sendto(chan, data, ip, port)
	udp:sendto(von.serialize({chan=chan,data=data,client=networkclientnumber}), ip, port)
end

function client_receive()
	local raw, msg = udp:receive()
	if raw==nil then return nil, nil end
	raw = von.deserialize(raw)
	--@TODO: use the ip and port to bind to a particular address
	return raw.chan, raw.data
end

function client_receivefrom()
	local raw, ip, port = udp:receivefrom()
	--@TODO: In the odd circumstance we are sent no data from somebody?
	if raw==nil then return nil, nil, ip, port end
	raw = von.deserialize(raw)
	--@TODO: use the ip and port to bind to a particular address
	return raw.chan, raw.data, ip, port
end


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
		client_send("connect", {nick=guielements.nickentry.value})
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
	local chan, data = client_receive()
	while chan and data do
		if chan~="synccoords" and chan~="otherpointingangle" then
			print("CLIENT-U: "..chan.." -- doing") 
		end
		_G["client_callback_" .. chan](data)
		chan, data = client_receive()
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
	
	networkupdatetimer = networkupdatetimer + dt
	if networkupdatetimer > networkupdatelimit then 
		networkupdatetimer = networkupdatetimer - networkupdatelimit
		client_send("move", {
			x=objects["player"][1].x,
			y=objects["player"][1].y,
			speedx=objects["player"][1].speedx,
			speedy=objects["player"][1].speedy,
			dt=love.timer.getDelta()
		})
	end

	angletimer = angletimer + dt
	if angletimer > .1 and not clientisnetworkhost then
		angletimer = 0
		client_send("pointingangle", {angle=objects["player"][1].pointingangle})
	elseif angletimer > .5 and clientisnetworkhost then
		if alternatesynctimer < 0 then
			alternatesynctimer = 0
		end
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
function client_callback_connected(data)
	networksynccedconfig = false
	local nick = guielements.nickentry.value
	lobby_load(nick)
	networkclientnumber = data.clientid
	print("connected, my client number is " .. networkclientnumber)
end
function client_callback_startgame(data)
	connectionstate = "starting game..."
	players = data.numplayers
	game_load()
end
function client_callback_synccoords(data)
	if objects then
		print("hmm "..data.id.." ("..data.x..","..data.y..")")
		objects["player"][convertclienttoplayer(data.id)].x = data.x
		objects["player"][convertclienttoplayer(data.id)].y = data.y
		objects["player"][convertclienttoplayer(data.id)].speedx = data.speedx
		objects["player"][convertclienttoplayer(data.id)].speedy = data.speedy
		objects["player"][convertclienttoplayer(data.id)].currentdt = data.dt
	else
		print("WARNING: synccoords called too early")
	end
end
function client_callback_otherpointingangle(data)
	if objects then
		objects["player"][convertclienttoplayer(data.id)].pointingangle = data.pointingangle
	else
		print("WARNING: otherpointingangle called too early")
	end
end