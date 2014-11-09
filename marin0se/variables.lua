--DELIMITERS old: ,-;*=   new: ¤×¸·¨
BLOCKDELIMITER = "¤"
LAYERDELIMITER = "×"
CATEGORYDELIMITER = "¸"
MULTIPLYDELIMITER = "·"
EQUALSIGN = "¨"

--SETABLE VARS--	
--almost all vars are in "blocks", "blocks per second" or just "seconds". Should be obvious enough what's what.
portalgundelay = 0.2
gellifetime = 2
bulletbilllifetime = 20
playertypelist = {"portalgun", "gelcannon"}
gameplaytypelist = {"na", "vanilla", "oddjob"}
help_tips = { "i love men", "this is a helpful tip i promise", "flabberific", "beware of gaping buttholes", "first jo is best jo", "cake is a lie joke ban me", "that was easy", "george lucas is an asshole", "what the fuck is wrong with his neck", "now with more hints", "shoot it until it dies", "watashi wa desu", "naah he-man"}
help_tipi = 1

latetable = {"portalwall", "castlefirefire", "platform"}
-- the above is used in physics.lua to calculate late physics entities

newpoweruproutine=true --makes it so that if mario touches a "tier2" powerup he skips bigmario ala nsmb
powerupstates = {
	"death", --this bypasses the powerup chain processing and kills mario instantly
	"hurt",  --causes mario to simply be hurt, you shouldn't use this as a powerdowntarget
	"small", --mario spawns with this
	"super", --mario after getting a mushroom
	"fire",  --mario after getting a flower
}

numgeltypes=6
enum_gels = {"blue", "orange", "white", "purple", "water", "black"}
gelsthattarnishmirrors = {"blue", "orange", "white", "purple", "black"}

spawnarea = {1, 1, 1, 1}

joystickdeadzone = 0.2
joystickaimdeadzone = 0.5

walkacceleration = 8 --acceleration of walking on ground
runacceleration = 16 --acceleration of running on ground
walkaccelerationair = 8 --acceleration of walking in the air
runaccelerationair = 16 --acceleration of running in the air
minspeed = 0.7 --When friction is in effect and speed falls below this, speed is set to 0
maxwalkspeed = 6.4 --fastest speedx when walking
maxrunspeed = 9.0 --fastest speedx when running
friction = 14 --amount of speed that is substracted when not pushing buttons, as well as speed added to acceleration when changing directions
superfriction = 100 --see above, but when speed is greater than maxrunspeed
frictionair = 0 --see above, but in air
airslidefactor = 0.8 --multiply of acceleration in air when changing direction

damage_types = {
	"toilet",		--if this happens, something had an undefined kill type, mostly for bug finding
	"kill",			--generic, this happens as a fallback for icon purposes (skull & crossbones)
	
	"physics",		--box crushes enemy, or other deaths caused by inaction
	
	"stomp",		--when feet land on something's head, sometimes side-kicks
	"shell",		--shells from koopas
	"star",			--reflective rampage man
	"fireball",		--the projectiles that come out of the player's hands
	
	"touch",		--goombas and any other oddly threatining simpletons
	"bump", 		--hit by the underside of a block
	"suicide",		--generic self-kill
	"pit",			--fell off screen boundary
	"spike",		--landed on a sharp block
	"tailspin",		--spinning as a raccoon
	"spin",			--I'm not sure when/where this happens nor if it differs from tailspin
	"pow",			--kill everything on the screen
	"laser",		--giant red light dissolves flesh and patience
}

combo_enums = {
	stomp = {100, 200, 400, 500, 800, 1000, 2000, 4000, 5000, 8000},
	shell = {500, 800, 1000, 2000, 4000, 5000, 8000},
}

score_enum = {
	block_break			= 50,	--for when mario gets bricky
	generic				= 100,	--reward people for doing things we're not even aware of!
	underside_bump		= 100,	--killing something with our heads, with a block as the medium
	generic_firepoints	= 200,	--for when an enemy has no sense of self-worth
	coin				= 200,	--for every individual coin we get
	collect_star		= 1000, --good job
}

enemy_score_enum = {
	fireball = {
		goomba = 100,
		koopa = 200,
		plant = 200,
		bowser = 5000,
		squid = 200,
		cheep = 200,
		flyingfish = 200,
		hammerbro = 1000,
		lakito = 200,
		bulletbill = 200,
	},
	--star scores are identical, but, now we have an opportunity to change that
	star = {
		goomba = 100,
		koopa = 200,
		plant = 200,
		bowser = 5000,
		squid = 200,
		cheep = 200,
		flyingfish = 200,
		hammerbro = 1000,
		lakito = 200,
		bulletbill = 200,
	},
}


