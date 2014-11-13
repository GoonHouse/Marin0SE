entity = class("entity")

entitylist = {	
	{t="remove", category="misc", description="place anywhere - acts as an entity eraser", iconauthor="Assasin-Kiashi"}, --0
	{t="powerup", category="smb stuff", description="place on block - will give either a mushroom or a flower", iconauthor=""},
	{t="cheepcheep", category="smb stuff", description="place on empty tile - red or white cheep cheep", iconauthor="alesan99"},
	{t="musicentity", category="misc", description="place anywhere - takes an input and will play specified music track", iconauthor="idiot9.0"},
	{t="manycoins", category="smb stuff", description="place on a non question mark block - gives several coins", iconauthor="TheCanadianToast"},
	{t="enemyspawner", category="misc", description="place on empty tile - will spawn enemies on input", iconauthor=""},
	{t="animatedtiletrigger", category="i/o objects", description="place anywhere - will animate tiles with the trigger attribute", iconauthor=""},
	{t="spawn", category="level markers", description="place on empty tile - mario's starting point", iconauthor="TripleXero"},
	{t="delayer", category="gates", description="place anywhere - will delay an input", output=true, iconauthor=""},
	{t="rsflipflop", category="gates", description="place anywhere - can be toggled on and off", output=true, iconauthor=""},
	{t="flag", category="level markers", description="place on block - bottom of the flag, end of level", iconauthor="TripleXero"}, --10
	{t="sfxentity", category="misc", description="place anywhere - takes an input and will play specified sound effect", iconauthor="EntranceJew"},
	{t="animationtarget", category="i/o objects", description="place anywhere - sends output when called by animation trigger", output=true, iconauthor="EntranceJew"},
	{t="vine", category="smb stuff", description="place on block - vine - right click to choose destination", iconauthor="Superjustinbros"},
	{t="vinestop", category="smb stuff", description="place anywhere - will stop a vine's growth at this point", iconauthor="alesan99"},
	{t=""},
	{t=""},
	{t="platform", category="smb stuff", description="place on empty tile - oscillating platform", iconauthor="Assasin-Kiashi"},
	{t="regiontrigger", category="i/o objects", description="place anywhere - will output when there's an object in a region", output=true, iconauthor="alesan99"},
	{t=""},
	{t=""}, --20
	{t=""},
	{t="mazestart", category="level markers", description="place anywhere - logical maze start", hidden=not DEBUG, iconauthor=""},
	{t="mazeend", category="level markers", description="place anywhere - logical maze end", hidden=not DEBUG, iconauthor=""},
	{t="mazegate", category="level markers", description="place on empty tile - maze gate", hidden=not DEBUG, iconauthor=""},
	{t="emancipationgrill", category="portal elements", description="place on empty tile - emancipation grill, stops portals and objects other than mario", iconauthor="Assasin-Kiashi"},
	{t="scaffold", category="portal elements", description="place on empty tile - platform with an input", iconauthor=""},
	{t="door", category="portal elements", description="place on empty tile - it's a door. it opens, it closes, it doors.", iconauthor="idiot9.0"},
	{t="pedestal", category="portal elements", description="place on empty tile - portal gun ready for pickup", iconauthor=""},
	{t="wallindicator", category="i/o objects", description="place anywhere - shows on or off state", iconauthor=""},
	{t=""}, --30
	{t="platformfall", category="smb stuff", description="place on empty tile - falling platforms", iconauthor=""},
	{t="pswitch", category="smb stuff", description="place on empty tile or in block", iconauthor=""},
	{t=""},
	{t="drain", category="level markers", description="place at the very bottom in an underwater level - drain, attracts mario down", iconauthor="Bobfan"},
	{t="lightbridge", category="portal elements", description="place on empty tile - light bridge", iconauthor="ChrisGin"},
	{t="portalent", category="misc", description="place on block - create a portal on input", iconauthor="Firaga"},
	{t=""},
	{t="actionblock", category="i/o objects", description="place on empty tile - will create a coinblock style toggle button", output=true, iconauthor=""},
	{t="button", category="portal elements", description="place on empty tile - floor button", output=true, iconauthor=""},
	{t="platformspawner", category="smb stuff", description="place on empty tile - platform spawner", iconauthor=""}, --40
	{t="animationtrigger", category="i/o objects", description="place anywhere - will start an animation when getting an input signal", iconauthor=""},
	{t="groundlight", category="portal elements", description="place anywhere - use to show on/off state", iconauthor="idiot9.0"},
	{t=""},
	{t=""},
	{t=""},
	{t=""},
	{t=""},
	{t="faithplate", category="portal elements", description="place on ground - f-f--fling yourself.", iconauthor="idiot9.0"},
	{t=""},
	{t=""}, --50
	{t="laser", category="portal elements", description="place on empty tile - laser pew pew", iconauthor="Pixelworker"},
	{t="noportal", category="portal elements", description="all portals shot into this region will be destroyed", iconauthor="EntranceJew"},
	{t=""},
	{t=""},
	{t="laserdetector", category="portal elements", description="place on empty tile - will send signal if laser is detected", output=true, iconauthor="QwertymanO07"},
	{t=""},
	{t=""},
	{t=""},
	{t="bulletbill", category="smb stuff", description="place on bulletbill launchers - will make the launcher actually launch bulletbills", iconauthor="Mari0Maker"},
	{t="geldispenser", category="portal elements", description="place on empty tile - will produce gel", iconauthor=""}, --60
	{t=""},
	{t=""},
	{t=""},
	{t=""},
	{t=""},
	{t="boxtube", category="portal elements", description="place on empty tile - will drop an object and remove previous one", iconauthor="Mari0Maker"},
	{t="pushbutton", category="portal elements", description="place on empty tile - will send a toggle signal when used", output=true, iconauthor=""},
	{t=""},
	{t=""},
	{t=""}, --70
	{t=""},
	{t=""},
	{t="walltimer", category="i/o objects", description="place anywhere - will send on signal for a duration", output=true, iconauthor=""},
	{t="generatorbullet", category="smb stuff", description="place anywhere - generates bullet bills", iconauthor="sorrynothing"},
	{t="generatorcheeps", category="smb stuff", description="place anywhere - generates flying cheep cheeps", iconauthor="sorrynothing"},
	{t="generatorflames", category="smb stuff", description="place anywhere - generates bowser's flames", iconauthor="sorrynothing"},
	{t="generatorwind", category="smb stuff", description="place anywhere - generates wind", iconauthor="sorrynothing"},
	{t="castlefire", category="smb stuff", description="place anywhere - rotating fire stick", iconauthor="Assasin-Kiashi"},
	{t="seesaw", category="smb stuff", description="place on empty tile - see-saw", iconauthor="Firaga"},
	{t="warppipe", category="level markers", description="place on block - level warp", iconauthor="BobTheLawyer"}, --80
	{t="squarewave", category="gates", description="place anywhere - sends on signal for x seconds and off signal for y seconds", output=true, iconauthor="crazyal02"},
	{t="lakitoend", category="level markers", description="place anywhere - defines a right border for lakito", iconauthor=""},
	{t="notgate", category="gates", description="place anywhere - turns in input around", output=true, iconauthor="Pixelworker"},
	{t="gel", category="portal elements", description="place on tile - creates gel on this block", iconauthor="MissingWorld"},
	{t="orgate", category="gates", description="place anywhere - or gate", output=true, iconauthor=""},
	{t="andgate", category="gates", description="place anywhere - and gate", output=true, iconauthor="Turtle95"},
	{t="redcoin", category="smb stuff", description="place in air - a red coin to collect", iconauthor="sorrynothing"},
	{t=""},
	{t="bowser", category="level markers", description="place on empty tile preferably on the first block on a bridge with an axe - bowser", iconauthor="renhoek"},
	{t="axe", category="level markers", description="place on empty tile preferably behind a bridge - axe, end of level", output=true, iconauthor="alesan99"}, --90
	{t="platformbonus", category="smb stuff", description="place on empty tile - platform in coin worlds", iconauthor=""},
	{t="spring", category="smb stuff", description="place on empty tile - spring", iconauthor="Firaga"},
	{t=""},
	{t=""},
	{t=""},
	{t=""},
	{t=""},
	{t=""},
	{t="checkpoint", category="level markers", description="place on empty tile - checkpoint - mario will spawn there if he dies after reaching it", iconauthor="TripleXero"},
	{t="ceilblocker", category="level markers", description="place an	ywhere - makes it impossible to jump over the top row of blocks", iconauthor="alesan99"},
	{t=""},
	{t=""},
	{t=""},
	{t="funnel", category="portal elements", description="place on empty tile - portal excursion funnel", iconauthor=""},
	{t=""},
	{t=""},
	{t=""},
	{t="panel", category="portal elements", description="place on block - will probably be removed anyway. todo!", iconauthor=""},
	{t="textentity", category="i/o objects", description="place anywhere - creates a text in the level, supports input", iconauthor=""},
}

