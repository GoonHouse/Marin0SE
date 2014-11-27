client = class("client")

--[[@NOTE:
	This exists because mapping camera / perspective code to the player felt wrong.
	This is for each viewport within the game that represents a player.
	ie: local co-op, splitscreen = 2 clients
		local co-op, single screen = 1 client (furthest player)
	HUD stuff can also be managed here.
]]

function client:init()
	
end