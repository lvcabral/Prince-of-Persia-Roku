' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **  Created: May 2016
' **  Updated: July 2016
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateGuard(level as object, room as integer, position as integer, face as integer, skill as integer, name as string, colors as integer, active, visible) as object
    this = {}
    'constants
    this.const = m.const
    'indexed by Skill
    if m.settings.spriteMode = m.const.SPRITES_DOS ' DOS 1.0 port used some assembly hex values as octal
        this.const.STRIKE_PROBABILITY      = [  61, 100,  61,  61,  61,  40, 100, 220, 0,  48,  32,  48 ]
        this.const.RESTRIKE_PROBABILITY    = [   0,   0,   0,   5,   5, 175,  16,   8, 0, 255, 255, 150 ]
        this.const.IMPAIRBLOCK_PROBABILITY = [   0,  61,  61, 100, 100, 145, 100, 250, 0, 145, 255, 175 ]
        this.const.REFRAC_TIMER            = [  16,  16,  16,  16,   8,   8,   8,   8, 0,   8,   0,   0 ]
    else
        this.const.STRIKE_PROBABILITY      = [  75, 100,  75,  75,  75,  50, 100, 220, 0,  60,  40,  60 ]
        this.const.RESTRIKE_PROBABILITY    = [   0,   0,   0,   5,   5, 175,  20,  10, 0, 255, 255, 150 ]
        this.const.IMPAIRBLOCK_PROBABILITY = [   0,  75,  75, 100, 100, 145, 100, 250, 0, 145, 255, 175 ]
        this.const.REFRAC_TIMER            = [  20,  20,  20,  20,  10,  10,  10,  10, 0,  10,   0,   0 ]
    end if
    this.const.BLOCK_PROBABILITY       = [   0, 150, 150, 200, 200, 255, 200, 250, 0, 255, 255, 255 ]
    this.const.ADVANCE_PROBABILITY     = [ 255, 200, 200, 200, 255, 255, 200,   0, 0, 255, 100, 100 ]
    this.const.EXTRA_STRENGTH          = [   0,   0,   0,   0,   1,   0,   0,   0, 0,   0,   0,   0 ]
    'indexed by Level
    this.const.STRENGTH                = [ 4, 3, 3, 3, 3, 4, 5, 4, 4, 5, 5, 5, 4, 6, 10, 0 ]
    'sprites and animations
    this.scale = m.scale
    if name = "guard" and colors > 0
        this.charImage = name + itostr(colors)
    else
        this.charImage = name
    end if
    this.spriteMode = m.settings.spriteMode
    this.splash = {frameName: this.charImage + "-splash", visible: false}
    if name = "shadow"
        this.animations = ParseJson(ReadAsciiFile("pkg:/assets/anims/shadow.json"))
    else
        this.animations = ParseJson(ReadAsciiFile("pkg:/assets/anims/guard.json"))
    end if
    'inherit generic Actor properties and methods
    ImplementActor(this, room, position, face, name)
    'properties
    this.level = level
    this.charName = name
    this.gameWidth = m.gameWidth / m.scale
    this.gameHeight = m.gameHeight / m.scale
    this.frame = 16
    this.frameName = name + "-16"
    this.haveSword = true
    this.meet = false

    if active <> invalid then this.active = active else this.active = true
    if visible <> invalid then this.visible = visible else this.visible = true

    this.baseX  = level.rooms[room].x * this.const.ROOM_WIDTH
    this.baseY  = level.rooms[room].y * this.const.ROOM_HEIGHT

    if face = this.const.FACE_RIGHT
        this.charX = this.charX + 2
    else
        this.charX = this.charX - 2
    end if
    this.charSkill = skill
    this.strikeProbability = this.const.STRIKE_PROBABILITY[skill]
    this.restrikeProbability = this.const.RESTRIKE_PROBABILITY[skill]
    this.blockProbability = this.const.BLOCK_PROBABILITY[skill]
    this.impairblockProbability = this.const.IMPAIRBLOCK_PROBABILITY[skill]
    this.advanceProbability = this.const.ADVANCE_PROBABILITY[skill]

    this.fight = m.settings.fight
    this.refracTimer = 0
    this.blockTimer = 0
    this.strikeTimer = 0

    this.health = m.const.EXTRA_STRENGTH[skill] + m.const.STRENGTH[this.level.number]

    'methods
    this.update = update_guard
    this.updateBehaviour = update_behaviour_guard
    this.processCommand = process_command_guard
    this.getCharBounds = get_guard_bounds
    this.startFall = start_fall_guard
    this.land = land_guard
    this.checkRoomChange = check_room_change_guard
    this.guardAdvance = guard_advance
    this.oppLeftSide = opp_left_side
    this.oppRightSide = opp_right_side
    this.oppTooFar = opp_too_far
    this.oppTooClose = opp_too_close
    this.oppInRange = opp_in_range
    this.oppInRangeArmed = opp_in_range_armed
    this.canDo = can_do_guard
    this.tryAdvance = try_advance
    this.tryBlock = try_block
    this.tryStrike = try_strike
    this.resetRefracTimer = reset_refrac_timer
    this.resetBlockTimer = reset_block_timer
    this.resetStrikeTimer = reset_strike_timer

    return this
