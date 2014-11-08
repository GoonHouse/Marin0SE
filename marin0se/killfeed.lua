killfeed = {}
killfeed.red = {255, 127, 127}
killfeed.white = {255, 255, 255}

killfeed.attacker = {255, 127, 127}
killfeed.dtype = {127, 255, 127}
killfeed.victim = {127, 127, 255}

killfeed.killfeeds = {}
killfeed.duration = 5 --seconds
killfeed.fadetime = 0.5

function killfeed.glob(glob)
	local fallbackname = "mystery "..tostring(glob):split("class ")[2]
	local name = ""
	
	if objects~=nil then
		for k,v in pairs(objects) do
			for k2,v2 in pairs(v) do
				if glob == v2 then
					local subclass=tostring(k)
					if subclass=="enemy" then
						subclass = glob.t
					end
					name = subclass.."#"..tostring(k2)
				end
			end
		end
		
		if name=="" then
			name=fallbackname
		end
		return name
	else
		return fallbackname
	end
end

function killfeed.new(attacker, dtype, victim, ex)
	local duration = duration or killfeed.duration
	local color = color or killfeed.white
	
	local attackername = killfeed.glob(attacker) --getglobalentityid(attacker)
	dtype = dtype or "kiss"
	local victimname = killfeed.glob(victim) --getglobalentityid(victim)
	
	table.insert(killfeed.killfeeds, {
		attacker=attackername:lower(),
		dtype=dtype:lower(),
		victim=victimname:lower(),
		color = killfeed.white,
		text=attackername:lower().." "..dtype:lower().."ed "..victimname:lower(),
		life=duration,
		duration=duration,
	})
end 

function killfeed.update(dt)
	for i = #killfeed.killfeeds, 1, -1 do
		local v = killfeed.killfeeds[i]
		
		v.life = v.life - dt
		
		if v.life <= 0 then
			table.remove(killfeed.killfeeds, i)
		end
	end
end

function killfeed.draw()
	local y = 0
	for i = #killfeed.killfeeds, 1, -1 do
		local v = killfeed.killfeeds[i]
		
		--get width by finding longest line 
		local split = v.text:split("|")
		local longest = #split[1]
		for i = 2, #split do
			if #split[i] > longest then
				longest = #split[i]
			end
		end
		
		local height = #split*10+3
		
		local actualy = killfeed.gety(y, v.life, height, v.duration)
		
		local targetrect = {width*16 - longest*8-5, actualy, longest*8+5, height}
		local scissor = {(width*16 - longest*8-5)*scale, y*scale, (longest*8+5)*scale, (actualy-y+height)*scale}
		--This freezes the menu for some reason
		--Spent a goddamn hour debugging this
		--FML
		--love.graphics.setScissor(unpack(scissor))
		
		love.graphics.setColor(0, 0, 0, 200)
		love.graphics.rectangle("fill", targetrect[1]*scale, targetrect[2]*scale, targetrect[3]*scale, targetrect[4]*scale)
		
		love.graphics.setColor(255, 255, 255, 255)
		drawrectangle(targetrect[1]+1, targetrect[2]+1, targetrect[3]-2, targetrect[4]-2)
		
		--love.graphics.setColor(killfeed.white)
		--properprint(v.text, 	(targetrect[1]+2)*scale, (actualy+3)*scale)
		
		local xoff = targetrect[1]+3
		love.graphics.setColor(killfeed.attacker)
		properprint(v.attacker, xoff*scale, (actualy+3)*scale)
		xoff = xoff + (v.attacker.." "):len()*8
		love.graphics.setColor(killfeed.dtype)
		properprint(v.dtype.."ed", xoff*scale, (actualy+3)*scale)
		xoff = xoff + (v.dtype.."ed "):len()*8
		love.graphics.setColor(killfeed.victim)
		properprint(v.victim, xoff*scale, (actualy+3)*scale)
		
		y = actualy+height
		--love.graphics.setScissor()
	end
	
	love.graphics.setColor(255, 255, 255)
end

function killfeed.gety(y, life, height, duration)
	if life > duration-killfeed.fadetime then
		return y - height*((life-(duration-killfeed.fadetime))/killfeed.fadetime)^2
	elseif life < killfeed.fadetime then
		return y - height*((killfeed.fadetime-life)/killfeed.fadetime)^2
	else
		return y
	end
end