outputs = {}
outputsi = {}
for i = 1, #entitylist do
	if entitylist[i].output then
		table.insert(outputs, entitylist[i].t)
		table.insert(outputsi, i)
	end
end

tooltipimages = {}

for i = 1, #entitylist do
	if entitylist[i].t~="" then
		local path = "entitytooltips/" .. entitylist[i].t .. ".png"
		tooltipimages[i] = love.graphics.newImage(path)
	end
end

rightclickmenues = {}

rightclickmenues.seesaw = {
	{t="text", value="distance:"},
	{t="scrollbar", min=2, max=10, step=1, default=7},
	{t="text", value="left height:"},
	{t="scrollbar", min=1, max=10, step=1, default=4},
	{t="text", value="right height:"},
	{t="scrollbar", min=1, max=10, step=1, default=6},
	{t="text", value="platf. width:"},
	{t="scrollbar", min=1, max=10, step=0.5, default=3},
}

rightclickmenues.spawn = {
	{t="text", value="for players:"},
	{t="checkbox", text="all", default="true"},
	{t="checkbox", text="1", default="false"},
	{t="checkbox", text="2", default="false"},
	{t="checkbox", text="3", default="false"},
	{t="checkbox", text="4", default="false"}
}

rightclickmenues.castlefire = {
	{t="text", value="length:"},
	{t="scrollbar", min=1, max=16, step=1, default=6},
	{t="text", value="delay:"},
	{t="scrollbar", min=0.03, max=1, step=0.01, default=0.11},
	{},
	{t="checkbox", text="counter-cw", default="false"}
}