yacceleration = 80 --gravity
mariogravity = yacceleration
yaccelerationjumping = 30 --gravity while jumping (Only for mario)
maxyspeed = 100 --SMB: 14
jumpforce = 16
jumpforceadd = 1.9 --how much jumpforce is added at top speed (linear from 0 to topspeed)
headforce = 2 --how fast mario will be sent back down when hitting a block with his head
bounceheight = 14/16 --when jumping on enemy, the height that mario will fly up
passivespeed = 4 --speed that mario is moved against the pointing direction when inside blocks (by crouch sliding under low blocks and standing up for example)

--Variables that are different for underwater

uwwalkacceleration = 8
uwrunacceleration = 16
uwwalkaccelerationair = 8
uwmaxairwalkspeed = 5
uwmaxwalkspeed = 3.6
uwmaxrunspeed = 5
uwfriction = 14
uwsuperfriction = 100
uwfrictionair = 0
uwairslidefactor = 0.8
uwjumpforce = 5.9
uwjumpforceadd = 0
uwyacceleration = 9
uwyaccelerationjumping = 12

waterdamping = 0.2
waterjumpforce = 13

uwmaxheight = 2.5
uwpushdownspeed = 3

bubblesmaxy = 2.5
bubblesspeed = 2.3
bubblesmargin = 0.5
bubblestime = {1.2, 1.6}

gelmaxrunspeed = 50
gelmaxwalkspeed = 25
gelrunacceleration = 25
gelwalkacceleration = 12.5

uwgelmaxrunspeed = 50
uwgelmaxwalkspeed = 12.5
uwgelrunacceleration = 12.5
uwgelwalkacceleration = 6.25

horbouncemul = 1.5
horbouncespeedy = 20
horbouncemaxspeedx = 15
horbounceminspeedx = 2

--items
mushroomspeed = 3.6
mushroomtime = 0.7 --time until it fully emerged out the block
mushroomjumpforce = 13
starjumpforce = 13
staranimationdelay = 0.04
mariostarblinkrate = 0.08 --/disco
mariostarblinkrateslow = 0.16 --/disco
mariostarduration = 12
mariostarrunout = 1 --subtracts, doesn't add.

bowseranimationspeed = 0.5
bowserspeedbackwards = 1.875
bowserspeedforwards = 0.875
bowserjumpforce = 7--v
bowsergravity = 10.9--v
bowserjumpdelay = 1
bowserfallspeed = 8.25--v said "for animation" but still limited bowser all the time

bowserhammertable = {0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.5, 1, 2, 1}--v
bowserhammerdrawtime = 0.5--v as throwpreparetime?

bowserhealth = 5--v

platformverdistance = 8.625
platformhordistance = 3.3125
platformvertime = 6.4
platformhortime = 4
platformbonusspeed = 3.75

platformspawndelay = 2.18 --time between platform spawns

platformjustspeed = 3.5

seesawspeed = 4
seesawgravity = 30
seesawfriction = 4

-- loiters between 4 blocks behind and 4 blocks ahead of you (total 9 blocks he goes above)
-- spawns only 3 of the hedgehog things and then hides until they're offscreen/dead
-- in 4-1 he disappears when you touch the first step (not stand on, touch from side while on the ground)
-- can be killed by single fireflower
-- the spiky dudes turn towards you after they fall down

maxfireballs = 2
fireanimationtime = 0.11

shotspeedx = 4 --X speed (constant) of fire/shell killed enemies
shotjumpforce = 8 --initial speedy (negative) when shot
shotgravity = 60 --how fast enemies that have been killed by fire or shell accellerate downwards

deathanimationjumpforce = 17
deathanimationjumptime = 0.3
deathgravity = 40
deathtotaltime = 4

portalanimationcount = 6 --frame count of portal animation
portalanimation = 1
portalanimationtimer = 0
portalanimationdelay = 0.08 --frame delay of portal animation
portalrotationalignmentspeed = 15 --how fast things return to a rotation of 0 rad(-ical)

scrollrate = 5
superscrollrate = 40
maxscrollrate = maxrunspeed*2
blockbouncetime = 0.2
blockbounceheight = 0.4
coinblocktime = 0.3
coinblockdelay = 0.5/30

runanimationspeed = 10
swimanimationspeed = 10

