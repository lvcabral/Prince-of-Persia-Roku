' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: May 2016
' **  Updated: July 2016
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateCutscene(level as integer, scale as float) as object
	this = {}
	'Constants
	this.const = m.const
	this.STATE_WAITING = 0
	this.STATE_RUNNING = 1
	this.STATE_FADEOUT = 2
	'Scene script properties
	this.level = level
	this.scale = scale
	print "Loading cut scene:"; this.level
    sceneJson = ParseJson(ReadAsciiFile("pkg:/assets/scenes/scene" + itostr(this.level) + ".json"))
	if sceneJson <> invalid
		this.program = sceneJson.program
	else
		return invalid
	end if
	this.actors = []
	this.objects = []
	this.trobs = []
	this.pc = 0
	this.waitingTime = 0
	this.sceneState = this.STATE_RUNNING
	this.flash = false
	this.tick = 0
	'Scene regions and objects
	if m.settings.spriteMode = m.const.SPRITES_MAC
		this.objects.Push(CreateTorch(35, 86))
		this.objects.Push(CreateTorch(247, 86))
		starPositions = []
		starPositions.Append([{ x: 8, y: 104 },{ x: 10, y: 120 },{ x: 100, y: 113 },{ x: 115, y: 115 },{ x: 120, y: 100 }])
		starPositions.Append([{ x: 151, y: 105 },{ x: 159, y: 113 },{ x: 170, y: 102 },{ x: 220, y: 108 },{ x: 208, y: 113 }])
		starPositions.Append([{ x: 206, y: 97 },{ x: 258, y: 110 },{ x: 270, y: 100 },{ x: 275, y: 112 }])
	else
		this.objects.Push(CreateTorch(53, 81))
		this.objects.Push(CreateTorch(171, 81))
		starPositions = [{ x: 20, y: 97 },{ x: 16, y: 104 },{ x: 23, y: 110 },{ x: 17, y: 116 },{ x: 24, y: 120 },{ x: 18, y: 128 }]
	end if
	for each position in starPositions
		this.objects.Push( CreateStar(position.x, position.y) )
	next
	'Method
	this.executeProgram = execute_program
	return this
End Function

Sub execute_program()
	if m.sceneState = m.STATE_WAITING
		m.waitingTime = m.waitingTime - 1
		if m.waitingTime = 0
			m.sceneState = m.STATE_RUNNING
		end if
	end if
	while m.sceneState = m.STATE_RUNNING
		opcode = m.program[m.pc]
		if opcode.i = "START"
			'm.sceneState = m.STATE_FADEIN
		else if opcode.i = "END"
			m.sceneState = m.STATE_FADEOUT
		else if opcode.i = "ACTION"
			actor = m.actors[opcode.p1]
            if actor <> invalid
				actor.action(opcode.p2)
			end if
		else if opcode.i = "ADD_ACTOR"
			m.actors.Push(CreateActor(opcode.p3, opcode.p4, opcode.p5, opcode.p2, m.scale))
		else if opcode.i = "REM_ACTOR"
			m.actors[opcode.p1].sprite.Remove()
			m.actors[opcode.p1] = invalid
		else if opcode.i = "ADD_OBJECT"
			m.trobs.Push(CreateClock(opcode.p3, opcode.p4, opcode.p2))
		else if opcode.i = "START_OBJECT"
			m.trobs[opcode.p1].activate()
		else if opcode.i = "EFFECT"
			m.flash = true
		else if opcode.i = "WAIT"
			m.sceneState = m.STATE_WAITING
			m.waitingTime = opcode.p1
		else if opcode.i = "PLAY_SONG"
			PlaySong(opcode.p1)
		else if opcode.i = "PLAY_SOUND"
			PlaySound(opcode.p1)
		end if
		m.pc++
	end while
End Sub