rightclickmenues.walltimer = {
	{t="text", value="time:"},
	{t="scrollbar", min=1, max=10, step=0.01, default=1},
	{},
	{t="linkbutton", value="link power", link="power"}
}

rightclickmenues.delayer = {
	{t="checkbox", text="visible", default="true"},
	{},
	{t="text", value="delay:"},
	{t="scrollbar", min=0.01, max=10, step=0.01, default=1},
	{},
	{t="linkbutton", value="link power", link="power"}
}

rightclickmenues.wallindicator = {
	{t="checkbox", text="reversed", default="false"},
	{t="linkbutton", value="link power", link="power"}
}

rightclickmenues.notgate = {
	{t="checkbox", text="visible", default="true"},
	{},
	{t="linkbutton", value="link in", link="in"}
}

rightclickmenues.rsflipflop = {
	{t="checkbox", text="visible", default="true"},
	{},
	{t="linkbutton", value="link set", link="set"},
	{t="linkbutton", value="link reset", link="reset"}
}

rightclickmenues.orgate = {
	{t="checkbox", text="visible", default="true"},
	{},
	{t="linkbutton", value="link in 1", link="1"},
	{t="linkbutton", value="link in 2", link="2"},
	{t="linkbutton", value="link in 3", link="3"},
	{t="linkbutton", value="link in 4", link="4"}
}

