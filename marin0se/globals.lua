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
	keys = {
		x = "playerDebug",
		w = {"playerUp", "menuUp", "editorNudgeUp"},
		a = {"playerLeft", "menuLeft", "editorNudgeLeft"},
		s = {"playerDown", "menuDown", "editorNudgeDown"},
		d = {"playerRight", "menuRight", "editorNudgeRight"},
		up = {"menuUp", "editorScrollUp"},
		left = {"menuLeft", "editorScrollLeft"},
		m = {"mappackShortcut"},
		down = {"menuDown", "editorScrollDown"},
		right = {"menuRight", "editorScrollRight"},
		k = {"editorQuickSave", "replaySave"},
		--(key == "return" or key == "enter" or key == "kpenter" or key == " ")
		["return"] = "menuSelect",
		tab = "menuNextElement", --unimplemented
		f = {"playerUse", "debugEmbiggen"},
		escape = {"playerPause", "menuBack"},
		l = "playerSuicide",
		t = "editorToggle",
		lshift = "playerRun",
		lctrl = "editorShortcutModifier",
		lalt = "debugModifier",
		r = "playerReload",
		delete = "editorDelete",
		[" "] = {"playerJump", "menuSelect"},
		f9 = "debugLua",
		f10 = "debugCrash",
		f11 = "screenshot",
		f12 = "grabMouseToggle",
		y = "recordToggle",
	},
	mouseBtns = {
		l = {"playerPrimaryFire", "editorSelect", "editorPaint"},
		m = {"playerReload", "editorDropper"},
		r = {"playerSecondaryFire", "editorContext"},
		wu = {"playerPrevWeapon", "editorPrevBlock", "gameFrameSkipDecrease", "gameBulletTimeDecrease", "debugSpeedDecrease"},
		wd = {"playerNextWeapon", "editorNextBlock", "gameFrameSkipIncrease", "gameBulletTimeIncrease", "debugSpeedIncrease"},
		x1 = "",
		x2 = "",
	},
	useJoystick = false,
	useKeyboard = true,
	useMouse = true,
}