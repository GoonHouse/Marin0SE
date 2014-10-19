function levelscreen_load(reason, i)
	--check if lives left
	livesleft = false
	for i = 1, players do
		if mariolivecount == false or mariolives[i] > 0 then
			livesleft = true
		end
	end
	
	if reason == "sublevel" then
		gamestate = "sublevelscreen"
		blacktime = sublevelscreentime
		sublevelscreen_level = i
	elseif reason == "vine" then
		gamestate = "sublevelscreen"
		blacktime = sublevelscreentime
		sublevelscreen_level = i
	elseif livesleft then
		gamestate = "levelscreen"
		blacktime = levelscreentime
		if reason == "next" then --next level
			checkpointsub = false
			checkpointx = {}
			checkpointy = {}
			respawnsublevel = 0
			
			--check if next level doesn't exist
			if not love.filesystem.exists("mappacks/" .. mappack .. "/" .. marioworld .. "-" .. mariolevel .. ".txt") then
				gamestate = "mappackfinished"
				blacktime = gameovertime
				music:play("princessmusic.ogg")
			end
		end
	else
		gamestate = "gameover"
		blacktime = gameovertime
		playsound("gameover")
	end
	
	if editormode then
		blacktime = 0
	end
	
	if reason ~= "initial" then
		updatesizes()
	end
	
	if marioworld == 1 or mariolevel == 1 then
		blacktime = blacktime * 1.5
	end
	
	if gameplaytype == "Oddjob" then
		levelscore = 0
		levelcoin = 0
	end
	
	coinframe = 1
	redcoinframe = 1
	
	love.graphics.setBackgroundColor(0, 0, 0)
	levelscreentimer = 0
	
	--reached worlds
	local updated = false
	if not reachedworlds[mappack] then
		reachedworlds[mappack] = {}
	end
	
	if marioworld ~= "M" and not reachedworlds[mappack][marioworld] then
		reachedworlds[mappack][marioworld] = true
		updated = true
	end
	
	if updated then
		saveconfig()
	end
	
	--Load the level
	
	if gamestate == "levelscreen" then
		if respawnsublevel ~= 0 then
			loadlevel(marioworld .. "-" .. mariolevel .. "_" .. respawnsublevel)
		else
			loadlevel(marioworld .. "-" .. mariolevel)
		end
	elseif gamestate == "sublevelscreen" then
		loadlevel(sublevelscreen_level)
	end
	
	if skiplevelscreen and gamestate ~= "gameover" and gamestate ~= "mappackfinished" then
		startlevel(gamestate == "levelscreen")
	end
end

function levelscreen_update(dt)
	levelscreentimer = levelscreentimer + dt
	if levelscreentimer > blacktime then
		if gamestate == "levelscreen" or gamestate == "sublevelscreen" then
			startlevel(gamestate == "levelscreen")
		else
			menu_load()
		end
		
		return
	end
end

function levelscreen_draw()
	--black background
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 0, 0, width*16*scale, height*16*scale)
	love.graphics.setColor(255, 255, 255)

	if levelscreenback then
		love.graphics.draw(levelscreenback, 0, 0, 0, scale, scale)
	end
	
	if levelscreentimer < blacktime - blacktimesub and levelscreentimer > blacktimesub then
		if gamestate == "levelscreen" then
			properprint("world " .. marioworld .. "-" .. mariolevel, (width/2*16)*scale-40*scale, 72*scale - (players-1)*6*scale)
			
			if not arcade and not mkstation then
				for i = 1, players do
					local x = width/2*16-29
					local y = 97 + (i-1)*20 - (players-1)*8
							
					local v = characters[mariocharacter[i]]
					local angle = 3
					if v.nopointing then
						angle = 1
					end
					
					local pid = i
					if pid > 4 then
						pid = 5
					end
					
					
					
					drawplayer(nil, x+6, y+11, scale,     v.smalloffsetX, v.smalloffsetY, 0, v.smallquadcenterX, v.smallquadcenterY, "idle", false, false, mariohats[i], v.animations, v.idle[angle], 0, false, false, mariocolors[i], 1, portalcolor[i][1], portalcolor[i][2], nil, nil, nil, nil, nil, nil, characters[mariocharacter[i]])
					
					love.graphics.setColor(255, 255, 255, 255)
					if mariolivecount == false then
						properprint("*  inf", (width/2*16)*scale-8*scale, y*scale+7*scale)
					else
						properprint("*  " .. mariolives[i], (width/2*16)*scale-8*scale, y*scale+7*scale)
					end
				end
			end
			
			
			if mappack == "smb" and marioworld == 1 and mariolevel == 1 then
				local s = "remember that you can run with "
				--[[for i = 1, #controls[1]["run"] do
					s = s .. controls[1]["run"][i]
					if i ~= #controls[1]["run"] then
						s = s .. "-"
					end
				end]]
				s = s .. "your feet"
				properprint(s, (width/2*16)*scale-string.len(s)*4*scale, 200*scale)
			end
			
			if mappack == "portal" and marioworld == 1 and mariolevel == 1 then
				local s = "you can remove your portals with "
				--[[for i = 1, #controls[1]["reload"] do
					s = s .. controls[1]["reload"][i]
					if i ~= #controls[1]["reload"] then
						s = s .. "-"
					end
				end]]
				s = s .. "hard work and dedication"
				properprint(s, (width/2*16)*scale-string.len(s)*4*scale, 190*scale)
				
				local s = "you can grab cubes and push buttons with "
				--[[for i = 1, #controls[1]["use"] do
					s = s .. controls[1]["use"][i]
					if i ~= #controls[1]["use"] then
						s = s .. "-"
					end
				end]]
				s = s .. "your hands"
				properprint(s, (width/2*16)*scale-string.len(s)*4*scale, 200*scale)
			end
			
		elseif gamestate == "mappackfinished" then
			properprint("congratulations!", (width/2*16)*scale-64*scale, 120*scale)
			properprint("you have finished this mappack!", (width/2*16)*scale-128*scale, 140*scale)
		else
			local s = "game over"
			properprint(s, (width/2*16)*scale-40*scale, 120*scale)
		end
		
		love.graphics.translate(0, -yoffset*scale)
		if yoffset < 0 then
			love.graphics.translate(0, yoffset*scale)
		end
		
		drawui(true)
	end
end
