--[[
	STEAL MY SHIT AND I'LL FUCK YOU UP
	PRETTY MUCH EVERYTHING BY MAURICE GUÉGAN AND IF SOMETHING ISN'T BY ME THEN IT SHOULD BE OBVIOUS OR NOBODY CARES

	Please keep in mind that for obvious reasons, I do not hold the rights to artwork, audio or trademarked elements of the game.
	This license only applies to the code and original other assets. Obviously. Duh.
	Anyway, enjoy.
	
	
	
	DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
              Version 2, December 2004

	Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

	Everyone is permitted to copy and distribute verbatim or modified
	copies of this license document, and changing it is allowed as long
	as the name is changed.

			DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
	TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

	0. You just DO WHAT THE FUCK YOU WANT TO.
]]
require("utils") --we wanna do this as close to the opening scope as possible
require("hook")

function love.load(args)
	hook.Call("LovePreLoad", args)
	args = args or {}
	
	-- I'm literally doing this just so the title load text gets shaken up.
	love.math.random()
	for i=1,love.math.random(5) do
		love.math.random()
	end
	
	lastline = debug.getinfo(1).currentline
	lasttime = 0
	
	love.audio.setDistanceModel("exponent clamped")
	love.graphics.setLineJoin("miter") --@DEV: This fixes a bug in love 0.9.1 with calling lg.getLineJoin before init, remove this when you upgrade.
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setDefaultFilter("nearest", "nearest")
	
	require("helpers")
	
	-- configure the thingers
	--[[distance models
		none: basically everything stays the same, always
		inverse: things get quieter as you move away
		linear: basically things just move around but never fade, you get the most dopple out of this
		exponent: like inverse, except happens quicker
		x clamped: gain gets clamped
	]]
	--love.keyboard.setKeyRepeat(false)
	
	--IT BEGINS
	add("Initialized")
	
	--@todo: require significant components here
	require("globals")
	require("variables")
	require("loveutils")
	add("Variables + Love Overloads")
	
	--register some resources to draw the intro screen ASAP
	logo = love.graphics.newImage("stabyourself.png")
	fontimage = love.graphics.newImageFont("fontimageexample.png",
					" abcdefghijklmnopqrstuvwxyz" ..
					"ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
					"123456789.,!?-+/():;%&`'*#=[]\"")
	
	logoPresent()
	add("Logo Presented")

	--@todo: third party library stuff
	tween = require("libs.tween")
	class = require("libs.middleclass")
	lurker = require("libs.lurker")
	lurker.interval = 30 --seconds
	lurker.quiet = false --set to true to stop reload errors
	require("libs.loveframes")
	JSON = require("libs.JSON")
	require("timer")
	--require "notice"
	require("libs.lube")
	require("libs.neubind")
	nb = neubind:new(neuControlTable)
	TLbind = require("libs.TLbind")
	binds, controls = TLbind.giveInstance(controlTable)
	require("libs.grapher")
	local i=1
	for k,v in pairs(graphs) do
		local g = grapher.Create(k, v)
		g.x = love.graphics.getWidth()-g.width
		g.y = love.graphics.getHeight()-(g.height*i)
		g.font = fontimage
		i = i + 1
	end
	--graphs.tick = fpsgraph.createGraph(love.graphics.getWidth()-50,love.graphics.getHeight()-90, 50, 30, 0.5, false)
	--[[
	require("libs.monocle")
	Monocle.new({
		isActive=false,
		customPrinter=false,
		customColor = {0, 128, 0, 255},
		debugToggle = 'f1',
		filesToWatch = {}
	})
	http = require("socket.http")
	http.PORT = 55555
	http.TIMEOUT = 1
	http.TIMEOUT = 4
	]]
	require("imgurupload")
	require("libs.sha1")
	add("Core Libraries")
	
	--require("libs.von")
	--require "netplay2"
	--require "netplay"
	--require "_client"
	--require "server"
	--require "lobby"
	--add("Netplay Libs")
	
	require "gui.onlinemenu"
	require "gui.killfeed"
	require "gui.nodetree"
	require "gui.maptree"
	require "gui.tiletree"
	add("GUI Libs")
	
	require "dmap"
	require "world"
	add("World Classes")
	
	-- these are here because we deported some stuff for the sake of having a clean main
	require("reload")
	require("loader")
	require("mouse")
	require("config")
	require("controls")
	require("gui.killfeed") --this is necessary because reloadGraphics uses vars in here
	require("gui.notice")
	add("Guff Libraries")
	
	--Get biggest screen size
	local sizes = love.window.getFullscreenModes()
	desktopsize = sizes[1]
	
	for i = 2, #sizes do
		if sizes[i].width > desktopsize.width or sizes[i].height > desktopsize.height then
			desktopsize = sizes[i]
		end
	end
	touchfrominsidescaling = math.min(desktopsize.width/(width*16), desktopsize.height/(height*16))
	touchfrominsidemissing = desktopsize.height-height*16*touchfrominsidescaling
	
	shaderlist = love.filesystem.getDirectoryItems( "shaders/" )
	local rem
	for i, v in pairs(shaderlist) do
		if v == "init.lua" then
			rem = i
		else
			shaderlist[i] = string.sub(v, 1, string.len(v)-5)
		end
	end
	table.remove(shaderlist, rem)
	table.insert(shaderlist, 1, "none")
	require "shaders"
	add("Shaders")
	
	--@WARNING: This will be inaccurate for any mappacks that provide a namespaced graphicspack or potential mods.
	for k,v in pairs(love.filesystem.getDirectoryItems( "graphics" )) do
		if love.filesystem.isDirectory("graphics/"..v) and string.upper(v)==v then
			table.insert(graphicspacklist, v)
		end
	end
	reloadGraphics()
	add("Initializing Graphics")
	
	reloadFonts()
	add("Initializing Fonts")
	
	--@WARNING: Same goes for me.
	for k,v in pairs(love.filesystem.getDirectoryItems( "sounds" )) do
		if love.filesystem.isDirectory("graphics/"..v) and string.upper(v)==v then
			table.insert(soundpacklist, v)
		end
	end
	reloadSounds()
	add("Initializing Sounds")
	
	loadconfig()
	add("User Config")
	
	changescale(scale, true)
	add("Resolution Change")
	
	require "entity" --preceed baseentity so the loading classes can be used
	require "baseentity"
	local mixins = love.filesystem.getDirectoryItems("basedmixins")
	for k,v in pairs(mixins) do
		require("basedmixins."..v:sub(0,-5))
		
		-- precache all the images used by this entity type, eventually this will be dynamic
		--for k2,v2 in pairs(_G[basedents[k]].image_sigs) do
		--	allocate_image(k2, v2[1], v2[2])
		--end]]
	end
	add("BasedEntity & Mixins")
	
	basedents = love.filesystem.getDirectoryItems("basedents")
	for k,v in pairs(basedents) do
		basedents[k] = v:sub(0,-5)
		require("basedents."..basedents[k])
		
		-- precache all the images used by this entity type, eventually this will be dynamic
		--for k2,v2 in pairs(_G[basedents[k]].image_sigs) do
		--	allocate_image(k2, v2[1], v2[2])
		--end]]
	end
	add("BasedEntity Classes")
	
	for _,v in pairs(saneents) do
		-- we're doing sub because I forgot how not to \o/
		--require("entities."..v:sub(0, -5))
		require("entities."..v)
	end
	add("Sane Entities")
	
	require("weapons.portalgun")
	require("weapons.gelcannon")
	add("Weapons")
	
	require "animatedquad"
	require "intro"
	require "levelscreen"
	require "editor"
	require "menu"
	require "game"
	require "physics"
	require "player"
	require "enemies"
	require "camera"
	require "characterloader"
	require "animationguiline"
	require "quad"
	require "hatconfigs"
	require "bighatconfigs"
	require "customhats"
	require "gui"
	require "musicloader"
	require "rightclickmenu"
	require "animation"
	require "animationsystem"
	require "regiondrag"
	require "animatedtimer"
	require "entitylistitem"
	require "entitytooltip"
	require "itemanimation"
	
	--things that should be sane/based
	require "fire"
	require "magic"
	add("Engine Libs")
	
	love.filesystem.createDirectory( "mappacks" )
	love.graphics.setPointSize(3*scale)
	love.graphics.setLineWidth(2*scale)
	add("Graphics Settings")
	
	local imgwidth, imgheight = smbtilesimg:getWidth(), smbtilesimg:getHeight()
	local width = math.floor(imgwidth/17)
	local height = math.floor(imgheight/17)
	local imgdata = love.image.newImageData("smbtiles.png")
	
	for y = 1, height do
		for x = 1, width do
			table.insert(tilequads, quad:new(smbtilesimg, imgdata, x, y, imgwidth, imgheight))
			local r, g, b = getaveragecolor(imgdata, x, y)
			table.insert(rgblist, {r, g, b})
		end
	end
	smbtilecount = width*height
	
	--add portal tiles
	local imgwidth, imgheight = portaltilesimg:getWidth(), portaltilesimg:getHeight()
	local width = math.floor(imgwidth/17)
	local height = math.floor(imgheight/17)
	local imgdata = love.image.newImageData("portaltiles.png")
	
	for y = 1, height do
		for x = 1, width do
			table.insert(tilequads, quad:new(portaltilesimg, imgdata, x, y, imgwidth, imgheight))
			local r, g, b = getaveragecolor(imgdata, x, y)
			table.insert(rgblist, {r, g, b})
		end
	end
	portaltilecount = width*height
	add("Standard Tiles")
	
	--add entities
	entityquads = {}
	local imgwidth, imgheight = entitiesimg:getWidth(), entitiesimg:getHeight()
	local width = math.floor(imgwidth/17)
	local height = math.floor(imgheight/17)
	local imgdata = love.image.newImageData("entities.png")
	
	for y = 1, height do
		for x = 1, width do
			table.insert(entityquads, entity:new(entitiesimg, x, y, imgwidth, imgheight))
			entityquads[#entityquads]:sett(#entityquads)
		end
	end
	entitiescount = width*height
	
	-- overload table because we can't change the timing of the above
	for k,v in pairs(entityquad_overloads) do
		entityquads[k] = v
	end
	add("Hardcoded Entities")
	
	reloadQuads()
	add("Stranded Quad Definitions")
	
	shaders:init()
	add("Shader Initialization")
	
	magicdns_session_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	magicdns_session = ""
	local rand
	for i = 1, 8 do
		rand = math.random(string.len(magicdns_session_chars))
		magicdns_session = magicdns_session .. string.sub(magicdns_session_chars, rand, rand)
	end
	--use love.filesystem.getIdentity() when it works
	magicdns_identity = love.filesystem.getSaveDirectory():split("/")
	magicdns_identity = string.upper(magicdns_identity[#magicdns_identity])
	add("MagicDNS Identity")
	
	--[[
	mycamera = camera:new()
	mycamera:zoomTo(0.4)
	add("Camera Init")
	]]

	loveframes.util.SetActiveSkin("Blu")

	--@todo: settings load

	--@todo: gui elements load
	require("gui.debug_bar")
	debug_bar:func()

	--@todo: assets
	bg = love.graphics.newImage("graphics/DEFAULT/bg.png")
	bgscalex = love.graphics.getWidth()/bg:getWidth()
	bgscaley = love.graphics.getHeight()/bg:getHeight()
	
	dertotal = os.clock()-starttime
	print("TOTAL: " .. tostring(os.clock()).."s")
	if skipintro then
		menu_load()
	else
		intro_load()
	end
	
	hook.Call("LovePostLoad", args)
end

function love.update(dt)
	hook.Call("LovePreUpdate", dt)
	lurker.update()
	if music then
		music:update()
	end
	timer.Update(dt)
	
	grapher.update(dt)
	
	nb:update(dt)
	TLbind:update()
	binds:update()
	controlsUpdate(dt)
	notice.update(dt)
	killfeed.update(dt)
	
	--@WARNING: I can't be certain this is safe.
	realdt = dt
	dt = math.min(0.5, dt) --ignore any dt higher than half a second
	
	if recording then
		dt = recordtarget
	end
	
	steptimer = steptimer + dt
	dt = targetdt
	--@todo: handle dt for network timesync
	
	if skipupdate then
		steptimer = 0
		skipupdate = false
		return
	end
	
	--speed
	if bullettime and speed ~= speedtarget then
		if speed > speedtarget then
			speed = math.max(speedtarget, speed+(speedtarget-speed)*dt*5)
		elseif speed < speedtarget then
			speed = math.min(speedtarget, speed+(speedtarget-speed)*dt*5)
		end
		
		if math.abs(speed-speedtarget) < 0.02 then
			speed = speedtarget
		end
		
		if speed > 0 then
			for i, v in pairs(soundlist) do
				v.source:setPitch( speed )
			end
			music.pitch = speed
			love.audio.setVolume(volume)
		else	
			love.audio.setVolume(0)
		end
	end
	
	while steptimer >= targetdt do
		steptimer = steptimer - targetdt
		
		if frameskip then
			if frameskip > skippedframes then
				skippedframes = skippedframes + 1
				return
			else
				skippedframes = 0
			end
		end
		
		if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "options" or gamestate == "lobby" then
			menu_update(dt)
		elseif gamestate == "levelscreen" or gamestate == "gameover" or gamestate == "sublevelscreen" or gamestate == "mappackfinished" then
			--levelscreen_update(dt)
		elseif gamestate == "game" then
			game_update(dt)	
		elseif gamestate == "intro" then
			intro_update(dt)	
		end
		if onlinemp then
			if clientisnetworkhost then
				server_update(dt)
			end
			network_update(dt)
		end
		
		for i, v in pairs(guielements) do
			v:update(dt)
		end
		
		--netplay_update(dt)
		--love.window.setTitle("NCN:"..networkclientnumber.."; FPS:" .. love.timer.getFPS())
	end
	love.window.setTitle("Marin0SE; FPS:" .. love.timer.getFPS())
	
	tween.update(dt)
	if any_frames_visible then
		loveframes.update(dt)
	end
	hook.Call("LovePostUpdate", dt)
end

function love.draw()
	hook.Call("LovePreDraw")
	--love.graphics.setColor(255, 255, 255, 255)
	--love.graphics.draw(bg, 0, 0, 0, bgscalex, bgscaley)
	
	shaders:predraw()
	--mycamera:attach()
	if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "options" or gamestate == "lobby" then
		menu_draw()
	elseif gamestate == "levelscreen" or gamestate == "gameover" or gamestate == "mappackfinished" then
		--levelscreen_draw() --@DEV: stubbed because we don't need it
	elseif gamestate == "game" then
		game_draw()
	elseif gamestate == "intro" then
		--@DEV: don't actually draw the intro because it broked
		--intro_draw()
	end
	--mycamera:detach()
	shaders:postdraw()
	
	notice.draw()
	killfeed.draw()
	
	--@todo: entity draw
	if any_frames_visible then
		loveframes.draw()
	end
	
	if game.graphs.draw then
		grapher.draw()
	end
	
	--[[
	if recording then
		screenshotimagedata = love.graphics.newScreenshot( )
		screenshotimagedata:encode("recording/" .. recordframe .. ".png")
		recordframe = recordframe + 1
		screenshotimagedata = nil
		
		if recordframe%100 == 0 then
			collectgarbage("collect")
		end
	end
	]]
	hook.Call("LovePostDraw")
end

--INPUT HANDLERS

function love.mousepressed(x, y, button)
	exMousepressed(x,y,button)
	if any_frames_visible then
		loveframes.mousepressed(x, y, button)
	end
end

function love.mousereleased(x, y, button)
	exMousereleased(x,y,button)
	if any_frames_visible then
		loveframes.mousereleased(x, y, button)
	end
end

function love.keypressed(key, isrepeat)
	exKeypressed(key, isrepeat)
	if any_frames_visible then
		loveframes.keypressed(key, isrepeat)
	end
end

function love.keyreleased(key)
	if any_frames_visible then
		if debug_bar.console_input:GetFocus() then
			if key == "up" then
				debug_bar.console_input:ResetSelection()
				local scrollback_size = table.length(debug_bar.scrollback)
				debug_bar.scrollback_index = debug_bar.scrollback_index - 1
				if debug_bar.scrollback_index < 1 then
					debug_bar.scrollback_index = 1
				end
				if scrollback_size ~= 0 then
					debug_bar.console_input:SetText(debug_bar.scrollback[debug_bar.scrollback_index])
				end
			elseif key == "down" then
				debug_bar.console_input:ResetSelection()
				local scrollback_size = utils.tablelength(debug_bar.scrollback)

				debug_bar.scrollback_index = debug_bar.scrollback_index + 1
				if debug_bar.scrollback_index < scrollback_size+1 then
					debug_bar.console_input:SetText(debug_bar.scrollback[debug_bar.scrollback_index])
				elseif debug_bar.scrollback_index >= scrollback_size+1 then
					debug_bar.console_input:Clear()
					debug_bar.scrollback_index = scrollback_size+1
				end
			end
		end
		
		loveframes.keyreleased(key)
	end
end

function love.textinput(text)
	if any_frames_visible then
		loveframes.textinput(text)
	end
end

--[[ commented out because pause on focus lost is currently all sorts of broken
function love.focus(f)
	if not f and gamestate == "game" and not editormode and not levelfinished and not everyonedead then
		pausemenuopen = true
		love.audio.pause()
	end
end
]]

function love.quit()
	print("goodbye")
end

function love.run()
	love.math.setRandomSeed(os.time())
	
	
	love.load(arg)

	-- Main loop time.
	while true do
		-- Process events.
		love.event.pump()
		for e,a,b,c,d in love.event.poll() do
			if e == "quit" then
				if not love.quit() then
					love.audio.stop()
					return
				end
			end
			love.handlers[e](a,b,c,d)
		end

		-- Update dt, as we'll be passing it to update
		love.timer.step()
		local dt = love.timer.getDelta()

		-- Call update and draw
		love.update(dt) -- will pass 0 if love.timer is disabled
		love.graphics.clear()
		love.graphics.origin()
		
		--Fullscreen hack
		if not mkstation and fullscreen and gamestate ~= "intro" then
			completecanvas:clear()
			love.graphics.setScissor()
			completecanvas:renderTo(love.draw)
			love.graphics.setScissor()
			if fullscreenmode == "full" then
				love.graphics.draw(completecanvas, 0, 0, 0, desktopsize.width/(width*16*scale), desktopsize.height/(height*16*scale))
			else
				love.graphics.draw(completecanvas, 0, touchfrominsidemissing/2, 0, touchfrominsidescaling/scale, touchfrominsidescaling/scale)
				love.graphics.setColor(0, 0, 0)
				love.graphics.rectangle("fill", 0, 0, desktopsize.width, touchfrominsidemissing/2)
				love.graphics.rectangle("fill", 0, desktopsize.height-touchfrominsidemissing/2, desktopsize.width, touchfrominsidemissing/2)
				love.graphics.setColor(255, 255, 255, 255)
			end
		else
			love.graphics.setScissor()
			love.draw()
		end
		
		love.graphics.present()
		love.timer.sleep(0.001)
	end
end