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

Function CreateActor(x as integer, y as integer, face as integer, name as string, scale as float) as object
    this = {}
    'constants
    this.const = m.const
    'sprites and animations
    this.spriteMode = m.settings.spriteMode
    this.animations = ParseJson(ReadAsciiFile("pkg:/assets/anims/" + name + ".json"))
    'properties
    this.charName = name
    this.frame = 16
    this.frameName = name + "-16"
    this.haveSword = true
    this.alive = true
    this.isWeightless = false
    this.swordDrawn = false
    this.charXVel = 0
    this.charYVel = 0
    if face = 1
        this.face = m.const.FACE_RIGHT
    else
        this.face = m.const.FACE_LEFT
    end if
    this.moveLeft = false
    this.opponent = invalid
    this.room = - 1
    this.blockX = 0
    this.blockY = 0
    this.charX = x
    this.charY = y
    this.x = 0
    this.y = 0
    this.z = 20
    this.saveX = 0
    this.saveY = 0
    this.baseX = 0
    this.baseY = 0
    this.charFdx = 0
    this.charFdy = 0
    this.charFcheck = false
    this.charFfoot = 0
    this.charFood = false
    this.charFthin = false
    this.charSword = false
    this.charAction = "stand"
    this.seqPointer = 0
    this.leapOfFaith = false
    'Methods
    SetActorMethods(this)
    this.processCommand = process_command_actor

    return this
End Function

Function ImplementActor(char as object, room as integer, tile as integer, face as integer, name as string) as object
    'Sprites and animations
    if char.sword = invalid
        char.sword = {frameName: "",  x: 0, y: 0, z: 0, visible: false}
        char.swordAnims = ParseJson(ReadAsciiFile("pkg:/assets/anims/sword.json"))
    end if
    'Properies
    char.alive = true
    char.isWeightless = false
    char.swordDrawn = false
    char.blocked = false
    char.flee = false
    char.allowAdvance = true
    char.allowRetreat = true
    char.allowBlock = true
    char.allowStrike = true
    char.leapOfFaith = false
    char.charXVel = 0
    char.charYVel = 0
    char.room = room
    if face = 1
        char.face = m.const.FACE_RIGHT
    else
        char.face = m.const.FACE_LEFT
    end if
    char.fallingBlocks = 0
    char.moveLeft = false
    char.opponent = invalid
    char.blockX = tile mod 10
    char.blockY = int(tile / 10)
    char.charX = ConvertBlockXtoX(char.blockX) + 7
    char.charY = convertBlockYtoY(char.blockY)
    char.x = 0
    char.y = 0
    char.z = 20
    char.saveX = 0
    char.saveY = 0
    char.baseX = 0
    char.baseY = 0
    char.charFdx = 0
    char.charFdy = 0
    char.charFcheck = false
    char.charFfoot = 0
    char.charFood = false
    char.charFthin = false

    char.charSword = true
    char.swordFrame = 0
    char.swordDx = 0
    char.swordDy = 0
    char.swordDz = 0

    char.charAction = "stand"
    char.seqPointer = 0
    'Methods
    SetActorMethods(char)
    SetFighterMethods(char)

    return char
End Function
'--------------- Actor Methods ---------------
Sub SetActorMethods(char as object)
    char.updateActor = update_actor
    char.updatePosition = update_position
    char.updateFrame = update_frame
    char.updateBlockXY = update_block_xy
    char.updateVelocity = update_velocity
    char.updateAcceleration = update_acceleration
    char.checkFloor = check_floor
    char.checkSlicer = check_slicer
    char.checkSpikes = check_spikes
    char.trySpikes = try_spikes
    char.movingTo = moving_to
    char.bumpFall = bump_fall
    char.action = action_actor
    char.frameId = frame_id
    char.faceL = face_l
    char.faceR = face_r
    char.distanceToFloor = distance_to_floor
    char.distanceToEdge = distance_to_edge
    char.canReachOpponent = can_reach_opponent
End Sub

Function update_actor()
    m.processCommand()
    m.updatePosition()
End Function

