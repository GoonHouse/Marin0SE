function onlinemenu_load()
	objects = nil
	
	gamestate = "onlinemenu"
	
	localnicks = {"virt. reality", "no fun","smp2","motherducker", "smart9.0","avatar fad", "triple hat",  "a0zora", "99nasela", "wear will", "designer b","camel barrier", "moguri", "automatique", "superiorityman", "mythicalpastry", "not greencandy", "orthobot", "broken turret", "rektic", "honchkrow", "sol sucks", "201", "tortoise59", "wizard cushion"}
	localnick = localnicks[math.random(#localnicks)]

	if love.filesystem.exists("savenick.txt") then
		local returnedtable = love.filesystem.load("savenick.txt")()
		if returnedtable.nick then
			localnick = returnedtable.nick
		end

		for x = 1, #localnicks do
			if localnick == localnicks[x] then
				localnick = localnicks[math.random(#localnicks)]
				break
			end
		end
	end
	
	guielements = {}
	guielements.nickentry = guielement:new("input", 5, 30, 14, nil, localnick, 14, 1)
	
	guielements.configdecrease = guielement:new("button", 192, 31, "{", configdecrease, 0)
	guielements.configincrease = guielement:new("button", 214, 31, "}", configincrease, 0)
	
	
	guielements.ipentry = guielement:new("input", 6, 87, 23, joingame, "", 23, 1)
	guielements.portentry2 = guielement:new("input", 131, 155, 5, nil, "27020", 5, 1, true)
	
	guielements.portentry = guielement:new("input", 274, 87, 5, nil, "27020", 5, 1, true)
	
	guielements.magiccheckbox = guielement:new("checkbox", 220, 147, togglemagic, true)
	
	guielements.hostbutton = guielement:new("button", 247, 199, "create game", creategame, 2)
	guielements.hostbutton.bordercolor = {255, 0, 0}
	guielements.hostbutton.bordercolorhigh = {255, 127, 127}
	
	guielements.joinbutton = guielement:new("button", 61, 199, "join game", joingame, 2)
	guielements.joinbutton.bordercolor = {0, 255, 0}
	guielements.joinbutton.bordercolorhigh = {127, 255, 127}

	guielements.hideip = guielement:new("checkbox", 44, 142, togglehideip, false)
	onlinemenu_hidingip = false
	
	runanimationtimer = 0
	runanimationframe = 1
	runanimationdelay = 0.1
	
	playerconfig = 1
	
	usemagic = true
	
	magictimer = 0
	magicdelay = 0.15
	magics = {}
	hook.Call("GameOnlineMenuLoaded")
end

function onlinemenu_update(dt)
	runanimationtimer = runanimationtimer + dt
	while runanimationtimer > runanimationdelay do
		runanimationtimer = runanimationtimer - runanimationdelay
		runanimationframe = runanimationframe - 1
		if runanimationframe == 0 then
			runanimationframe = 3
		end
	end
	
	--[[magictimer = magictimer + dt
	while magictimer > magicdelay do
		magictimer = magictimer - magicdelay
		if checkmagic(guielements.ipentry.value) then
			table.insert(magics, magic:new())
		end
	end--]]
	
	local delete = {}
	
	for i, v in pairs(magics) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(magics, v) --remove
	end
	
	localnick = guielements.nickentry.value
end

function onlinemenu_draw()
	--TOP PART
	love.graphics.setColor(0, 0, 0, 200)
	love.graphics.rectangle("fill", 3*scale, 3*scale, 394*scale, 52*scale)
	love.graphics.setColor(255, 255, 255)
	
	properprint("online play", 4*scale, 5*scale)
	
	properprint("your nick:", 4*scale, 20*scale)
	guielements.nickentry:draw()
	
	properprint("use config", 140*scale, 20*scale)
	properprint("number  " .. playerconfig , 140*scale, 33*scale)
	guielements.configdecrease:draw()
	guielements.configincrease:draw()
	
	drawplayercard(240, 10, mariocolors[playerconfig], mariohats[playerconfig], localnick)
	
	
	--BOTTOM PART
	
	--LEFT (JOIN)
	love.graphics.setColor(0, 0, 0, 200)
	love.graphics.rectangle("fill", 3*scale, 58*scale, 196*scale, 163*scale)
	
	love.graphics.setColor(255, 255, 255)
	properprint("join game", 64*scale, 60*scale)
	
	properprint("address/magicdns", 36*scale, 77*scale)
	guielements.ipentry:draw()
	love.graphics.setColor(150, 150, 150)
	properprint("enter ip, hostname,", 24*scale, 107*scale)
	properprint("domain or magicdns", 28*scale, 117*scale)
	properprint("words to connect.", 32*scale, 127*scale)
	
	love.graphics.setColor(255, 255, 255)
	properprint("optional port:", 21*scale, 158*scale)
	guielements.portentry2:draw()
	
	love.graphics.setColor(150, 150, 150)
	properprint("not needed with", 40*scale, 172*scale)
	properprint("magicdns", 68*scale, 182*scale)
	
	guielements.joinbutton:draw()

	guielements.hideip:draw()

	properprint("hide address", guielements.hideip.x*scale+12*scale, 143*scale)
	
	--RIGHT (HOST)
	love.graphics.setColor(0, 0, 0, 200)
	love.graphics.rectangle("fill", 202*scale, 58*scale, 195*scale, 163*scale)
	
	love.graphics.setColor(255, 255, 255)
	properprint("host game", 260*scale, 60*scale)
	properprint("port", 280*scale, 77*scale)
	
	guielements.portentry:draw()
	
	love.graphics.setColor(150, 150, 150)
	properprint("port will need to", 230*scale, 107*scale)
	properprint("be udp forwarded for", 218*scale, 117*scale)
	properprint("internet play!", 242*scale, 127*scale)
	
	guielements.magiccheckbox:draw()
	properprint("use magicdns words", 230*scale, 148*scale)
	love.graphics.setColor(150, 150, 150)
	properprint("allows friends", 238*scale, 162*scale)
	properprint("to join using", 242*scale, 172*scale)
	properprint("two short words", 234*scale, 182*scale)
	
	guielements.hostbutton:draw()
	
	for i, v in pairs(magics) do
		v:draw()
	end
end

function drawplayercard(x, y, colortable, hattable, nick, ping)
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle("fill", (x-1)*scale, (y-1)*scale, 152*scale, 38*scale)
	love.graphics.setColor(255, 255, 255, 255)
	drawrectangle(x, y, 150, 36)

	for i = 0, 3 do
		if i > 0 then
			love.graphics.setColor(unpack(colortable[i]))
		else
			love.graphics.setColor(255, 255, 255)
		end
		--drawplayer(nil, x, y, scale, 0, 0) --, hats, graphic, quad, pointingangle, shot, upsidedown, colors, lastportal, portal1color, portal2color, runframe, swimframe, climbframe, jumpframe, biggraphic, fireanimationtimer, char)
		--drawplayercard(marioanimations[i], mariorun[3][runanimationframe], (x-6)*scale, (y-1)*scale, 0, scale*2)
	end
	love.graphics.setColor(255, 255, 255)

	--[[Scissors just for hat stacks
	local yadd = 0
	local addcolortohat = true

	if (type(hattable) == "table" and #hattable > 1) or hattable[1] ~= 1 then 
		addcolortohat = false
	end

	for i = 1, #hattable do
		if addcolortohat then
			love.graphics.setColor(unpack(colortable[1]))
		end]]
		--local offsets = hatoffsets["running"]
		--love.graphics.draw(hat[hattable[i]].graphic, (x-6)*scale, (y-1)*scale, 0, scale*2, scale*2, - hat[hattable[i]].x + offsets[runanimationframe][1], - hat[hattable[i]].y + offsets[runanimationframe][2] + yadd)
		--yadd = yadd + hat[hattable[i]].height
	--end

	love.graphics.setColor(255, 255, 255)
	properprint(nick, x*scale+35*scale, y*scale+10*scale)

	if not ping then
		love.graphics.setColor(127, 127, 127)
	end
	properprint("ping:", x*scale+35*scale, y*scale+22*scale)
	if not ping then
		properprint("host", x*scale+75*scale, y*scale+22*scale)
	else
		if tonumber(ping) < 40 then
			love.graphics.setColor(0, 255, 0)
		elseif tonumber(ping) >= 40 and tonumber(ping) < 80 then
			love.graphics.setColor(255, 225, 0)
		elseif tonumber(ping) >= 80 then
			love.graphics.setColor(255, 0, 0)
		end
		properprint(ping .. "ms", x*scale+75*scale, y*scale+22*scale)
	end
end

function configdecrease()
	playerconfig = math.max(1, playerconfig-1)
end

function configincrease()
	playerconfig = math.min(4, playerconfig+1)
end

function togglemagic()
	usemagic = not usemagic
	guielements.magiccheckbox.var = usemagic
end

function checkmagic(s)
	if string.find(s, " ") then
		return true
	else
		return false
	end
end

function creategame()
	port = tonumber(guielements.portentry.value)

	if usemagic then
		adjective, noun = magicdns_make()
	end

	if (usemagic and adjective and noun) or not usemagic then
		
		server_load()


		onlinemp = true
		network_load("localhost", port)
	end

end

function joingame()
	local ip, port
	port = tonumber(guielements.portentry2.value)
	local s = guielements.ipentry.value

	if checkmagic(s) then
		usemagic = true
		local split = s:split(" ")
		adjective, noun = split[1], split[2]
		ip, port = magicdns_find(adjective, noun)
		
		if ip == nil then
			notice.new("server not found", notice.red, 5)
			return
		end
	else
		usemagic = false
		ip = guielements.ipentry.value
	end

	onlinemp = true

	
	network_load(ip, port)

end

function togglehideip()
	onlinemenu_hidingip = not onlinemenu_hidingip
	guielements.hideip.var = onlinemenu_hidingip
	guielements.ipentry.hidetext = onlinemenu_hidingip
end

magicdns_validresponses = {"MADE", "KEPT", "REMOVED", "FOUND", "NOTFOUND", "ERROR"}

function magicdns_make()
	http.PORT = port
	s = http.request("http://dns.stabyourself.net/MAKE/" .. magicdns_identity .. "/" .. magicdns_session .. "/" .. port)
	if s then
		result = s:split("/")
		magicdns_error(result)
		
		if result[1] == "MADE" then
			return string.lower(result[2]), string.lower(result[3])
		else
			print("MAGICDNS MAKE FAILED HORRIBLY");
			usemagic = false
			return;
		end
	else
		print("nothing returned")
	end
end

function magicdns_keep()
	s = http.request("http://dns.stabyourself.net/KEEP/"..magicdns_identity.."/"..magicdns_session)
	if s then
		result = s:split("/")
		magicdns_error(result)
		if result[1] ~= "KEPT" then
			print("MAGICDNS KEEP FAILED! RETURNED: " .. s)
		elseif result[2] ~= "" then
			print("MAGICDNS EXTERNAL PORT KNOWN = " .. result[2])
		end
	else
		print("returned nothing")
	end
end

function magicdns_remove()
	s = http.request("http://dns.stabyourself.net/REMOVE/"..magicdns_identity.."/"..magicdns_session)
	if s then
		result = s:split("/")
		magicdns_error(result)
		if result[1] ~= "REMOVED" then
			print("MAGICDNS REMOVE FAILED! RETURNED: " .. s)
		end
	else
		print("returned nothing")
	end
end
	
function magicdns_find(adjective, noun)
	s = http.request("http://dns.stabyourself.net/FIND/" .. magicdns_identity .. "/" .. string.upper(adjective) .. "/" .. string.upper(noun))
	if s then
		local result = s:split("/")
		magicdns_error(result)
		if result[1] == "FOUND" then
			if result[4] == "" then
			print("MAGICDNS Server external port is not known!")
			end		
			return result[2], result[3], result[4]
		else
			return nil
		end
	else
		print("returned nothing")
	end
end

function magicdns_error(result)
	if result[1] == "ERROR" then
		
		print("MAGICDNS ERROR: "..result[2])
		return true
	elseif not table.contains(magicdns_validresponses, result[1]) then
		print("MAGICDNS: nonstandard response: "..result[1])
		return true
	end
	return false
end