rightclickmenues.andgate = {
	{t="checkbox", text="visible", default="true"},
	{},
	{t="linkbutton", value="link in 1", link="1"},
	{t="linkbutton", value="link in 2", link="2"},
	{t="linkbutton", value="link in 3", link="3"},
	{t="linkbutton", value="link in 4", link="4"}
}

rightclickmenues.musicentity = {
	{t="checkbox", text="visible", default="true"},
	{t="checkbox", text="single use", default="true"},
	{},
	{t="submenu", entries=function() local t = {} for i, v in pairs(musiclist) do table.insert(t, v) end return t end, actualvalue=true, default=1, width=15},
	{},
	{t="linkbutton", value="link trigger", link="trigger"}
}

rightclickmenues.sfxentity = {
	{t="checkbox", text="visible", default="true"},
	{t="checkbox", text="single use", default="true"},
	{},
	{t="submenu", entries=function() local t = {} for i, v in pairs(soundstoload) do table.insert(t, v) end return t end, actualvalue=true, default=1, width=15},
	{},
	{t="linkbutton", value="link trigger", link="trigger"}
}

rightclickmenues.enemyspawner = {
	{t="submenu", entries=function() return {unpack(enemies)} end, actualvalue=true, default=1, width=15},
	{},
	{t="text", value="velocity x:"},
	{t="scrollbar", min=-50, max=50, default=0},
	{t="text", value="velocity y:"},
	{t="scrollbar", min=-50, max=50, default=0},
	{},
	{t="linkbutton", value="link trigger", link="trigger"}
}

rightclickmenues.boxtube = {
	{t="text", value="on load:"},
	{t="checkbox", text="drop box", default="true"},
	{},
	{t="checkbox", text="respawn obj", default="true"},
	{t="text", value="if destroyed"},
	{},
	{t="text", value="object:"},
	{t="submenu", entries=function() return {"box", unpack(enemies)} end, actualvalue=true, default=1, width=15},
	{},
	{t="linkbutton", value="link drop", link="drop"}
}

rightclickmenues.laserdetector = {
	{t="text", value="direction:"},
	{t="directionbuttons", left=true, right=true, up=true, down=true, default="right"}
}

rightclickmenues.pushbutton = {
	{t="text", value="direction:"},
	{t="directionbuttons", left=true, right=true, default="left"},
	{},
	{t="text", value="base:"},
	{t="directionbuttons", left=true, right=true, up=true, down=true, default="down"}
}

rightclickmenues.platformfall = {
	{t="text", value="width:"},
	{t="scrollbar", min=1, max=10, step=0.5, default=3}
}

rightclickmenues.pipe = {
	{t="text", value="destination:"},
	{t="submenu", entries={"main", "sub-1", "sub-2", "sub-3", "sub-4", "sub-5"}, default=1, width=5},
}

rightclickmenues.vine = {
	{t="text", value="destination:"},
	{t="submenu", entries={"main", "sub-1", "sub-2", "sub-3", "sub-4", "sub-5"}, default=1, width=5},
}

rightclickmenues.mazegate = {
	{t="text", value="gatenumber:"},
	{t="submenu", entries={"main", "gate 1", "gate 2", "gate 3", "gate 4", "gate 5"}, default=1, width=6},
}

rightclickmenues.warppipe = {
	{t="text", value="this id:"},
	{t="input", default="1"},
	{},
	{t="text", value="dest map:"},
	{t="input", default="1-1-1"},
	{t="text", value="dest id:"},
	{t="input", default="1"},
	{},
	{t="text", value="enter dir:"},
	{t="directionbuttons", left=true, right=true, up=true, down=true, default="down"},
	{t="text", value="exit dir:"},
	{t="directionbuttons", left=true, right=true, up=true, down=true, default="up"},
	{},
	{t="checkbox", text="is usable", default="true"}, 
	{t="checkbox", text="is sublevel", default="true"}, 
}

