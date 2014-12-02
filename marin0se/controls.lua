function controlsUpdate(dt)
	if controls.tap.gameScreenshot then
		screenshotUploadWrap("screenshot.png", love.graphics.newScreenshot())
	end
	
	if controls.tap.editorGetMousePosition then
		local x, y = getMouseTile(mouse.getX(), mouse.getY())
		print("mouse position", x, y)
	end
	
	if controls.debugModifier then
		if controls.tap.recordToggle then
			recording = not recording
		end
		if replaysystem and controls.tap.replaySave then
			objects["player"][1]:savereplaydata()
		end
		if controls.tap.debugLua then
			debug.debug()
		end
		if controls.tap.debugCrash then
			totallynonexistantfunction()
		end
	else
		if controls.tap.debugLua then
			lurker.scan()
		elseif controls.tap.consoleToggle then
			debug_bar:ToggleConsole()
		end
	end 
	
	if controls.tap.gameGrabMouseToggle then
		love.mouse.setGrabbed(not love.mouse.isGrabbed())
	end
	
	if gamestate == "lobby" or gamestate == "onlinemenu" then
		if controls.tap.menuBack then
			net_quit()
			return
		end
	end
	
	if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "options" then
		menu_controlupdate(dt)
	elseif gamestate == "game" then
		game_controlupdate(dt)
	elseif gamestate == "intro" then
		intro_skip()
	end
end

function exKeypressed(key, isrepeat)
	if keyprompt then
		keypromptenter("key", key)
		return
	end

	--@WARNING: This is the sample of code that causes the online lobby to edit all textboxes at once.
	for i, v in pairs(guielements) do
		if v:keypress(string.lower(key)) then
			--return
		end
	end
	
	if testbed then
		for k,v in pairs(testbed) do
			if v.active then
				v:keypressed(key)
			end
		end
	end
	
	
	if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "options" then
		table.insert(konamitable, key)
		table.remove(konamitable, 1)
		local s = ""
		for i = 1, #konamitable do
			s = s .. konamitable[i]
		end
		
		if sha1(s) == konamihash then --Before you wonder how dumb this is; This used to be a different code than konami because I thought it'd be fun to make people figure it out before they can tell others how to easily unlock cheats (without editing files). It wasn't, really.
			playsound("konami") --allowed global
			gamefinished = true
			saveconfig()
			notice.new("Cheats unlocked!")
		end
	elseif gamestate == "game" and editormode and rightclickm then
		-- aside from the transplanted code above, this was the only thing left in the editor's keypressed
		rightclickm:keypressed(key)
	elseif gamestate == "intro" then
		intro_skip()
	end
end

function exMousepressed(ox, oy, button)
	local x, y = getMousePos()
	if gamestate == "intro" then
		intro_skip()
	end
	
	--editor transplant because I guess the editor doesn't use the standard guielements array
	
	--editor transplant because ???
	if rightclickm then
		allowdrag = false
		if button == "r" or not rightclickm:mousepressed(x, y, button) then
			closerightclickmenu()
			return
		else
			return
		end
	end
	
	if testbed then
		for k,v in pairs(testbed) do
			if v.active then
				v:mousepressed(x, y, button)
			end
		end
	end
	
	for i, v in pairs(guielements) do
		if v.priority then
			if v:click(x, y, button) then
				return
			end
		end
	end
	
	for i, v in pairs(guielements) do
		if not v.priority then
			if v:click(x, y, button) then
				return
			end
		end
	end
end

function exMousereleased(ox, oy, button)
	local x, y = getMousePos()
	--desktopsize.width/(width*16*scale)*x, desktopsize.height/(height*16*scale)*y
	
	for i, v in pairs(guielements) do
		v:unclick(x, y, button)
	end
	
	if testbed then
		for k,v in pairs(testbed) do
			if v.active then
				v:mousereleased(x, y, button)
			end
		end
	end
	
	--same as above
	if rightclickm then
		rightclickm:mousereleased(x, y, button)
	end
end

function bind(key, func)
	
end