levelscreen = class("levelscreen")

function levelscreen:init(reason, mystery)
	nop() --I don't know why.
end

function levelscreen_load(x, y)
	print("WARNING: vanilla levelscreen_load handler called in place of world")
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