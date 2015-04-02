-- Load the module.
local mml = require("mml")

local steeldrum = love.audio.newSource("I12.wav", "static")

-- Sample song!
local twinkle = "t120 l4 o4  ccggaag2 ffeeddc2 ggffeed2 ggffeed2 ccggaag2 ffeeddc2"

function love.load()
	love._openConsole()

end

-- A simple busy-wait delay function.
local clock = os.clock
function delay(n)
	local start = clock()
	repeat until (clock() - start) >= n
end

-- Create the player
local samplemmlplayer = mml.newPlayer(twinkle, "multiplier")

while true do
	local ok, note, time, vol = samplemmlplayer

	if not ok then
		print(note)
		break
	end

	if note then
		--	Use SoX's synth effect to sound the note.
		--	os.execute( string.format(
		--	"play -qn -V0 synth %.2f pluck %.2f",
		--	time, note
		--	))
		-- The Enigma, translating that Sox into playing a pitch adjusted sample for a given duration?
		steeldrum:setLooping(true)
		steeldrum:setPitch(note)
		love.audio.play(steeldrum)
	else
		-- If "note" is nil, it's a rest.
		steeldrum:setLooping(false)
		love.audio.stop(steeldrum)
		-- delay(time)
	
	end
	
end