rightclickmenues.funnel = {
	{t="text", value="direction:"}, 
	{t="directionbuttons", left=true, up=true, right=true, down=true, default="right"}, 
	{}, 
	{t="text", value="speed:"}, 
	{t="scrollbar", min=funnelminspeed, max=funnelmaxspeed, step=0.01, default=3}, 
	{}, 
	{t="checkbox", text="reverse", default="false"}, 
	{t="checkbox", text="default off", default="false"}, 
	{},
	{t="linkbutton", value="link reverse", link="reverse"},
	{t="linkbutton", value="link power", link="power"}
}

rightclickmenues.emancipationgrill = {
	{t="text", value="direction:"}, 
	{t="directionbuttons", hor=true, ver=true, default="ver"}, 
	{}, 
	{t="checkbox", text="default off", default="false"}, 
	{}, 
	{t="linkbutton", value="link power", link="power"}
}

rightclickmenues.laser = {
	{t="text", value="direction:"}, 
	{t="directionbuttons", left=true, up=true, right=true, down=true, default="right"}, 
	{}, 
	{t="checkbox", text="default off", default="false"}, 
	{}, 
	{t="linkbutton", value="link power", link="power"}
}

rightclickmenues.lightbridge = {
	{t="text", value="direction:"}, 
	{t="directionbuttons", left=true, up=true, right=true, down=true, default="right"}, 
	{}, 
	{t="checkbox", text="default off", default="false"}, 
	{}, 
	{t="linkbutton", value="link power", link="power"}
}

rightclickmenues.platformspawner = {
	{t="text", value="direction:"}, 
	{t="directionbuttons", up=true, down=true, default="up"}, 
	{}, 
	{t="text", value="width:"},
	{t="scrollbar", min=1, max=10, step=0.5, default=3},
	{t="text", value="speed:"},
	{t="scrollbar", min=0.5, max=10, step=0.01, default=3.5},
	{t="text", value="delay:"},
	{t="scrollbar", min=1, max=10, step=0.01, default=2.18}
}

rightclickmenues.platform = {
	{t="text", value="width:"},
	{t="scrollbar", min=1, max=10, step=0.5, default=3},
	{t="text", value="distance x:"},
	{t="scrollbar", min=-15, max=15, step=0.5, default=3.3125},
	{t="text", value="distance y:"},
	{t="scrollbar", min=-15, max=15, step=0.5, default=0},
	{t="text", value="duration:"},
	{t="scrollbar", min=1, max=10, step=0.01, default=4}
}

rightclickmenues.scaffold = {
	{t="text", value="direction:"}, 
	{t="directionbuttons", down=true, left=true, right=true, up=true, default="right"},
	{t="checkbox", text="default off", default="false"}, 
	{t="text", value="width:"},
	{t="scrollbar", min=0.5, max=15, step=0.5, default=3},
	{t="text", value="distance:"},
	{t="scrollbar", min=0.5, max=15, step=0.01, default=3},
	{t="text", value="speed:"},
	{t="scrollbar", min=0.5, max=10, step=0.01, default=5.5},
	{t="text", value="wait start:"},
	{t="scrollbar", min=0, max=10, step=0.01, default=0.5},
	{t="text", value="wait end:"},
	{t="scrollbar", min=0, max=10, step=0.01, default=0.5},
	{t="linkbutton", value="link power", link="power"}
}

rightclickmenues.faithplate = {
	{t="text", value="velocity x:"},
	{t="scrollbar", min=-50, max=50, step=0.01, default=30},
	{t="text", value="velocity y:"},
	{t="scrollbar", min=5, max=50, step=0.01, default=30},
	{},
	{t="checkbox", text="default off", default="false"},
	{},
	{t="linkbutton", value="link power", link="power"}
}

