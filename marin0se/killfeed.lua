killfeed = {}
killfeed.red = {255, 127, 127}
killfeed.white = {255, 255, 255}

killfeed.attacker = {255, 127, 127}
killfeed.dtype = {127, 255, 127}
killfeed.victim = {127, 127, 255}

killfeed.themes = {
	dark = {
		background = {30,28,17},
		icon = {229,224,181},
		alpha = 200,
		
		attacker = {184,59,59},
		neutral = {255,255,255},
		victim = {89,121,139}
	},
	light = {
		background = {179,171,141},
		icon = {61,57,35},
		alpha = 200,
		
		attacker = {184,59,59},
		neutral = {0,0,0},
		victim = {89,121,139}
	},
	humiliation = {
		background = {213,198,217},
		icon = {89,76,93},
		alpha = 200,
		
		attacker = {229,172,182},
		neutral = {0,0,0},
		victim = {229,172,182}
	},
}

killfeed.killfeeds = {}
killfeed.duration = 5 --seconds
killfeed.fadetime = 0.5

function killfeed.glob(glob)
	if glob == nil then
		return ""
	end
	local fallbackname = tostring(glob):split("class ")[2].."?"
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

function killfeed.process_dtypes(dtype)
	
end

function killfeed.new(attackers, dtype, victims, ex)
	local duration = duration or killfeed.duration
	local theme = "dark"
	
	local trashname = tostring(attackers):split("class ")[2]
	local attackername = ""
	if attackers and attackers.isInstanceOf and attackers:isInstanceOf(_G[trashname]) then
		if attackers.playernumber == 1 then
			theme = "light"
		end
		attackername = killfeed.glob(attackers)
	elseif attackers then
		for k,v in pairs(attackers) do
			if v.playernumber == 1 then
				theme = "light"
			end
			attackername = attackername .. killfeed.glob(v)
			if k<#attackers then
				attackername = attackername.." + "
			end
		end
	else
		attackername = "world"
	end
	dtype = dtype or "kiss"
	local victimname = killfeed.glob(victims)
	
	if (victims and victims.playernumber == 1) then
		theme = "light"
	end
	if attackers==victims or (type(attackers)=="table" and table.contains(attackers, victims)) then
		theme = "humiliation"
	end
	
	table.insert(killfeed.killfeeds, {
		attacker=attackername:lower(),
		dtype=dtype:lower(),
		victim=victimname:lower(),
		theme=theme,
		--text=attackername:lower().." "..dtype:lower().."ed "..victimname:lower(),
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
		local thewidth = (
			v.attacker:len()
			+ v.victim:len()
			+ v.dtype:len() --eventually this will be an image width
			+ 2 --spacing chars
			+ 2 --"ed" to the dtype
		)*8
		--[[local split = v.text:split("|")
		local longest = #split[1]
		for i = 2, #split do
			if #split[i] > longest then
				longest = #split[i]
			end
		end]]
		
		
		
		local height = 1*10+3 --1 was #split
		local actualy = killfeed.gety(y, v.life, height, v.duration)
		
		local targetrect = {
			width*16 - thewidth-5,
			actualy,
			thewidth+5,
			height
		}
		local scissor = {
			(width*16 - thewidth-5)*scale,
			y*scale,
			(thewidth+5)*scale,
			(actualy-y+height)*scale
		}
		local datheme = killfeed.themes[v.theme]
		
		-- background
		love.graphics.setColor(datheme.background, datheme.alpha)
		--love.graphics.rectangle("fill", targetrect[1]*scale, targetrect[2]*scale, targetrect[3]*scale, targetrect[4]*scale)
		love.graphics.roundrect("fill", targetrect[1]*scale, targetrect[2]*scale, targetrect[3]*scale, targetrect[4]*scale, 16, 16)
		
		-- outline
		local tline = love.graphics.getLineWidth()
		love.graphics.setColor(datheme.neutral, datheme.alpha)
		love.graphics.setLineWidth(2)
		love.graphics.roundrect("line", targetrect[1]*scale, targetrect[2]*scale, targetrect[3]*scale, targetrect[4]*scale, 16, 16)
		--love.graphics.roundrect("line", (targetrect[1]+1)*scale, (targetrect[2]+1)*scale, (targetrect[3]-2)*scale, (targetrect[4]-2)*scale, 16, 16)
		love.graphics.setLineWidth(tline)
		
		--drawrectangle(targetrect[1]+1, targetrect[2]+1, targetrect[3]-2, targetrect[4]-2)
		
		--love.graphics.setColor(killfeed.white)
		--properprint(v.text, 	(targetrect[1]+2)*scale, (actualy+3)*scale)
		
		--attacker(s)
		local xoff = targetrect[1]+3
		love.graphics.setColor(datheme.attacker, datheme.alpha)
		properprint(v.attacker, xoff*scale, (actualy+3)*scale)
		xoff = xoff + (v.attacker.." "):len()*8
		
		love.graphics.setColor(datheme.icon, datheme.alpha)
		properprint(v.dtype.."ed", xoff*scale, (actualy+3)*scale)
		xoff = xoff + (v.dtype.."ed "):len()*8
		
		love.graphics.setColor(datheme.victim, datheme.alpha)
		properprint(v.victim, xoff*scale, (actualy+3)*scale)
		
		y = actualy+height
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