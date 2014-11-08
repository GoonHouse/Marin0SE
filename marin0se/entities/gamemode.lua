gamemode = class('gamemode')

function gamemode:init(worlds)
	self.worlds = worlds --all the levels/worlds this is responsible for managing
	self.rules = {} --a basic set of rules to enforce every think frame
end

local magictimeoffset = 8 --I guess this is the expected length of the hurry up jingle

function gamemode:update(dt)
	for _, planet in pairs(self.worlds) do
		
		-- TIME
		if planet.timelimit > 0 and planet.time > 0  and planet:anyPlayersActiveAndAlive() then
			local pretime = planet.time
			planet.time = planet.time - planet.timescale*dt
			
			if planet.time > 0 and pretime >= planet.lowtime and planet.time < planet.lowtime then
				love.audio.stop()
				playsound("lowtime") --allowed global
				
				if pretime >= planet.lowtime-8 and planet.time < planet.lowtime-magictimeoffset then
					if planet:areAnyPlayersStarred() then
						music:play("starmusic.ogg")
					else
						playmusic()
					end
				end
			elseif planet.time <= 0 then
				planet.time = 0
				planet:killAllPlayers("time")
			end
		end
	end
end