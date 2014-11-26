-- how old map do?

function savemap(filename)
	local s = ""
	
	--mapheight
	local s = s .. mapheight .. CATEGORYDELIMITER
	
	local mul = 1
	local prev = nil
	
	for y = 1, mapheight do
		for x = 1, mapwidth do
			local current = map[x][y][1] .. (coinmap[x][y] and "c" or "")
			
			--check if previous is the same
			if #map[x][y] == 1 then
				if prev == current and (y ~= mapheight or x ~= mapwidth) then
					mul = mul + 1
				elseif prev == current and y == mapheight and x == mapwidth then
					mul = mul + 1
					s = s .. prev .. MULTIPLYDELIMITER .. mul
				else
					if prev then
						if mul > 1 then
							s = s .. prev .. MULTIPLYDELIMITER .. mul
						else
							s = s .. prev
						end
						
						if y ~= mapheight or x ~= mapwidth then
							s = s .. BLOCKDELIMITER
						end
					end
					prev = current
					mul = 1
					if y == mapheight and x == mapwidth then
						if prev then
							s = s .. BLOCKDELIMITER
						end
						s = s .. prev
					end
				end
			else
				if prev then
					if mul > 1 then
						s = s .. prev .. MULTIPLYDELIMITER .. mul
					else
						s = s .. prev
					end
					
					s = s .. BLOCKDELIMITER
				end
				prev = nil
				mul = 1
				
				for i = 1, #map[x][y] do
					if tonumber(map[x][y][i]) and tonumber(map[x][y][i]) < 0 then
						s = s .. "m" .. math.abs(tostring(map[x][y][i]))
					else
						s = s .. tostring(map[x][y][i])
					end
					
					if i == 1 and coinmap[x][y] then
						s = s .. "c"
					end
					
					if i ~= #map[x][y] then
						s = s .. LAYERDELIMITER
					end
				end
				
				if y ~= mapheight or x ~= mapwidth then
					s = s .. BLOCKDELIMITER
				end
			end
		end
	end
	
	--options
	s = s .. CATEGORYDELIMITER .. "backgroundr" .. EQUALSIGN ..  background[1]
	s = s .. CATEGORYDELIMITER .. "backgroundg" .. EQUALSIGN ..  background[2]
	s = s .. CATEGORYDELIMITER .. "backgroundb" .. EQUALSIGN ..  background[3]
	s = s .. CATEGORYDELIMITER .. "spriteset" .. EQUALSIGN ..  spriteset
	if musicname then
		s = s .. CATEGORYDELIMITER .. "music" .. EQUALSIGN ..  musicname
	end
	if intermission then
		s = s .. CATEGORYDELIMITER .. "intermission"
	end
	if bonusstage then
		s = s .. CATEGORYDELIMITER .. "bonusstage"
	end
	if haswarpzone then
		s = s .. CATEGORYDELIMITER .. "haswarpzone"
	end
	if underwater then
		s = s .. CATEGORYDELIMITER .. "underwater"
	end
	if custombackground then
		if custombackground == true then
			s = s .. CATEGORYDELIMITER .. "custombackground"
		else
			s = s .. CATEGORYDELIMITER .. "custombackground" .. EQUALSIGN ..  custombackground
		end
	end
	if customforeground then
		if customforeground == true then
			s = s .. CATEGORYDELIMITER .. "customforeground"
		else
			s = s .. CATEGORYDELIMITER .. "customforeground" .. EQUALSIGN ..  customforeground
		end
	end
	s = s .. CATEGORYDELIMITER .. "timelimit" .. EQUALSIGN ..  mariotimelimit
	s = s .. CATEGORYDELIMITER .. "scrollfactor" .. EQUALSIGN ..  scrollfactor
	s = s .. CATEGORYDELIMITER .. "fscrollfactor" .. EQUALSIGN ..  fscrollfactor
	if not portalsavailable[1] or not portalsavailable[2] then
		local ptype = "none"
		if portalsavailable[1] then
			ptype = "blue"
		elseif portalsavailable[2] then
			ptype = "orange"
		end
		
		s = s .. CATEGORYDELIMITER .. "portalgun" .. EQUALSIGN ..  ptype
	end
	
	if levelscreenbackname then
		s = s .. CATEGORYDELIMITER .. "levelscreenback" .. EQUALSIGN ..  levelscreenbackname
	end
	
	--tileset
	
	love.filesystem.createDirectory( "mappacks" )
	love.filesystem.createDirectory( "mappacks/" .. mappack )
	
	love.filesystem.write("mappacks/" .. mappack .. "/" .. filename .. ".txt", s)
	
	--preview
	
	previewimg = renderpreview()
	previewimg:encode("mappacks/" .. mappack .. "/" .. filename .. ".png")
	
	print("Map saved as " .. "mappacks/" .. filename .. ".txt")
	notice.new("Map saved!", notice.white, 2)
end