End Function

Function update_guard()
    m.updateBehaviour()
    m.processCommand()
    m.updateAcceleration()
    m.updateVelocity()
    m.checkFight()
    m.checkSlicer()
    m.checkSpikes()
    m.checkFightBarrier()
    m.checkFloor()
    m.checkRoomChange()
    m.updatePosition()
    m.updateSwordPosition()
End Function

Sub update_behaviour_guard()
    if m.opponent = invalid or not m.opponent.alive or not m.alive
        if m.alive and m.charAction <> "stand" and m.swordDrawn then
            m.action("stand")
            m.swordDrawn = false
        end if
        m.splash.visible = false
        return
    end if
    if m.refracTimer > 0 then m.refracTimer = m.refracTimer - 1
    if m.blockTimer > 0 then m.blockTimer = m.blockTimer - 1
    if m.strikeTimer > 0 then m.strikeTimer = m.strikeTimer - 1
    if m.charAction = "stabbed" or m.charAction = "stabkill" or m.charAction = "dropdead" or m.charAction = "stepfall" or m.charAction = "freefall" or m.charAction = "halve" then return
    distance = m.opponentDistance()
    if m.swordDrawn and m.blockY = m.opponent.blockY
        if (m.faceL() and m.oppRightSide()) or (m.faceR() and m.oppLeftSide())
            m.turnengarde()
        end if
        if distance >= 35
            m.oppTooFar(distance)
        else if distance < 12
            m.oppTooClose(distance)
        else
            m.oppInRange(distance)
        end if
    else
        if m.canSeeOpponent()
            m.engarde()
        else if m.charAction <> "stand" and m.charAction <> "impale"
            m.action("stand")
            m.swordDrawn = false
        else if m.charAction = "stand"
            if m.room = m.opponent.room
                if m.blockX < m.opponent.blockX and not m.faceR()
                    m.face = m.const.FACE_RIGHT
                    m.charX = ConvertBlockXtoX(m.blockX) + m.const.BLOCK_WIDTH / 2
                else if m.blockX > m.opponent.blockX and not m.faceL()
                    m.face = m.const.FACE_LEFT
                    m.charX = ConvertBlockXtoX(m.blockX)
                end if
            end if
        end if
    end if
End Sub

