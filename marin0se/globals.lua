--[[
	The purpose of this is to document / list variables in the global scope.
]]

soundsearchdirs = {
	"mappacks/%(mappack)s/sounds/%(soundpack)s/%(file)s",
	"mappacks/%(mappack)s/sounds/DEFAULT/%(file)s",
	"mappacks/%(mappack)s/music/%(file)s",
	"sounds/%(soundpack)s/%(file)s",
	"sounds/DEFAULT/%(file)s",
	"sounds/DEFAULT/missingsound.ogg"
}

graphicssearchdirs = {
	"mappacks/%(mappack)s/graphics/%(graphicspack)s/%(file)s",
	"mappacks/%(mappack)s/graphics/DEFAULT/%(file)s",
	"mappacks/%(mappack)s/graphics/%(file)s",
	"graphics/%(graphicspack)s/%(file)s",
	"graphics/DEFAULT/%(file)s",
	"graphics/DEFAULT/missinggraphic.png"
}

enemygraphicsearchdirs = {
	"mappacks/%(mappack)s/graphics/%(graphicspack)s/enemies/%(file)s",
	"mappacks/%(mappack)s/graphics/DEFAULT/enemies/%(file)s",
	"mappacks/%(mappack)s/enemies/%(file)s",
	"graphics/%(graphicspack)s/enemies/%(file)s",
	"graphics/DEFAULT/enemies/%(file)s",
	"enemies/%(file)s",
}

controlTable = {
	a = "left",
}