Sub process_command_actor()
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
            if m.face = m.const.FACE_LEFT
                m.charX = m.charX - data.p1
            else
                m.charX = m.charX + data.p1
            end if
        else if data.cmd = m.const.CMD_CHY
            m.charY = m.charY + data.p1
        else if data.cmd = m.const.CMD_TAP
            if data.p1 = 0
                'alertguard
            else if data.p1 = 1
                PlaySound("footstep", true)
            else if data.p1 = 2
                PlaySound("smack-wall")
            end if
        else if data.cmd = m.const.CMD_UP
            m.blockY = m.blockY - 1
        else if data.cmd = m.const.CMD_DOWN
            m.blockY = m.blockY + 1
        else if data.cmd = m.const.CMD_GOTO
            m.charAction = data.p1
            m.seqPointer = data.p2 - 1
        else if data.cmd = m.const.CMD_FRAME
            m.frame = data.p1
            m.updateFrame()
            command = false
        else if data.cmd = m.const.CMD_DIE
            m.health = 0
            m.alive = false
			m.swordDrawn = false
        end if
        m.seqPointer = m.seqPointer + 1
    end while
End Sub

Sub update_position()
    m.frameName = m.charName + "-" + itostr(m.frame)
    m.updateBlockXY()
    tempx = 0.0
    if m.faceL()
        tempx = m.charX - m.charFdx
    else
        tempx = m.charX + m.charFdx
    end if

    if (m.charFood and m.faceL()) or (not m.charFood and m.faceR())
        tempx = tempx + 0.5
    end if
    m.x = m.baseX + ConvertX(tempx)
    m.y = m.baseY + m.charY + m.charFdy
End Sub

Sub update_frame()
    framedef = m.animations.framedef[m.frame]
    m.charFdx = framedef.fdx
    m.charFdy = framedef.fdy
    fcheck = Val(framedef.fcheck, 16)
    m.charFfoot = fcheck and &h1F
    m.charFood = (fcheck and &h80) = &h80
    m.charFcheck = (fcheck and &h40) = &h40
    m.charFthin = (fcheck and &h20) = &h20
	m.charSword = (framedef.fsword <> invalid)
    if m.charSword
        if m.spriteMode = m.const.SPRITES_MAC
            stab = m.swordAnims.swordTabMac[framedef.fsword - 1]
        else
            stab = m.swordAnims.swordTabDos[framedef.fsword - 1]
        end if
        m.swordFrame = stab.id
        m.swordDx = stab.dx
        m.swordDy = stab.dy
        if stab.dz <> invalid
            m.swordDz = stab.dz
        else
            m.swordDz = -1
        end if
    end if
End Sub

Sub update_block_xy()
    if m.faceL()
        footX = m.charX - m.charFdx + m.charFfoot
    else
        footX = m.charX + m.charFdx - m.charFfoot
    end if
    footY = m.charY + m.charFdy
    m.blockX = ConvertXtoBlockX(footX)
    m.blockY = ConvertYtoBlockY(footY-3)
    'if m.charName = "kid" then print "update_block_xy charX="; m.charX;" footX="; footX; " blockX=",m.blockX
    if m.blockX < 0 and m.charX < 0
        m.charX = m.charX + 140
        m.baseX = m.baseX - 320
        m.blockX = 9
        m.room = m.level.rooms[m.room].links.left
        if m.charName = "kid" and m.flee and m.opponent <> invalid and not m.canSeeOpponent()
            if m.opponent.blockX > 3 or m.blockY <> m.opponent.blockY
                print "flee"
                m.flee = false
                m.opponent = invalid
            end if
        end if
    else if m.blockX > 9 and m.room > -1
        m.charX = m.charX - 140
        m.baseX = m.baseX + 320
        m.blockX = 0
        m.room = m.level.rooms[m.room].links.right
        if m.charName = "kid" and m.flee and m.opponent <> invalid and not m.canSeeOpponent()
            if m.opponent.blockX < 6 or m.blockY <> m.opponent.blockY
                m.flee = false
                m.opponent = invalid
            end if
        end if
    end if
End Sub

Sub update_velocity()
    m.charX = m.charX + m.charXVel
    m.charY = m.charY + m.charYVel
End Sub