Sub process_command_guard()
    command = true
    while (command)
        actionArray = m.animations.sequence.Lookup(m.charAction)
        if actionArray = invalid then exit while
        data = actionArray[m.seqPointer]
        if data.cmd = m.const.CMD_ACT
            m.actionCode = data.p1
        else if data.cmd = m.const.CMD_SETFALL
            if m.face = m.const.FACE_LEFT
                m.charXVel = data.p1 * -1
            else
                m.charXVel = data.p1
            end if
            m.charYVel = data.p2
        else if data.cmd = m.const.CMD_ABOUTFACE
            m.face = Abs(m.face - 1)
        else if data.cmd = m.const.CMD_CHX
            if m.faceL()
                m.charX = m.charX - data.p1
            else
                m.charX = m.charX + data.p1
            end if
        else if data.cmd = m.const.CMD_CHY
            m.charY = m.charY + data.p1
        else if data.cmd = m.const.CMD_TAP
            'alert opponent
        else if data.cmd = m.const.CMD_GOTO
            m.charAction = data.p1
            m.seqPointer = data.p2 - 1
        else if data.cmd = m.const.CMD_FRAME
            m.frame = data.p1
            m.updateFrame()
            command = false
        else if data.cmd = m.const.CMD_DIE
            if m.charName = "vizier"
                m.opponent.effect.color = m.opponent.colors.white
                m.opponent.effect.cycles = 4
                PlaySound("jaffar-death")
            else if m.charName <> "shadow"
                PlaySound("glory")
            end if
            m.health = 0
            m.alive = false
			m.swordDrawn = false
            m.opponent = invalid
        end if
        m.seqPointer = m.seqPointer + 1
    end while
End Sub

Function get_guard_bounds() as object
    g = GetGlobalAA()
    f = g.regions.guards.Lookup(m.charImage)[m.face].Lookup(m.frameName)
	fWidth  = f.getWidth() / m.scale
	fHeight = f.getHeight() / m.scale
	if m.faceL()
		x = m.x - m.charFdx
	else
		x = m.x + m.charFdx - fWidth
	end if
    y = m.y + m.charFdy - fHeight
    if (m.charFood and m.faceL()) or (not m.charFood and m.faceR())
        x = x + 1
    end if
    return {x: x, y: y, width: fWidth, height: fHeight}
End Function

Sub check_room_change_guard()
    if m.charY > 189
        m.charY = m.charY - 189
        m.baseY = m.baseY + 189
        if m.room >= 0 then m.room = m.level.rooms[m.room].links.down
    else if m.charY < 0
        m.charY = m.charY + 189
        m.baseY = m.baseY - 189
        if m.room >= 0 then m.room = m.level.rooms[m.room].links.up
    end if
End Sub

Sub start_fall_guard()
    m.fallingBlocks = 0
    m.action("stepfall")
    if m.opponent <> invalid then m.opponent.droppedOut = false
    m.processCommand()
End Sub

Sub land_guard(tile as object)
    m.charY = ConvertBlockYtoY(m.blockY)
    m.charXVel = 0
    m.charYVel = 0
    if m.charName = "skeleton"
        if m.fallingBlocks <= 5
            m.action("stand")
        else
            m.action("halve")
        end if
    else if m.charName = "shadow"
        if m.fallingBlocks <= 2
            m.action("softland")
        else
            m.action("dropdead")
        end if
    else if tile.element = m.const.TILE_SPIKES
        m.action("impale")
        PlaySound("spiked")
    else if m.fallingBlocks <= 1
        m.action("stand")
    else
        m.action("dropdead")
    end if
    if m.charAction = "dropdead" and (tile.element = m.const.TILE_RAISE_BUTTON or tile.element = m.const.TILE_DROP_BUTTON)
        tile.push(true, false)
    end if
    m.processCommand()
End Sub

Sub guard_advance()
    if m.faceL()
        tileF = m.level.getTileAt(m.blockX - 1, m.blockY, m.room)
        tile2F = m.level.getTileAt(m.blockX -2, m.blockY, m.room)
        tileD = m.level.getTileAt(m.blockX - 1, m.blockY + 1, m.room)
    else
        tileF = m.level.getTileAt(m.blockX + 1, m.blockY, m.room)
        tile2F = m.level.getTileAt(m.blockX + 2, m.blockY, m.room)
        tileD = m.level.getTileAt(m.blockX + 1, m.blockY + 1, m.room)
    end if
    if tileF.isWalkable() and tileF.element <> m.const.TILE_LOOSE_BOARD
        m.advance()
    else if tile2F.isWalkable() and tile2F.element <> m.const.TILE_LOOSE_BOARD
        m.advance()
    else if m.opponent.droppedOut and tileD.isWalkable() and m.opponent.blockY = m.blockY + 1
        print "follow down"
        'follow kid down
        m.advance()
    else
        print "retreat after dropped out"
        m.opponent.droppedOut = false
        m.retreat()
    end if
