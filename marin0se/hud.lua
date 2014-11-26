hud = class("hud")

--[[@NOTE:
	This is so that the overlay that is drawn per-screen works nicely, anything that masks the screen and isn't
	a gui element should live here.
	
	This is mostly non-functional because the emphasis at the time was to get levels working.
]]

function hud:init()
	self.state = "levelscreen" --level, none
	
	self.globalMask = {0, 0, 0, 255}
	self.useGlobalMask = true
	
	self.overlayImage = nil --drawable
end

function hud:update(dt)
	
end

function hud:draw()
	if self.useGlobalMask then
		love.graphics.setColor(self.globalMask)
		love.graphics.rectangle("fill", 0, 0, width*16*scale, height*16*scale)
	end
	
	love.graphics.setColor(255, 255, 255)
	if self.overlayImage then
		love.graphics.draw(self.overlayImage, 0, 0, 0, scale, scale)
	end
	
	if self.state == "levelscreen" then
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
						properprint("*  " .. objects["player"][i].lives, (width/2*16)*scale-8*scale, y*scale+7*scale)
					end
				end
			end
			
			
			if mappack == "smb" then
				local  s = help_tips[help_tipi]
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