rightclickmenues.door = {
	{t="text", value="direction:"},
	{t="directionbuttons", hor=true, ver=true, default="ver"},
	{},
	{t="checkbox", text="start open", default="false"},
	{t="checkbox", text="force close", default="false"},
	{},
	{t="linkbutton", value="link open", link="open"}
}

rightclickmenues.gel = {
	{t="text", value="type:"},
	{t="submenu", entries=enum_gels, default=1, width=6},
	{},
	{t="text", value="direction:"}, 
	{t="checkbox", text="left", default="false"},
	{t="checkbox", text="top", default="true"},
	{t="checkbox", text="right", default="false"},
	{t="checkbox", text="bottom", default="false"}
}

rightclickmenues.geldispenser = {
	{t="text", value="direction:"}, 
	{t="directionbuttons", left=true, right=true, down=true, up=true, default="down"}, 
	{},
	{t="text", value="type:"},
	{t="submenu", entries=enum_gels, default=1, width=6},
	{},
	{t="checkbox", text="default off", default="false"},
	{},
	{t="linkbutton", value="link power", link="power"}
}

rightclickmenues.panel = {
	{t="text", value="direction:"}, 
	{t="directionbuttons", left=true, up=true, right=true, down=true, default="right"}, 
	{}, 
	{t="checkbox", text="start white", default="false"}, 
	{}, 
	{t="linkbutton", value="link power", link="power"}
}

rightclickmenues.button = {
	{t="text", value="direction:"},
	{t="directionbuttons", left=true, right=true, up=true, down=true, default="down"}
}

rightclickmenues.textentity = {
	{t="input", default="text", max=50},
	{},
	{t="checkbox", text="default off", default="false"},
	{},
	{t="text", value="red:"},
	{t="scrollbar", min=0, max=255, step=1, default=255},
	{t="text", value="green:"},
	{t="scrollbar", min=0, max=255, step=1, default=255},
	{t="text", value="blue:"},
	{t="scrollbar", min=0, max=255, step=1, default=255},
	{},
	{t="text", value="x offset:"},
	{t="scrollbar", min=0, max=16, step=1, default=0},
	{t="text", value="y offset:"},
	{t="scrollbar", min=0, max=16, step=1, default=0},
	{},
	{t="linkbutton", value="link power", link="power"},
}

rightclickmenues.squarewave = {
	{t="text", value="off time"},
	{t="scrollbar", min=0.01, max=10, step=0.01, default=2},
	{t="text", value="on time"},
	{t="scrollbar", min=0.01, max=10, step=0.01, default=2},
	{},
	{t="text", value="wave offset"},
	{t="scrollbar", min=0, max=1, step=0.01, default=0},
	{},
	{t="checkbox", text="visible", default="true"}
}

rightclickmenues.regiontrigger = {
	{t="text", value="trigger on:"},
	{t="checkbox", text="players", default="true"},
	{t="checkbox", text="enemies", default="true"},
	{},
	{t="regionselect", value="select region", region="region", default="region:0:0:1:1"}
}

rightclickmenues.noportal = {
	{t="text", value="allow:"},
	{t="checkbox", text="shooting", default="false"},
	{},
	{t="regionselect", value="select region", region="region", default="region:0:0:1:1"}
}

rightclickmenues.animationtrigger = {
	{t="text", value="animation id"},
	{t="input", default="myanim", max=12},
	{},
	{t="linkbutton", value="link in", link="in"}
}

rightclickmenues.animationtarget = {
	{t="text", value="target name"},
	{t="input", default="mytarget", max=12},
}

rightclickmenues.animatedtiletrigger = {
	{t="checkbox", text="visible", default="true"},
	{},
	{t="regionselect", value="select tiles", region="region", default="region:0:0:1:1"},
	{},
	{t="linkbutton", value="link trigger", link="trigger"}
}

