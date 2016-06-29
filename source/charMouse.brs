' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **  Created: February 2016
' **  Updated: June 2016
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateMouse(level as object, room as integer, position as integer, face as integer) as object
    this = {}
    'constants
    this.const = m.const
    'sprites and animations
    this.scale = m.scale
    this.spriteMode = m.settings.spriteMode
    this.animations = ParseJson(ReadAsciiFile("pkg:/assets/anims/mouse.json"))
    'inherit generic Actor properties and methods
    ImplementActor(this, room, position, face, "mouse")
    'properties
    this.level = level
    this.charName = "mouse"
    this.gameWidth = m.gameWidth / m.scale
    this.gameHeight = m.gameHeight / m.scale
    this.frame = 1
    this.frameName = "mouse-1"
    this.haveSword = false
    this.meet = false
    this.visible = true

    this.baseX  = level.rooms[room].x * this.const.ROOM_WIDTH
    this.baseY  = level.rooms[room].y * this.const.ROOM_HEIGHT

    this.health = 1

    'methods
    this.update = update_mouse
    this.processCommand = process_command_actor

    return this
End Function

Function update_mouse()
    m.processCommand()
    m.checkFloor()
    m.updatePosition()
End Function
