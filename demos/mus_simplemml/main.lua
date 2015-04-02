function love.load()
	love._openConsole()
	
	mml = require("mml")
	
	iterator = 1 --our position in the song
	nexttime = 0 --the time of the next note to play
	ratemult = 300 --(one note should be this long)
	
	steeldrum = love.audio.newSource("I12.wav", "static")
	steeldrum:setLooping(false)
	
	twinkle = "t120 l4 o4  ccggaag2 ffeeddc2 ggffeed2 ggffeed2 ccggaag2 ffeeddc2"
	
	samplemmlplayer = mml.newPlayer(twinkle, "multiplier")
end

function love.update(dt)
	-- use our sync
	nexttime = nexttime - dt
	-- only play if we aren't delayed
	if nexttime <= 0 and iterator <= #samplemmlplayer then
		local sample = samplemmlplayer[iterator]
		local note = sample.output
		local time = sample.notetime
		local volume = sample.volume
		print("NOTE DEBUG:", love.timer.getTime(), iterator, note, time, volume)
		
		if note then
			-- stop the existing note because we have to start our next
			love.audio.stop(steeldrum)
			steeldrum:setPitch(note)
			steeldrum:setVolume(volume)
			love.audio.play(steeldrum)
			nexttime = time
		else
			-- If "note" is nil, it's a rest.
			nexttime = time
		end
		iterator = iterator + 1
	end
end