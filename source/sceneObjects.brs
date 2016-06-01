' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: February 2016
' **  Updated: May 2016
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateClock(x as integer, y as integer, state as integer) as object
    this = {}
    this.x = x
    this.y = y
    this.child = {x: 8, y: 16, visible: false }
    this.sandStep = 0
    this.clockStep = state
    this.step = 0
	this.sandFrames = GenerateFrameNames("clocksand0", 1, 3, "", false)
	this.clockFrames = GenerateFrameNames("clock0", 1, 7, "", false)
    this.frameName = this.clockFrames[this.clockStep]
    this.child.frameName = this.sandFrames[this.sandStep]
    this.visible = true
    this.active = false
    'Methods
    this.update = update_clock
    this.activate = activate_clock
    return this
End Function

Sub update_clock()
    if m.active
        m.sandStep = (m.sandStep + 1) Mod 3
        m.child.frameName = m.sandFrames[m.sandStep]
        m.step = m.step + 1
        if m.step = 40
            m.clockStep = (m.clockStep + 1) Mod 7
            m.frameName = m.clockFrames[m.clockStep]
            m.step = 0
        end if
    end if
End Sub

Sub activate_clock()
    m.active = true
    m.child.visible = true
End Sub

'------ Scene Star Object

Function CreateStar(x as integer, y as integer) as object
	this = {}
    'properties
    this.x = x
    this.y = y
    this.state = 1
    this.frameName = "star1"
    'method
    this.update = update_star
    return this
End Function

Sub update_star()
	stage = Rnd(10)
	if stage = 1
		if m.state > 0 then m.state = m.state - 1
	else if stage = 2
		if m.state < 2 then m.state = m.state + 1
    end if
    m.frameName = "star" + itostr(m.state)
End Sub

'------ Scene Torch Object

Function CreateTorch(x as integer, y as integer)
    return { frames: GenerateFrameNames("fire_", 1, 9, "", true), x: x + 40, y: y + 18}
End Function