Sub update_acceleration()
    if m.actionCode = 4 'freefall
        if m.isWeightless
            m.charYVel = m.charYVel + m.const.GRAVITY_WEIGHTLESS
            if m.charYVel > m.const.TOP_SPEED_WEIGHTLESS then m.charYVel = m.const.TOP_SPEED_WEIGHTLESS
        else
            m.charYVel = m.charYVel + m.const.GRAVITY_NORMAL
            if m.charYVel > m.const.TOP_SPEED_NORMAL then m.charYVel = m.const.TOP_SPEED_NORMAL
        end if
    end if
End Sub

Sub check_floor()
    if m.charAction = "climbdown" or m.charAction = "climbup" or m.room < 0 or not m.alive or not m.visible
         return
    end if
    if m.actionCode = 0 or m.actionCode = 1 or m.actionCode = 7 or m.actionCode = 5
        if m.charFcheck
            tile = m.level.getTileAt(m.blockX, m.blockY,m.room)
            if tile.element = m.const.TILE_SPACE
                if m.actionCode = 5 then return 'being bumped
                if m.leapOfFaith
                    'show tiles
                    tile.element = m.const.TILE_FLOOR
                    tile.back = tile.key + "_" + itostr(tile.element)
                    tile.front = tile.back + "_fg"
                    tile.redraw = true
                    return
                end if
                print m.charName;" startFall";m.fallingBlocks; " y="; m.charY
                if m.faceL() and m.moveLeft
                    if m.swordDrawn
                        m.charX = ConvertBlockXtoX(m.blockX - 1)
                        m.updateBlockXY()
                    end if
                else
                    if m.charName = "skeleton"
                        if m.room = 3
                            m.charX = ConvertBlockXtoX(m.blockX) + 20
                        else
                            m.charX = ConvertBlockXtoX(m.blockX) + 15
                        end if
                    else if m.charName = "guard"
                        m.charX = ConvertBlockXtoX(m.blockX) + 15
                    else
                        m.charX = ConvertBlockXtoX(m.blockX) + 5
                    end if
                    m.updateBlockXY()
                end if
                m.startFall()
            else if tile.isSpace()
                if m.actionCode = 5 then return 'being bumped
                m.startFall()
            else if tile.element = m.const.TILE_LOOSE_BOARD
                if m.charAction = "testfoot" then tile.shake(false) else tile.shake(true)
            else if tile.element = m.const.TILE_RAISE_BUTTON or tile.element = m.const.TILE_DROP_BUTTON
                tile.push()
            else if tile.element = m.const.TILE_SPIKES
                tile.raise()
            end if
        end if
    else if m.actionCode = 4   ' freefall
        if m.charY > ConvertBlockYtoY(m.blockY)
            tile = m.level.getTileAt(m.blockX, m.blockY, m.room)
            print m.charName;" falling at tile=";tile.element; " y="; m.charY
            if tile.isWalkable()
                print m.charName;" m.fallingBlocks=";m.fallingBlocks; " y="; m.charY
                m.land(tile)
            else if not m.isWeightless
                print m.charName;" m.fallingBlocks++";m.fallingBlocks; " y="; m.charY
                m.fallingBlocks = m.fallingBlocks + 1
                if m.fallingBlocks = 3 and m.charName = "kid"
                    PlaySound("scream")
                end if
            end if
        end if
    end if
End Sub

Sub check_slicer()
    if not m.alive or m.room < 0 then return
    if m.charAction = "climbdown" or m.charAction = "climbup" then return
    for t = -1 to 1
        tile = m.level.getTileAt(m.blockX + t, m.blockY, m.room)
        if tile.element = m.const.TILE_SLICER
            bounds = m.getCharBounds()
            if tile.intersects(bounds) and (tile.stage = 2 or tile.stage = 3)
                tile.blood.visible = true
                StopAudio()
                if m.faceL()
                    m.charX = ConvertBlockXtoX(m.blockX + t) - 7
                else
                    m.charX = ConvertBlockXtoX(m.blockX + t) + 5
                end if
                m.charY = (m.blocky + 1) * m.const.BLOCK_HEIGHT - 10
                m.updateBlockXY()
                m.swordDrawn = false
                if m.charName = "kid"
                    m.effect.color = m.colors.white
                    m.effect.cycles = 1
                end if
                m.action("halve")
                PlaySound("sliced", false, 75)
                exit for
            end if
        end if
    next