End Sub

Function opp_left_side() as boolean
    if m.room < 0 or m.opponent.room < 0 then
        return (m.blockX > m.opponent.blockX)
    else if m.level.rooms[m.room].x = m.level.rooms[m.opponent.room].x
        return (m.blockX > m.opponent.blockX)
    else
        return (m.level.rooms[m.room].x > m.level.rooms[m.opponent.room].x)
    end if
End Function

Function opp_right_side() as boolean
    if m.room < 0 or m.opponent.room < 0 then
        return (m.blockX < m.opponent.blockX)
    else if m.level.rooms[m.room].x = m.level.rooms[m.opponent.room].x
        return (m.blockX < m.opponent.blockX)
    else
        return (m.level.rooms[m.room].x < m.level.rooms[m.opponent.room].x)
    end if
End Function

Sub opp_too_far(distance)
    if m.refracTimer <> 0 then return
    if m.opponent.charAction = "running" and distance < 40
        if m.fight = m.const.FIGHT_ATTACK then m.strike()
    else if m.opponent.charAction = "runjump" and distance < 50
        if m.fight = m.const.FIGHT_ATTACK then m.strike()
    else
        if m.canReachOpponent() then m.guardAdvance()
    end if
End Sub

Sub opp_too_close(distance)
    if m.face = m.opponent.face
        m.retreat()
    else
        m.advance()
    end if
End Sub

Sub opp_in_range(distance)
    if not m.opponent.swordDrawn
        if m.refracTimer = 0
            if distance < 29
                if m.fight = m.const.FIGHT_ATTACK then m.strike()
            else
                m.advance()
            end if
        end if
    else
        m.oppInRangeArmed(distance)
    end if
End Sub

Sub opp_in_range_armed(distance)
    if distance < 10 or distance >= 29
        m.tryAdvance()
    else
        m.tryBlock()
        if m.refracTimer = 0
            if distance < 12
                m.tryAdvance()
            else
                if m.fight = m.const.FIGHT_ATTACK then m.tryStrike()
            end if
        end if
    end if
End Sub

Sub try_advance()
    if m.charSkill = 0 or m.strikeTimer = 0
        if m.advanceProbability > (rnd(255) - 1) then m.advance()
    end if
End Sub

Sub try_block()
    if m.opponent.frameID(152,153) or m.opponent.frameID(162)
        if (m.blockTimer <> 0)
            if m.impairblockProbability > (rnd(255) - 1) then m.block()
        else
            if m.blockProbability > (rnd(255) - 1) then m.block()
        end if
    end if
End Sub

Sub try_strike()
    if m.opponent.frameID(169) or m.opponent.frameID(151)  then return
    if m.frameID(0) or m.frameID(150)
        if m.restrikeProbability > (rnd(255) - 1) then m.strike()
    else
        if m.strikeProbability > (rnd(255) - 1) then m.strike()
    end if
End Sub

Sub reset_refrac_timer()
    m.refracTimer = m.const.REFRAC_TIMER[m.charSkill]
End Sub

Sub reset_block_timer()
    m.blockTimer = 4
End Sub

Sub reset_strike_timer()
    m.strikeTimer = 15
End Sub

Function can_do_guard(doAction as integer) as boolean
    if doAction = m.const.DO_MOVE
        frames = [8, 20, 21]
    else if doAction = m.const.DO_STRIKE
        frames = [7, 8, 15, 20, 21]
    else if doAction = m.const.DO_DEFEND
        frames = [8, 15, 18, 20, 21]
    else if doAction = m.const.DO_BLOCK
        frames = [2]
    else if doAction = m.const.DO_STRIKE_TO_BLOCK
        frames = [17]
    else if doAction = m.const.DO_BLOCK_TO_STRIKE
        frames = [0]
    end if
    for each frame in frames
        if m.charName = "shadow"
            if m.frameID(frame + 150) then return true
        else
            if m.frameID(frame) then return true
        end if
    next
    return false
End Function