spriteset = 1
speed = 1
speedtarget = 1
speedmodifier = 10

portalparticlespeed = 1
portalparticletimer = 0
portalparticletime = 0.05
portalparticleduration = 0.5

portaldotstime = 0.8
portaldotsdistance = 1.2
portaldotsinner = 10
portaldotsouter = 70

portalprojectilespeed = 100
portalprojectilesinemul = 100
portalprojectiledelay = 2
portalprojectilesinesize = 0.3
portalprojectileparticledelay = 0.002

emanceparticlespeed = 3
emanceparticlespeedmod = 0.3
emanceimgwidth = 64
emancelinecolor = {100, 100, 255, 10}

boxfriction = 20
boxfrictionair = 0

faithplatetime = 0.3

spacerunroom = 1.2/16 --How far you can fall but still be allowed onto the top of a block (For running over 1 tile wide gaps)

doorspeed = 2
groundlightdelay = 1

geldispensespeed = 0.05
gelmaxspeed = 30

cubedispensertime = 1

pushbuttontime = 1

bulletbillspeed = 8.0
bulletbilltimemax = 4.5
bulletbilltimemin = 1.0
bulletbillrange = 3

hammerbropreparetime = 0.5
hammerbrotime = {0.6, 1.6}
hammerbrospeed = 1.5
hammerbroanimationspeed = 0.15


hammerbrojumptime = 3
hammerbrojumpforce = 19
hammerbrojumpforcedown = 6


hammerspeed = 4
hammerstarty = 8
hammergravity = 25
hammeranimationspeed = 0.05

squidfallspeed = 0.9
squidxspeed = 3
squidupspeed = 3
squidacceleration = 10
squiddowndistance = 1

firespeed = 4.69
fireverspeed = 2
fireanimationdelay = 0.05

upfireforce = 19
upfiregravity = 20

flyingfishgravity = 20
flyingfishforce = 23

userange = 1
usesquaresize = 1

castlefireangleadd = 1.125
castlefiredelay = .34/(360/castlefireangleadd) --the number in front of the bracket is how long a full turn takes
castlefireanimationdelay = 0.07

--plants
plantintime = 1.8
plantouttime = 2
plantanimationdelay = 0.15
plantmovedist = 23/16
plantmovespeed = 2.3

vinespeed = 2.13
vinemovespeed = 3.21
vinemovedownspeed = vinemovespeed*2
vineframedelay = 0.15
vineframedelaydown = vineframedelay/2

vineanimationstart = 4
vineanimationgrowheight = 6
vineanimationmariostart = vineanimationgrowheight/vinespeed
vineanimationstop = 1.75
vineanimationdropdelay = 0.5

--animationstuff
pipeanimationtime = 0.7
pipeanimationdelay = 1
pipeanimationdistancedown = 32/16
pipeanimationdistanceright = 16/16
pipeanimationrunspeed = 3
pipeupdelay = 1

growtime = 0.9
shrinktime = 0.9
growframedelay = 0.08
shrinkframedelay = 0.08
invicibleblinktime = 0.02
invincibletime = 3.2

blinktime = 0.5

levelscreentime = 2.4 --2.4
gameovertime = 7
blacktimesub = 0.1
sublevelscreentime = 0.2

--flag animation
flagclimbframedelay = 0.07
scoredelay = 2
flagdescendtime = 0.9
flagydistance = 7+10/16
flaganimationdelay = 0.6
scoresubtractspeed = 1/60
castleflagstarty = 1.5
castleflagspeed = 3
castlemintime = 7
fireworkdelay = 0.55
fireworksoundtime = 0.2
endtime = 2

--smokepuff
smokepuffdelay = 0.55
smokepuffoundtime = 0.2

--spring
springtime = 0.2
springhighforce = 41 --Regular Springboard
springhighhighforce = 190 --High Springboard
springforce = 24
springytable = {0, 0.5, 1}

--flag scores and positions
flagscores = {100, 400, 800, 2000, 5000}
flagvalues = {9.8125, 7.3125, 5.8125, 2.9375}