End Sub

Sub check_spikes()
    if m.room < 0 then return
    if m.distanceToEdge() < 5
        if m.faceL()
            m.trySpikes(m.blockX - 1, m.blockY)
        else
            m.trySpikes(m.blockX + 1, m.blockY)
        end if
    end if
    m.trySpikes(m.blockX, m.blockY)
End Sub

Sub try_spikes(x as integer, y as integer)
    while (y < 3)
        tile = m.level.getTileAt(x, y,m.room)
        if tile.element = m.const.TILE_SPIKES
            tile.raise()
        else if tile.element <> m.const.TILE_SPACE
            return
        end if
        y = y + 1
    end while
End Sub

Sub bump_fall()
    if m.actionCode = 4
        if m.faceL()
            m.charX = m.charX + 1
        else
            m.charX = m.charX - 1
        end if
        m.charXVel = 0
    else
        if m.faceL()
            m.charX = m.charX + 2
        else
            m.charX = m.charX - 2
        end if
        m.action("bumpfall")
        m.processCommand()
    end if
End Sub

Function action_actor(action = "" as string) as string
    if action <> ""
        m.charAction = action
        m.seqPointer = 0
    end if
    return m.charAction
End Function

Function frame_id(fromId as integer, toId = -1 as integer) as boolean
    if toId = -1
        return (m.frame = fromId)
    else
        return (m.frame >= fromId) and (m.frame <= toId)
    end if
End Function

Function face_l() as boolean
    return (m.face = m.const.FACE_LEFT)
End Function

Function face_r() as boolean
    return (m.face = m.const.FACE_RIGHT)
End Function

Function distance_to_floor() as integer
    return ConvertBlockYtoY(m.blockY) - m.charY - m.charFdy
End Function

Function distance_to_edge() as integer
    if m.faceR()
        dx = ConvertBlockXtoX(m.blockX + 1) - 1 - m.charX - m.charFdx + m.charFfoot
    else
        dx = m.charX + m.charFdx + m.charFfoot - ConvertBlockXtoX(m.blockX)
    end if
    return dx
End Function

'--------------- Fighter Methods ---------------
Sub SetFighterMethods(char as object)
    if char.block = invalid then char.block = block_fighter
    char.checkFight = check_fight
    char.checkFightBarrier = check_fight_barrier
    char.bumpFighter = bump_fighter
    char.engarde = engarde_fighter
    char.turnEngarde = turnengarde_fighter
    char.sheathe = sheathe_fighter
    char.retreat = retreat_fighter
    char.advance = advance_fighter
    char.strike = strike_fighter
    char.stabbed = stabbed_fighter
    char.opponentDistance = opponent_distance
    char.updateSwordPosition = update_sword_position
    char.canSeeOpponent = can_see_opponent
End Sub

Sub check_fight()
    if m.opponent = invalid then return
    if m.blocked and m.charAction <> "strike"
        m.retreat()
        m.processCommand()
        m.blocked = false
        return
    end if
    distance = m.opponentDistance()
	if m.charAction = "engarde" and m.charName = "kid"
		if not m.opponent.alive
			m.sheathe()
			m.opponent = invalid
        else if m.opponent.blockY <> m.blockY
            m.sheathe()
		else if m.opponent.blockY = m.blockY and distance < -4
		    m.turnengarde()
			m.opponent.turnengarde()
		end if
	else if m.charAction = "stabbed"
		if m.frameID(23) or m.frameID(173) then m.splash.visible = false
	else if m.charAction = "dropdead"
		if m.frameID(30) or m.frameID(180) then m.splash.visible = false
	else if m.charAction = "strike"
		if m.opponent.charAction = "climbstairs" then return
		if not m.frameID(153,154) and not m.frameID(3,4) then return
		if not m.opponent.frameID(150) and not m.opponent.frameID(0)
            if m.frameID(154) or m.frameID(4)
                if m.opponent.swordDrawn
                    minHurtDistance = 12
                else
                    minHurtDistance = 8
                end if
				if distance >= minHurtDistance and distance < 29
					m.opponent.stabbed()
                    if m.charName <> "kid"
                        PlaySound("harm")
                    else
                        PlaySound("guard-hit")
                    end if
				else
                    if m.charName = "kid" then PlaySound("sword-attack")
                end if
			end if
		else
			m.opponent.blocked = true
			m.action("blockedstrike")
			m.processCommand()
            PlaySound("sword-defense")
		end if
	end if
