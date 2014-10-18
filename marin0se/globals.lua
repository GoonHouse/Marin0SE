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
		e = {"editorErase"},
		up = {"menuUp", "editorScrollUp"},
		left = {"menuLeft", "editorScrollLeft"},
		m = {"gameShortcutMappackFolder"},
		down = {"menuDown", "editorScrollDown"},
		right = {"menuRight", "editorScrollRight"},
		k = {"editorQuickSave", "replaySave"},
		--(key == "return" or key == "enter" or key == "kpenter" or key == " ")
		["return"] = "menuSelect",
		tab = "menuNextElement", --unimplemented
		f = {"playerUse", "debugEmbiggen"},
		escape = {"playerPause", "menuBack"},
		--l = "playerSuicide",
		t = {"editorToggle", "editorTestLevel"},
		lshift = {"playerRun", "debugModifier"},
		lctrl = "editorShortcutModifier",
		--lalt = "debugModifier", --Until love 0.9.2 or 0.10.0 we can't use alt on Windows-based machines. :(
		r = "playerReload",
		delete = "editorDelete",
		[" "] = {"playerJump", "menuSelect"},
		f9 = "debugLua",
		f10 = "debugCrash",
		f11 = "gameScreenshot",
		f12 = "gameGrabMouseToggle",
		y = "recordToggle",
		
		["1"] = "editorTilesAll",
		--["2"] = "editorTilesSMB",
		--["3"] = "editorTilesPortal",
		--["4"] = "editorTilesCustom",
		["2"] = "editorTilesAnimated",
		["3"] = "editorTilesEntities",
		["4"] = "editorTilesEnemies",
	},
	mouseBtns = {
		l = {"playerPrimaryFire", "editorSelect", "editorPaint"},
		m = {"playerReload", "editorDropper"},
		r = {"playerSecondaryFire", "editorContext"},
		wu = {"playerPrevWeapon", "editorPrevBlock", "gameFrameSkipDecrease", "gameBulletTimeDecrease", "debugSpeedDecrease"},
		wd = {"playerNextWeapon", "editorNextBlock", "gameFrameSkipIncrease", "gameBulletTimeIncrease", "debugSpeedIncrease"},
		x1 = "", --mouse4
		x2 = "", --mouse5
	},
	joyBtns = {
		[1] = { -- first controller
			[1] = {--[["playerUp",]] "menuUp", "editorNudgeUp"}, -- xbox povup
			[2] = {--[["playerDown",]] "menuDown", "editorNudgeDown"}, -- xbox povdown
			[3] = {--[["playerLeft",]] "menuLeft", "editorNudgeLeft", "playerPrevWeapon", "editorPrevBlock", "gameFrameSkipDecrease", "gameBulletTimeDecrease", "debugSpeedDecrease"}, -- xbox povleft
			[4] = {--[["playerRight",]] "menuRight", "editorNudgeRight", "playerNextWeapon", "editorNextBlock", "gameFrameSkipIncrease", "gameBulletTimeIncrease", "debugSpeedIncrease"}, -- xbox povright
			[5] = {"playerPause"}, -- xbox start
			[6] = {"menuBack"}, -- xbox back
			[7] = {"playerRun"}, -- xbox leftstickclick
			[8] = {"playerJump"}, -- xbox rightstickclick
			[9] = {"playerRun"}, -- xbox lbumper
			[10] = {"playerJump"}, -- xbox rbumper
			[11] = {"menuSelect", "playerJump"}, -- xbox A
			[12] = {"menuBack", "playerUse"}, -- xbox B
			[13] = {"playerRun"}, -- xbox X
			[14] = {"playerReload", "editorDropper"}, -- xbox Y
			[15] = {}, -- xbox home
		},
	},
	--[[joyAxes = {
		[1] = {
			[1] = { -- xbox left X
				"leftx",
			},
			[2] = { -- xbox left Y
				"lefty",
			},
			[3] = { -- xbox right X
				"rightx",
			},
			[4] = { -- xbox right Y
				"righty",
			},
			[5] = { -- xbox left trigger
				"lefttrigger",
			},
			[6] = { -- xbox right trigger
				"righttrigger",
			},
		},
	},]]
	pairedAxes = {
		[1] = {
			[1] = {1, 2},
			[2] = {3, 4},
			[3] = {5, 6},
		},
	},
	deadzoneAxes = {
		[1] = {
			[1] = "playerMoveX", -- xbox left X
			[2] = "playerMoveY", -- xbox left Y
			[3] = "playerAimX", -- xbox right X
			[4] = "playerAimY", -- xbox right Y
			[5] = "playerPressureLeft", -- xbox left trigger
			[6] = "playerPressureRight", -- xbox right trigger
		},
	},
	maps = {
		--a       --d
		playerMoveX = {
			--h=0 --o={}
			{"playerLeft", "menuLeft", "editorNudgeLeft"},
			{"playerRight", "menuRight", "editorNudgeRight"},
		},
		playerMoveY = {
			{"playerUp", "menuUp", "editorNudgeUp"},
			{"playerDown", "menuDown", "editorNudgeDown"},
		},
		playerAimX = {
			{"editorScrollLeft"},
			{"editorScrollRight"},
		},
		playerAimY = {
			{"editorScrollUp"},
			{"editorScrollDown"},
		},
		playerPressureLeft = {
			{},
			{"playerPrimaryFire", "editorSelect", "editorPaint"},
		},
		playerPressureRight = {
			{},
			{"playerSecondaryFire", "editorContext"},
		},
	},
	--[[deadzoneAxes = {
		[1] = {
			
		},
	},]]
	deadzone = 0.3,
	useJoystick = true,
	useKeyboard = true,
	useMouse = true,
}