--castle win animation
castleanimationchaindisappear = 0.38 --delay from axe disappearing to chain disappearing; once this starts, bowser starts tapping feet with a delay of 0.0666666
castleanimationbowserframedelay = 0.0666
castleanimationbridgedisappeardelay = 0.06 --delay between each bridge block disappearing, also delay between chain and first block
--bowser starts falling and stops moving immediately after the last block disappears
castleanimationmariomove = 1.07 --time when mario starts moving after bowser starts falling and is also unfrozen. music also starts playing at this point
castleanimationcameraaccelerate = 1.83 -- time when camera starts moving faster than mario, relative to start of his move
castleanimationmariostop = 2.3 -- when mario stops next to toad, relative to start of his move
castleanimationtextfirstline = 3.2 -- when camera stops and first line of text appears, relative to the start of his move
castleanimationtextsecondline = 5.3 --second line appears
castleanimationnextlevel = 9.47 -- splash screen for next level appears

endanimationtextfirstline = 3.2 -- when camera stops and first line of text appears, relative to the start of his move
endanimationtextsecondline = 7.4 --second line appears
endanimationtextthirdline = 8.4 --third line appears
endanimationtextfourthline = 9.4 --fourth line appears
endanimationtextfifthline = 10.4 --fifth line appears
endanimationend = 12 -- user can press any button

drainspeed = 20
drainmax = 10

konamilength = 10
konamihash = "7d0b25cc0abdcc216e9f26b078c0cb5c9032ed8c"
konamitable = {}
for i = 1, konamilength do
	konamitable[i] = ""
end

earthquakespeed = 40

cheats_active = {
	rainboom = true,
	goombaattack = false,
	bigmario = false,
	bullettime = false,
	portalknockback = false,
	playercollisions = false,
	infinitetime = false,
	infinitelives = false,
}
scalefactor = 5
gelcannondelay = 0.05
gelcannonspeed = 30

pausemenuoptions = {"resume", "suspend", "volume", "quit to", "quit to"}
pausemenuoptions2 = {"", "", "", "menu", "desktop"}

guirepeatdelay = 0.07
mappackhorscrollrange = 220

maximumbulletbills = 5
coinblocktime = 4

funnelspeed = 3
funnelforce = 5
funnelmovespeed = 4
excursionbaseanimationtime = 0.1
funnelbuildupspeed = 50

yscrollingrate = 10
userscrolltime = 1
userscrollspeed = 13
userscrollrange = 5

--Rightclickmenu values
funnelminspeed = 1
funnelmaxspeed = 10

linktoolfadeouttimefast = 0.1
linktoolfadeouttimeslow = 0.5

pedestaltime = 1

--Functions, functions everywhere.

--[[ Oh noes this shit sucks
platformwidthfunction = function (i) return math.floor(i*18+2)/2 end
platformspeedfunction = function (i) return i*9.5+0.5 end	
platformspawndelayfunc = function (i) return i*9+1 end

scaffoldwidthfunction = function (i) return math.floor(i*18+2)/2 end
scaffoldspeedfunction = function (i) return i*9.5+0.5 end
scaffolddistancefunction = function (i) return i*14.5+.5 end
scaffoldtimefunction = function (i) return i*10 end

faithplatexfunction = function (i) return (i-.5)*100 end
faithplateyfunction = function (i) return i*45+5 end

timerfunction = function (i) return i*9+1 end

seesawdistancefunction = function (i) return math.floor(i*8+2) end
seesawheightfunction = function (i) return math.floor(i*9+1) end

castlefirelengthfunction = function (i) return math.floor(i*15+1) end
castlefiredelayfunction = function (i) return i*0.97+0.03 end

rgbfunction = function (i) return math.floor(i*255) end

squarewavetimefunction = function (i) return i*9.9+0.1 end

upfireheightfunction = function (i) return i*14.5+.5 end
upfirewaitfunction = function (i) return i*5.9+.1 end
upfirerandomfunction = function (i) return i*6 end

platformdistancefunction = function (i) return i*14.5+.5 end
platformtimefunction = function (i) return i*9+1 end 
--]]

arcadeexittime = 2
arcadeblinkrate = 1.7
arcadetimeout = 15

raccoonstarttime = 1
raccoontime = 4
raccoonascendspeed = 8
raccoonbuttondelay = 0.25
raccoondescendspeed = 4
raccoontailwagdelay = 0.08
raccoonspindelay = 0.1

scrollingstart = width/2 --when the scrolling begins to set in (Both of these take the player who is the farthest on the left)
scrollingcomplete = width/2-width/10 --when the scrolling will be as fast as mario can run
scrollingleftstart = width/3 --See above, but for scrolling left, and it takes the player on the right-estest.
scrollingleftcomplete = width/3-width/10
upscrollborder = 4
downscrollborder = 4
superscroll = 100
portaldotstimer = 0

pswitchtime = 20