End Sub

Sub check_fight_barrier()
    if m.charAction= "hardland" or m.charAction = "impale" or m.charAction = "dropdead"
        return
    else if m.charAction.left(4) = "turn" or m.charAction = "fastsheathe" or m.charAction = "resheathe"
        return
    else if not m.active or not m.alive or m.room < 0
        return
    end if
    'Check Vertical
    tileT = m.level.getTileAt(m.blockX, m.blockY - 1, m.room)
    if m.charAction = "freefall"
        if tileT.element = m.const.TILE_WALL
            if m.faceL()
                m.charX = ConvertBlockXtoX(m.blockX + 1) - 1
            else
                m.charX = ConvertBlockXtoX(m.blockX)
            end if
            m.updateBlockXY()
            print "bump: freefall"
        end if
        return
    end if
    'Check Horizontal
    tile = m.level.getTileAt(m.blockX, m.blockY, m.room)
    m.element = tile.element 'current tile element for debugging
    if tile.isBarrier()
        blockX = m.blockX
        if m.saveX <> invalid
            m.charX = m.saveX
            m.updateBlockXY()
            return
        end if
    else
        m.saveX = m.charX
    end if
    if m.movingTo() = m.const.FACE_LEFT
        m.moveLeft = true
        blockX = ConvertXtoBlockX(m.charX - m.charFdx - m.const.BLOCK_WIDTH / 3)
    else if m.movingTo() = m.const.FACE_RIGHT
        m.moveLeft = false
        blockX = ConvertXtoBlockX(m.charX + m.charFdx + m.const.BLOCK_WIDTH / 3)
    else
        return
    end if
    tileNext = m.level.getTileAt(blockX, m.blockY, m.room)
    if tileNext <> invalid and tileNext.isBarrier()
        if tileNext.isBarrier() and tileNext.element <> m.const.TILE_GATE
            if m.moveLeft
                m.charX = ConvertBlockXtoX(blockX + 1) + 7
            else
                m.charX = ConvertBlockXtoX(blockX - 1)
            end if
            m.updateBlockXY()
            print "bump: barrier"; m.charX; m.blockX
            m.bumpFighter()
        else if tileNext.element = m.const.TILE_GATE
            if tileNext.state <> tileNext.STATE_OPEN and tileNext.state <> tileNext.STATE_WAITING
                if m.moveLeft
                    m.charX = ConvertBlockXtoX(blockX + 1) + 7
                else
                    m.charX = ConvertBlockXtoX(blockX - 1) + 8
                end if
                m.updateBlockXY()
                m.saveX = m.charX
                print "bump: gate"; m.charX; m.blockX
                m.bumpFighter()
            end if
        end if
    end if
End Sub

Function moving_to() as integer
    if (m.faceL() and m.charAction = "advance") or (m.faceR() and m.charAction = "retreat") or (m.faceR() and m.charAction = "stabbed")
        return m.const.FACE_LEFT
    else if (m.faceR() and m.charAction = "advance") or (m.faceL() and m.charAction = "retreat") or (m.faceL() and m.charAction = "stabbed")
        return m.const.FACE_RIGHT
    else
        return -1
    end if
End Function

Function can_reach_opponent() as boolean
    can = true
    if m.opponent = invalid or m.blockY <> m.opponent.blockY
        return false
    else if m.faceL() and m.blockX > m.opponent.blockX
        min = m.opponent.blockX
        max = m.blockX
    else if m.faceR() and m.blockX < m.opponent.blockX
        min = m.blockX
        max = m.opponent.blockX
    else
        return true
    end if
    for x = min to max
        tile = m.level.getTileAt(x, m.blockY, m.room)
        if tile.isBarrier() or tile.isMob() or tile.element = m.const.TILE_SLICER
            can = false
            exit for
        end if
    next
    return can
End Function

