function love.load()
	love._openConsole()
	
	mml = require("mml")
	
	iterator = 1 --our position in the song
	nexttime = 0 --the time of the next note to play
	ratemult = 300 --(one note should be this long)
	steeldrumstartcuepoint = 5520 -- sample starting cue point
	steeldrumendcuepoint = 5568 -- sample ending cue point
	
	steeldrumattack = love.audio.newSource("I12A.ogg", "static")
	steeldrumhold = love.audio.newSource("I12H.ogg", "static")
	steeldrumhold:setLooping(true)
	
	twinkle = "t128 l4 o4  ccggaag2 ffeeddc2 ggffeed2 ggffeed2 ccggaag2 ffeeddc2"
	
	samplemmlplayer = mml.newPlayer(twinkle, "multiplier")
end

function love.update(dt)
	-- use our sync
	nexttime = nexttime - dt
	
	if steeldrumplaying and steeldrumattack:isStopped(true) and steeldrumhold:isStopped(true) then
		print("EXTEND")
		love.audio.play(steeldrumhold)
	end
	
	-- only play if we aren't delayed
	if nexttime <= 0 and iterator <= #samplemmlplayer then
		local sample = samplemmlplayer[iterator]
		local note = sample.output
		local time = sample.notetime
		local volume = sample.volume
		
		print("NOTE DEBUG:", love.timer.getTime(), iterator, note, time, volume)
		
		if note then
			-- stop the existing note because we have to start our next
			love.audio.stop(steeldrumattack)
			love.audio.stop(steeldrumhold)
			steeldrumattack:setPitch(note)
			steeldrumattack:setVolume(volume)
			steeldrumhold:setPitch(note)
			steeldrumhold:setVolume(volume)
			love.audio.play(steeldrumattack)
			steeldrumplaying = true
			nexttime = time
		else
			-- If "note" is nil, it's a rest.
			steeldrumplaying = false
			nexttime = time
		end
		iterator = iterator + 1
	end
end