rightclickmenues.checkpoint = {
	{t="text", value="for players:"},
	{t="checkbox", text="all", default="true"},
	{t="checkbox", text="1", default="false"},
	{t="checkbox", text="2", default="false"},
	{t="checkbox", text="3", default="false"},
	{t="checkbox", text="4", default="false"},
	{t="checkbox", text="the rest", default="false"},
	{},
	{t="checkbox", text="visible", default="false"},
	{},
	{t="regionselect", value="select region", region="region", default="region:0:0:1:1"},
	{},
	{t="linkbutton", value="link trigger", link="trigger"}
}

rightclickmenues.portalent = {
	{t="text", value="type:"},
	{t="submenu", entries={"blue", "orange"}, default=1, width=6},
	{},
	{t="text", value="direction:"}, 
	{t="directionbuttons", left=true, right=true, down=true, up=true, default="up"}, 
	{},
	{t="text", value="portal id:"},
	{t="submenu", entries={"1", "2", "3", "4", "5", "6", "7", "8"}, default=1, width=1},
	{},
	{t="checkbox", text="default on", default="false"},
	{},
	{t="linkbutton", value="link power", link="power"}
}

rightclickmenues.pedestal = {
	{t="text", value="portal:"},
	{t="checkbox", text="blue", default="true"},
	{t="checkbox", text="orange", default="true"}
}

rightclickmenues.spring = {
	{t="text", value="type:"},
	{t="submenu", entries={"regular", "high"}, default=1, width=7, actualvalue=true}
}

rightclickmenues.groundlight = {
	{t="text", value="type:"},
	{t="submenu", entries={"vertical", "horizontal", "upright", "rightdown", "downleft", "leftup"}, default=2, width=10},
	{},
	{t="checkbox", text="default on", default="false"},
	{},
	{t="linkbutton", value="link power", link="power"}
}

rightclickmenues.redcoin = {
	{t="text", value="value:"},
	{t="scrollbar", min=1, max=5, step=1, default=1},
	{},
	{t="text", value="size:"},
	{t="submenu", entries={"small", "tallthin", "large"}, default=1, width=8, actualvalue=true},
}

rightclickmenues.axe = {
	{t="text", value="value:"},
	{t="scrollbar", min=1, max=5, step=1, default=1},
	{},
	{t="text", value="size:"},
	{t="submenu", entries={"small", "tallthin", "large"}, default=1, width=8, actualvalue=true},
}

rightclickmenues.pswitch = {
	{t="text", value="type:"},
	{t="submenu", entries={"blue", "grey"}, default=1, width=4, actualvalue=true},
	{},
	{t="checkbox", text="reuse:", default="false"},
	{t="checkbox", text="carry:", default="false"}
}

rightclickmenues.generatorwind = {
	{t="text", value="direction:"},
	{t="submenu", entries={"right", "left"}, default=1, width=5, actualvalue=true},
	{},
	{t="text", value="intensity:"},
	{t="scrollbar", min=1, max=10, step=1, default=6},
	{},
	{t="regionselect", value="select region", region="region", default="region:0:0:1:1"}
}

rightclickmenues.generatorbullet = {
	{t="regionselect", value="select region", region="region", default="region:0:0:1:1"}
}

rightclickmenues.generatorcheeps = {
	{t="regionselect", value="select region", region="region", default="region:0:0:1:1"}
}

rightclickmenues.generatorflames = {
	{t="regionselect", value="select region", region="region", default="region:0:0:1:1"}
}

function entity:init(img, x, y, width, height)
	self.image = img
	if type(x)~="number" then
		self.quad = x
	else
		self.quad = love.graphics.newQuad((x-1)*17, (y-1)*17, 16, 16, width, height)
	end
end

function entity:sett(i)
	for j = 1, #entitylist do
		if i == j then
			self.t = entitylist[j].t
		end
	end
end

entityquad_overloads = {} --this is for overloading whatever is done to entityquads because we can't use it normally