Sub bump_fighter()
    if not m.alive or m.room < 0 then return
    tile = m.level.getTileAt(m.blockX, m.blockY, m.room)

    if tile.isSpace()
        if m.moveLeft
            m.charX = m.charX + 2
        else
            m.charX = m.charX - 2
        end if
        m.bumpFall()
    else
        if m.fallingBlocks > 0 and (m.frameID(24, 25) or m.frameID(40, 42) or m.frameID(102, 106))
            if m.moveLeft
                m.charX = m.charX + 5
            else
                m.charX = m.charX - 5
            end if
            m.land(tile)
        else
			print "bumping on fight..."
            if m.charAction = "advance"
                print "will retreat"
                m.action("retreat")
                m.processCommand()
            else if m.charAction = "retreat"
                print "will advance"
                m.action("advance")
                m.processCommand()
            end if
        end if
    end if
End Sub

Sub update_sword_position()
    if m.charSword
        m.sword.frameName = "sword" + itostr(m.swordFrame)
        m.sword.x = m.swordDx
        m.sword.y = m.swordDy
        m.sword.z = m.swordDz
    end if
    m.sword.visible = m.charSword
End Sub

Function opponent_distance()
    if m.opponent.room <> m.room then return 999
    if m.faceL()
        distance = (m.opponent.charX - m.charX) * -1
    else
        distance = m.opponent.charX - m.charX
    end if
    if distance >= 0 and m.face <> m.opponent.face
		distance = distance + 13
	end if
    return distance
End Function

Sub engarde_fighter()
    if m.haveSword
        if m.charName = "kid" then PlaySound("sword-drawn")
        m.action("engarde")
        m.swordDrawn = true
        if m.faceL()
            m.moveLeft = true
        else
            m.moveLeft = false
        end if
    end if
End Sub

Sub turnengarde_fighter()
    if m.haveSword
        m.action("turnengarde")
        m.swordDrawn = true
    end if
End Sub

Sub sheathe_fighter()
    m.action("resheathe")
    m.swordDrawn = false
End Sub

Sub retreat_fighter()
    if m.canDo(m.const.DO_MOVE)
        m.action("retreat")
        m.allowRetreat = false
    end if
End Sub

Sub advance_fighter()
    if m.canDo(m.const.DO_MOVE)
        m.action("advance")
        m.allowAdvance = false
    end if
End Sub

Sub strike_fighter()
    if m.canDo(m.const.DO_STRIKE)
        m.action("strike")
        m.allowStrike = false
    else
        if m.canDo(m.const.DO_BLOCK_TO_STRIKE) or m.blocked
            m.action("blocktostrike")
            m.allowStrike = false
            m.blocked = false
        end if
    end if
End Sub

Sub block_fighter()
    if m.canDo(m.const.DO_DEFEND)
        if m.opponentDistance() >= 32
            m.retreat()
            return
        end if
        if not m.canDo(m.const.DO_BLOCK)  then return
        m.action("block")
    else
        if not m.canDo(m.const.DO_STRIKE_TO_BLOCK) then return
        m.action("striketoblock")
    end if
    m.allowBlock = false
End Sub

Sub stabbed_fighter()
    if m.health = 0 then return
    m.charY = ConvertBlockYtoY(m.blockY)
    if m.charName <> "skeleton"
        if m.swordDrawn
            damage = 1
        else
            damage = m.health
        end if
        m.health -= damage
    end if
    if m.health = 0
        m.action("stabkill")
        tile = m.level.getTileAt(m.blockX, m.blockY, m.room)
        if tile.element = m.const.TILE_RAISE_BUTTON or tile.element = m.const.TILE_DROP_BUTTON
            tile.push(true, false)
        end if
    else
        m.action("stabbed")
    end if
    if m.charName = "shadow" and m.opponent <> invalid
        m.opponent.stabbed()
    else if m.charName = "kid"
        m.effect.color = m.colors.red
        m.effect.cycles = 1
    end if
    m.splash.visible = true
End Sub

Function can_see_opponent() as boolean
    if m.opponent = invalid then return false
    if m.opponent.room <> m.room then return false
    if m.opponent.blockY <> m.blockY then return false
    return true
End Function
