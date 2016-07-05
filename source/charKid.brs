' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **  Created: February 2016
' **  Updated: July 2016
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateKid(level as object, startRoom as integer, startTile as integer, startFace as integer, startHealth as integer) as object
    this = {}
	'constants
    this.const = m.const
    this.colors = m.colors
	'controller
	this.cursors = GetCursors(m.settings.controlMode)
    'sprites and animations
    this.scale = m.scale
    this.spriteMode = m.settings.spriteMode
    this.splash = {frameName: "kid-splash", visible: false}
    this.animations = ParseJson(ReadAsciiFile("pkg:/assets/anims/kid.json"))
    'properties

    this.charName = "kid"
    this.gameWidth = m.gameWidth / m.scale
    this.gameHeight = m.gameHeight / m.scale

    this.maxHealth = startHealth
    this.health = startHealth

    this.pickupSword = false
    this.pickupPotion = false
    this.potion = 0

    this.startup = true

    this.allowCrawl = true
    this.inJumpUP = false
    this.charRepeat = false
    this.recoverCrop = false
    this.droppedOut = false
    this.active = true
    this.visible = true

    'methods
    this.startLevel = start_level
    this.update = update_kid
    this.updateBehaviour = update_behaviour_kid
    this.processCommand = process_command_kid
    this.getCharBounds = get_kid_bounds
    this.maskAndCrop = mask_and_crop
    this.checkBarrier = check_barrier
    this.checkRoomChange = check_room_change_kid
    this.trySpikes = try_spikes
    this.checkImpale = check_impale
    this.startFall = start_fall_kid
    this.tryGrabEdge = try_grab_edge
    this.grab = grab_kid
    this.tryPickup = try_pickup
    this.drinkPotion = drink_potion
    this.gotSword = got_sword
    this.block = block_kid
    this.fastSheathe = fast_sheathe
    this.tryEngarde = try_engarde
    this.canDo = can_do_kid
    this.turn = turn_kid
    this.walk = walk_kid
    this.jump = jump_kid
    this.land = land_kid
    this.bump = bump_kid
    this.jumpup = jumpup_kid
    this.highjump = highjump_kid
    this.jumpbackhang = jumpbackhang_kid
    this.jumphanglong = jumphanglong_kid
    this.stoop = stoop_kid
    this.climbup = climb_up
    this.climbdown = climb_down
    this.climbstairs = climb_stairs
    this.injured = injured_kid
    this.nearBarrier = near_barrier
    this.keyU = key_u
    this.keyD = key_d
    this.keyL = key_l
    this.keyR = key_r
    this.KeyS = key_s
    this.startLevel(level, startRoom, startTile, startFace, startHealth)
    return this
End Function

Sub start_level(level as object, startRoom as integer, startTile as integer, startFace as integer, startHealth as integer)
    'inherit generic actor properties and methods
    ImplementActor(m, startRoom, startTile, startFace, m.charName)
    'Save check point
    m.checkPoint = {room: startRoom, tile: startTile, face: startFace}
    'reset internal properties
    m.level = level
    m.frame = 15
    m.frameName = "kid-15"
    m.cropY = 0
    m.element = 0
    m.fallingBlocks = 0
    m.success = false
    m.cursors.shift = false
    m.effect = m.colors.black
    m.cycles = 0
    m.maxHealth = startHealth
    m.health = m.maxHealth
    if m.level.number = 1
        m.haveSword = false
    else
        m.startup = false
        m.haveSword = true
        if m.level.number <> 13 then
            m.health = m.maxHealth
            m.turn()
        else
            m.action("startrun")
        end if
    end if
End Sub

Function update_kid()
    m.updateBehaviour()
    m.processCommand()
    m.updateAcceleration()
    m.updateVelocity()
    m.checkFight()
    m.checkSlicer()
    m.checkSpikes()
    m.checkBarrier()
    m.checkFloor()
    m.checkImpale()
    m.checkRoomChange()
    m.updatePosition()
    m.updateSwordPosition()
    m.maskAndCrop()
End Function

Sub update_behaviour_kid()
    if not m.alive
        m.splash.visible = false
        return
    end if
    if (not m.keyL() and m.faceL()) or (not m.keyR() and m.faceR())
		m.allowCrawl = true
		m.allowAdvance = true
	end if
    if (not m.keyL() and m.faceR()) or (not m.keyR() and m.faceL())
		m.allowRetreat = true
	end if
    if not m.keyU()
		m.allowBlock = true
	end if
    if not m.keyS()
		m.allowStrike = true
	end if

	if m.charAction = "stand"
		if not m.flee and m.opponent <> invalid
            m.tryEngarde()
		else if m.flee and m.keyS() and m.opponent <> invalid
            m.tryEngarde()
        end if
		if (m.keyL() and m.faceR()) or (m.keyR() and m.faceL())
			m.turn()
		else if (m.keyL() and m.keyU() and m.faceL()) or (m.keyR() and m.keyU() and m.faceR())
			m.action("standjump")
		else if (m.keyL() and m.keyS() and m.faceL()) or (m.keyR() and m.keyS() and m.faceR())
			m.walk()
		else if (m.keyL() and m.faceL()) or (m.keyR() and m.faceR())
			if m.nearBarrier()
				m.walk()
			else
				m.action("startrun")
			end if
		else if m.keyU()
			m.jump()
		else if m.keyD()
			m.stoop()
		else if m.keyS()
			m.tryPickup()
		end if
	else if m.charAction = "startrun"
		if m.keyU() then m.action("standjump")
	else if m.charAction = "running"
		if (m.keyL() and m.faceR()) or (m.keyR() and m.faceL())
			m.action("runturn")
		else if m.keyU()
			m.action("runjump")
		else if m.keyD()
			m.action("rdiveroll")
			m.allowCrawl = false
        else if (not m.keyL() and m.faceL()) or (not m.keyR() and m.faceR())
            if m.frameID(7) or m.frameID(11)
                m.action("runstop")
            end if
		end if
	else if m.charAction = "turn"
		if ((m.keyL() and m.faceL()) or (m.keyR() and m.faceR())) and m.frameID(48)
			if m.nearBarrier()
				m.walk()
			else if not m.KeyS()
				m.action("turnrun")
			end if
		end if
    else if m.charAction = "medland"
        if not m.keyD() and m.frameID(109)
            'Special Case: First room of level 1 on startup
            if m.level.number = 1 and m.room = 1 and m.startup
                PlaySound("suspense")
            end if
            m.startup = false
        end if
	else if m.charAction = "stoop"
		if m.pickupSword and m.frameID(109)
			m.gotSword()
		else if m.pickupPotion and m.frameID(109)
			m.drinkPotion()
		else if not m.keyD() and m.frameID(109)
			m.action("standup")
			m.allowCrawl = true
		else if ((m.keyL() and m.faceL()) or (m.keyR() and m.faceR())) and m.allowCrawl
			m.action("crawl")
			m.allowCrawl = false
		end if
	else if m.charAction = "hang" or m.charAction = "hangstraight"
        tile = m.level.getTileAt(m.blockX, m.blockY, m.room)
        tileT = m.level.getTileAt(m.blockX, m.blockY-1, m.room)
	    if m.charAction = "hang"
    		if tile.element = m.const.TILE_WALL or tile.element = m.const.TILE_TAPESTRY or tile.element = m.const.TILE_TAPESTRY_TOP
    			m.action("hangstraight")
    		end if
        end if
        if tileT.element = m.const.TILE_SPACE
            m.startFall()
        end if
        if tileT.element = m.const.TILE_RAISE_BUTTON or tileT.element = m.const.TILE_DROP_BUTTON
            tileT.push()
        else if  tileT.element = m.const.TILE_LOOSE_BOARD
            tileT.shake(true)
        end if
		if m.keyU()
			m.climbup()
		else if not m.keyS()
			m.startFall()
		end if
    else if m.charAction = "climbup" or m.charAction = "climbdown"
        tile = m.level.getTileAt(m.blockX, m.blockY, m.room)
        tileT = m.level.getTileAt(m.blockX, m.blockY-1, m.room)
        if tile.element = m.const.TILE_RAISE_BUTTON or tile.element = m.const.TILE_DROP_BUTTON
            tile.push()
        else if tileT.element = m.const.TILE_RAISE_BUTTON or tileT.element = m.const.TILE_DROP_BUTTON
            if m.frameID(137,141)
                tileT.push()
            end if
        end if
        if tile.element = m.const.TILE_SPACE and m.frameID(142,146)
            m.startFall()
        end if
	else if m.charAction = "freefall" or m.charAction = "bumpfall"
		if m.keyS() then m.tryGrabEdge()
    else if m.charAction = "drinkpotion"
        if m.frameID(195)
            PlaySound("drink")
        end if
    else if m.charAction = "bump"
        if m.frameID(51)
            PlaySound("bump")
        end if
	else if m.charAction = "engarde"
		if ((m.keyL() and m.faceL()) or (m.keyR() and m.faceR())) and m.allowAdvance
			m.advance()
		else if ((m.keyL() and m.faceR()) or (m.keyR() and m.faceL())) and m.allowRetreat
			m.retreat()
		else if m.keyU() and m.allowBlock
			m.block()
		else if m.keyS() and m.allowStrike
			m.strike()
		else if m.keyD()
			m.fastSheathe()
		end if
	else if m.charAction = "advance" or m.charAction = "blockedstrike"
		if m.keyU() and m.allowBlock
			m.block()
		end if
	else if m.charAction = "retreat" or m.charAction = "strike" or m.charAction = "block"
		if m.keyS() and m.allowStrike
			m.strike()
		end if
    else if m.charAction = "resheathe" and m.frameID(52)
        m.cursors.shift = false
    end if
    if m.charAction <> "stabbed" and m.charAction <> "stabkill"
        m.splash.visible = false
    end if
End Sub

Sub process_command_kid()
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
            'Avoid retreat when non walkable tile is behind
            if m.charAction = "turnengarde"
                if m.faceL()
                    tileNext = m.level.getTileAt(m.blockX + 1, m.blockY, m.room)
                else
                    tileNext = m.level.getTileAt(m.blockX - 1, m.blockY, m.room)
                end if
                if not tileNext.isWalkable()
                    m.charAction = "engarde"
                    m.setPointer = 12
                else
                    m.charAction = data.p1
                    m.seqPointer = data.p2 - 1
                end if
            else
                m.charAction = data.p1
                m.seqPointer = data.p2 - 1
            end if
        else if data.cmd = m.const.CMD_IFWTLESS
            if m.isWeightless
                m.charAction = data.p1
                m.seqPointer = 0
            end if
        else if data.cmd = m.const.CMD_EFFECT
            tile = m.level.getTileAt(m.blockX, m.blockY,m.room)
            if m.charAction = "drinkpotion"
                if m.potion = m.const.POTION_HEALTH
                    if m.health < m.maxHealth
                        m.effect = m.colors.red
                        m.health = m.health + 1
                        PlaySound("small-life-potion")
                    end if
                else if m.potion = m.const.POTION_LIFE
                    if m.maxHealth < m.const.LIMIT_HEALTH
                        m.effect = m.colors.red
                        m.maxHealth = m.maxHealth + 1
                        m.health = m.maxHealth
                        PlaySound("big-life-potion")
                    end if
                else if m.potion = m.const.POTION_POISON
                    m.injured(true)
                    PlaySound("harm")
                else if m.potion = m.const.POTION_WEIGHTLESS
                    m.effect = m.colors.green
                    m.isWeightless = true
                    PlaySound("weightless-potion")
                else if m.potion = m.const.POTION_INVERT
                    FlipScreen()
                end if
                m.potion = 0
            else if  m.charAction = "pickupsword"
                m.effect = m.colors.yellow
            end if
        else if data.cmd = m.const.CMD_JARU
			m.level.shakeFloor(m.blockY - 1,m.room)
			tile = m.level.getTileAt(m.blockX, m.blockY - 1,m.room)
			if tile.element = m.const.TILE_LOOSE_BOARD
				tile.shake(true)
			end if
        else if data.cmd = m.const.CMD_JARD
			m.level.shakeFloor(m.blockY,m.room)
        else if data.cmd = m.const.CMD_FRAME
            m.frame = data.p1
            m.updateFrame()
            command = false
            if m.charAction = "medland" and m.frame = 108
                if not m.startup then m.injured(true)
            end if
        else if data.cmd = m.const.CMD_NEXTLEVEL
            if not m.success
                m.success = true
                if m.level.number = 4
                    PlaySound("success-suspense")
                else if m.level.number < 13
                    PlaySound("success")
                end if
                exit while
            end if
        else if data.cmd = m.const.CMD_DIE
			if m.swordDrawn
                PlaySound("fight-death")
            else
			    PlaySound("death")
            end if
            m.health = 0
            m.alive = false
			m.swordDrawn = false
        end if
        if data.cmd <> m.const.CMD_FRAME and data.cmd <> m.const.CMD_EFFECT and m.effect <> m.colors.black
            m.effect = m.colors.black
        end if
        m.seqPointer = m.seqPointer + 1
    end while
End Sub

Function get_kid_bounds() as object
    g = GetGlobalAA()
    f = g.regions.kid[m.face].Lookup(m.frameName)
	fWidth  = f.getWidth() / m.scale
	fHeight = f.getHeight() / m.scale
	if m.faceL()
		x = (g.xOff/m.scale) + m.x - m.charFdx
	else
		x = (g.xOff/m.scale) + m.x + m.charFdx
	end if
    y = (g.yOff/m.scale) + m.y + m.charFdy - fHeight
    if m.faceR()
        x = x - fWidth
    end if
    if (m.charFood and m.faceL()) or (not m.charFood and m.faceR())
        x = x + 1
    end if
    return {x: x, y: y, width: fWidth, height: fHeight}
End Function

Sub mask_and_crop()
    ' mask climbing
    if m.faceR() and m.frame > 134 and m.frame < 145
		m.frameName = m.frameName + "r"
	end if
    ' mask hanging
    if m.faceR() and m.charAction.mid(0,4) = "hang"
        m.level.maskTile(m.blockX, m.blockY - 1, m.room)
    else if m.faceR() and m.charAction = "jumphanglong" and m.frameID(79)
        m.level.maskTile(m.blockX, m.blockY - 1, m.room)
    else if m.faceR() and m.charAction = "jumpbackhang" and m.frameID(79)
        m.level.maskTile(m.blockX, m.blockY - 1, m.room)
    else if m.faceR() and m.charAction = "climbdown" and m.frameID(91)
        m.level.maskTile(m.blockX, m.blockY - 1, m.room)
    end if
    ' unmask falling / hangdroping
    if m.frameID(15)
		m.level.unMaskTiles()
	end if
    ' crop in jumpup
    if m.recoverCrop
        m.cropY = 0
        m.recoverCrop = false
    end if
    if m.inJumpUP and m.frameID(78)
        m.cropY = -7
    else if m.inJumpUP and m.frameID(81)
        m.cropY = -3
        m.inJumpUP = false
        m.recoverCrop = true
    else if m.charAction <> "jumpup"
        m.inJumpUP = false
        m.cropY = 0
    end if
End Sub

Sub check_barrier()
    if m.charAction= "hardland" or m.charAction = "impale" or m.charAction = "dropdead" or m.charAction = "jumphanglong"
        return
    else if m.charAction = "climbup" or m.charAction = "climbdown" or m.charAction = "climbfail" or m.charAction = "turn"
        return
    else if m.charAction.mid(0,4) = "step" or m.charAction.mid(0,4) = "hang" or m.charAction = "stoop" or m.charAction = "drinkpotion"
        return
    else if not m.alive or m.room < 0
        return
    else if m.swordDrawn and m.charAction.left(3) <> "run"
        m.checkFightBarrier()
        return
    else if m.charAction = "fastsheathe" or m.charAction = "resheathe"
        return
    end if

    'print "blocks:"; m.blockX; m.blockY - 1; m.room
    tileT = m.level.getTileAt(m.blockX, m.blockY - 1, m.room)
    if m.charAction = "freefall" and tileT.element = m.const.TILE_WALL
        if m.faceL()
            m.charX = ConvertBlockXtoX(m.blockX + 1) - 1
        else
            m.charX = ConvertBlockXtoX(m.blockX)
        end if
        print "bump: freefall"
        m.bump()
        return
    end if
    tile = m.level.getTileAt(m.blockX, m.blockY, m.room)
    m.element = tile.element 'current tile element for debugging

    if m.faceR() and tile.isBarrier() and tile.element <> m.const.TILE_MIRROR
        if tile.intersects(m.getCharBounds())
            m.charX = ConvertBlockXtoX(m.blockX) + 3
            m.updateBlockXY()
            print "bump: intersects right "; m.charAction
            m.bump()
        end if
    else
        if m.faceL()
            blockX = ConvertXtoBlockX(m.charX - m.charFdx)
        else
            blockX = ConvertXtoBlockX(m.charX + m.charFdx)
        end if
        tileNext = m.level.getTileAt(blockX, m.blockY, m.room)
        if tileNext <> invalid and tileNext.isBarrier()
            if tileNext.element = m.const.TILE_WALL
                if m.charAction = "stand" or m.charAction = "bump" then return
                if m.faceL()
                    m.charX = ConvertBlockXtoX(blockX + 1) - 1
                else
                    m.charX = ConvertBlockXtoX(blockX)
                end if
                if m.charAction <> "freefall" then m.updateBlockXY()
                print "bump: tile wall"; m.charX; m.blockX
                m.bump()
            else if tileNext.element = m.const.TILE_GATE
                if m.faceL() and tileNext.intersects(m.getCharBounds())
                    if m.charAction = "stand" and tile.element = m.const.TILE_GATE
                        m.charX = ConvertBlockXtoX(m.blockX) + 3
                        m.updateBlockXY()
                    else
                        m.charX = ConvertBlockXtoX(blockX + 1) - 1
                        m.updateBlockXY()
                        print "bump: tile gate"
                        m.bump()
                    end if
                end if
            else if tileNext.element = m.const.TILE_TAPESTRY or tileNext.element = m.const.TILE_TAPESTRY_TOP
                if m.charAction = "stand"
                    return
                end if
                if m.faceL()
                    m.charX = ConvertBlockXtoX(blockX + 1) - 1
                    m.updateBlockXY()
                    print "bump: tile tapestry"
                    m.bump()
                end if
            else if tileNext.element = m.const.TILE_MIRROR
                print "Mirror ahead..."
                if m.charAction = "stand" or m.charAction = "bump" then return
                if m.faceL() and (tileNext.intersects(m.getCharBounds()) or m.charAction <> "runjump")
                    m.charX = ConvertBlockXtoX(blockX) + 3
                    m.updateBlockXY()
                    print "bump: tile mirror"
                    m.bump()
                end if
            end if
        end if
    end if
End Sub

Sub check_room_change_kid()
    if m.charY > 189
        m.charY = m.charY - 189
        if m.gameHeight > 200
            m.baseY = m.baseY + 189
        end if
        if m.room >= 0
            m.room = m.level.rooms[m.room].links.down
        end if
    else if m.charY < 0
        m.charY = m.charY + 189
        if m.gameHeight > 200
            m.baseY = m.baseY - 189
        end if
        if m.room >= 0
            m.room = m.level.rooms[m.room].links.up
        end if
    end if
End Sub

Sub check_impale()
    if not m.alive or m.room < 0 then return
    tile = m.level.getTileAt(m.blockX, m.blockY, m.room)
    if tile.element = m.const.TILE_SPIKES
        if (m.charAction = "running" and tile.state = tile.STATE_RAISING) or ((m.frameId(26) or m.frameId(43)) and (tile.state = tile.STATE_RAISING or tile.state = tile.STATE_FULL_OUT))
            if m.faceL()
                m.charX = ConvertBlockXtoX(m.blockX) - 5
            else
                m.charX = ConvertBlockXtoX(m.blockX) + 10
            end if
            m.updateBlockXY()
            m.swordDrawn = false
            m.action("impale")
            PlaySound("spiked")
        end if
    end if
End Sub

Sub try_pickup()
    tile = m.level.getTileAt(m.blockX, m.blockY, m.room)
    if m.faceL()
        tileF = m.level.getTileAt(m.blockX - 1 , m.blockY, m.room)
    else
        tileF = m.level.getTileAt(m.blockX + 1 , m.blockY, m.room)
    end if
    m.pickupSword = (tile.element = m.const.TILE_SWORD and tile.hasObject) or (tileF.element = m.const.TILE_SWORD and tileF.hasObject)
    m.pickupPotion = (tile.element = m.const.TILE_POTION and tile.hasObject) or (tileF.element = m.const.TILE_POTION and tileF.hasObject)
    if m.pickupPotion or m.pickupSword
        if m.faceR()
            if tileF.element = m.const.TILE_POTION or tileF.element = m.const.TILE_SWORD
                m.blockX = m.blockX + 1
            end if
            m.charX = ConvertBlockXtoX(m.blockX) + (1 * BoolToInt(m.pickupPotion))
        else if m.faceL()
            if tile.element = m.const.TILE_POTION or tile.element = m.const.TILE_SWORD
                m.blockX = m.blockX + 1
            end if
            m.charX = ConvertBlockXtoX(m.blockX) - 3
        end if
        m.action("stoop")
        m.allowCrawl = false
        m.cursors.shift = false
    end if
End Sub

Sub drink_potion()
    m.action("drinkpotion")
    m.pickupPotion = false
    m.allowCrawl = true
    if m.faceL()
        x = m.blockX - 1
    else
        x = m.blockX + 1
    end if
    m.potion = m.level.getTileAt(x , m.blockY, m.room).modifier
    m.level.removeObject(x, m.blockY, m.room)
End Sub

Sub got_sword()
    m.action("pickupsword")
    m.pickupSword = false
    m.allowCrawl = true
    if m.faceL()
        x = m.blockX - 1
    else
        x = m.blockX + 1
    end if
    m.level.removeObject(x, m.blockY, m.room)
    m.haveSword = true
    PlaySound("glory")
End Sub

Sub turn_kid()
    if not m.haveSword or not m.canSeeOpponent() or m.opponentDistance() > 0
        m.action("turn")
    else
        m.action("turndraw")
        m.swordDrawn = true
        m.flee = false
    end if
End Sub

Sub walk_kid()
    px = 11
    tile = m.level.getTileAt(m.blockX, m.blockY, m.room)
	if m.faceL()
		tileF = m.level.getTileAt(m.blockX - 1, m.blockY, m.room)
	else
		tileF = m.level.getTileAt(m.blockX + 1, m.blockY, m.room)
	end if
    if m.nearBarrier() or (tileF.element = m.const.TILE_SPACE) or (tileF.element = m.const.TILE_POTION) or (tileF.element = m.const.TILE_LOOSE_BOARD) or (tileF.element = m.const.TILE_SWORD)
        px = m.distanceToEdge()
        print "dtoedge"; px
        if tile.element = m.const.TILE_GATE and not tile.canCross(m.getCharBounds().height) and m.faceR()
            px = px - 6
            if px <= 0
        		m.action("bump")
        		return
        	end if
        else if tile.element = m.const.TILE_TAPESTRY and m.faceR()
            px = px - 6
            if px <= 0
        		m.action("bump")
        		return
        	end if
        else if tile.element = m.const.TILE_MIRROR and m.faceL()
            px = px - 7
            if px <= 0
        		m.action("bump")
        		return
        	end if
        else
            if tileF.isBarrier()
                px = px - 2
                if px <= 0
					m.action("bump")
					return
				end if
            else
                if px = 0 and (tileF.element = m.const.TILE_LOOSE_BOARD or tileF.element = m.const.TILE_SPACE)
                    if m.charRepeat
                        m.charRepeat = false
                        px = 11
                    else
                        m.charRepeat = true
                        m.action("testfoot")
                        return
                    end if
                end if
            end if
        end if
    else if tile.element = m.const.TILE_SLICER or tileF.element = m.const.TILE_SLICER
        px = m.distanceToEdge()
        if m.faceL() then px = px - 8 else px = px - 6
        if px <= 0 then px = 11
    end if
    if px > 14
        px = 14
    else if px < 1
        px = 0
    end if
    if px > 0 then m.action("step" + itostr(px))
End Sub

Sub jump_kid()
	if m.faceL() then offset = -1 else offset = 1
    tile = m.level.getTileAt(m.blockX, m.blockY, m.room)
    tileF = m.level.getTileAt(m.blockX + offset, m.blockY, m.room)
    tileT = m.level.getTileAt(m.blockX, m.blockY - 1, m.room)
    tileTF = m.level.getTileAt(m.blockX + offset, m.blockY - 1, m.room)
    tileTR = m.level.getTileAt(m.blockX - offset, m.blockY - 1, m.room)
    tileR = m.level.getTileAt(m.blockX - offset, m.blockY, m.room)
    if tile.isExitDoor()
        if tile.element = m.const.TILE_EXIT_LEFT
            tile = m.level.getTileAt(m.blockX + 1, m.blockY,m.room)
        end if
        if tile.isOpen()
			m.climbstairs()
			return
		end if
    end if
    if tileT.isSpace() and tileTF.isWalkable()
        m.jumphanglong()
    else if tileT.isWalkable() and tileTR.isSpace() and tileR.isWalkable()
        if m.faceL() and ((ConvertBlockXtoX(m.blockX + 1) - m.charX) < 11)
            m.blockX = m.blockX + 1
            m.jumphanglong()
        else if m.faceR() and ((m.charX - ConvertBlockXtoX(m.blockX)) < 9)
            m.blockX = m.blockX - 1
            m.jumphanglong()
        else
			m.jumpup()
		end if
    else if tileT.isWalkable() and tileTR.isSpace()
        if (m.faceL() and ((ConvertBlockXtoX(m.blockX + 1) - m.charX) < 11)) or (m.faceR() and ((m.charX - ConvertBlockXtoX(m.blockX)) < 9))
            m.jumpbackhang()
		else
			m.jumpup()
        end if
    else if tileT.isSpace()
        m.highjump()
	else
		m.jumpup()
    end if
End Sub

Sub jumpup_kid()
    m.action("jumpup")
    m.inJumpUP = true
End Sub

Sub highjump_kid()
    if m.isWeightless
        m.action("superhighjump")
    else
        m.action("highjump")
    end if
End Sub

Sub jumphanglong_kid()
    if m.faceL()
        m.charX = ConvertBlockXtoX(m.blockX) + 1
    else
        m.charX = ConvertBlockXtoX(m.blockX) + 12
    end if
    m.action("jumphanglong")
    if (m.faceR())
        print "mask jumphangalong"
    end if
End Sub

Sub jumpbackhang_kid()
    if m.faceL()
        m.charX = ConvertBlockXtoX(m.blockX) + 7
    else
        m.charX = ConvertBlockXtoX(m.blockX) + 6
    end if
    m.action("jumpbackhang")
End Sub

Sub climb_stairs()
    if m.opponent <> invalid
        m.opponent.active = false
        m.opponent = invalid
    end if
    tile = m.level.getTileAt(m.blockX, m.blockY,m.room)
    if tile.element = m.const.TILE_EXIT_RIGHT
        m.blockX = m.blockX - 1
    else
        tile = m.level.getTileAt(m.blockX + 1, m.blockY,m.room)
    end if
    if m.faceR()
        m.face = m.const.FACE_LEFT
    end if
    m.charX = ConvertBlockXtoX(m.blockX) + 3
    tile.mask()
    m.action("climbstairs")
End Sub

Sub stoop_kid()
	if m.faceL()
		tileR = m.level.getTileAt(m.blockX + 1, m.blockY, m.room)
	else
		tileR = m.level.getTileAt(m.blockX - 1, m.blockY, m.room)
	end if
    if tileR.element = m.const.TILE_SPACE
        if m.faceL()
            if (m.charX - ConvertBlockXtoX(m.blockX)) > 4
				m.climbdown()
				return
			end if
        else
            if (m.charX - ConvertBlockXtoX(m.blockX)) < 9
				m.climbdown()
				return
			end if
        end if
    end if
    m.action("stoop")
End Sub

Sub climb_up()
    tileT = m.level.getTileAt(m.blockX, m.blockY - 1, m.room)
    if m.faceL() and tileT.element = m.const.TILE_GATE and not tileT.canCross(10)
        m.action("climbfail")
    else if m.faceR() and tileT.element = m.const.TILE_MIRROR
        m.action("hangdrop")
    else
        m.action("climbup")
        if m.faceR()
            print "unmask climbup"
            m.level.unMaskTiles()
        end if
    end if
End Sub

Sub climb_down()
    tile = m.level.getTileAt(m.blockX, m.blockY, m.room)
    if m.faceL() and (tile.element = m.const.TILE_GATE) and not tile.canCross(10)
        m.charX = ConvertBlockXtoX(m.blockX) + 3
    else
        if (m.faceL())
            m.charX = ConvertBlockXtoX(m.blockX) + 6
        else
            m.charX = ConvertBlockXtoX(m.blockX) + 7
        end if
        m.action("climbdown")
    end if
End Sub

Sub land_kid(tile as object)
    m.charY = ConvertBlockYtoY(m.blockY)
    m.charXVel = 0
    m.charYVel = 0
    m.swordDrawn = false

    if tile.element = m.const.TILE_SPIKES
        PlaySound("spiked")
        m.action("impale")
    else if m.fallingBlocks <= 1
        if not m.startup
            PlaySound("land-soft")
            m.action("softland")
        else
            m.action("medland")
        end if
    else if m.fallingBlocks = 2
        PlaySound("land-harm")
        m.action("medland")
    else
        m.swordDrawn = false
        PlaySound("land-fatal", false, 75)
        m.action("hardland")
        if tile.element = m.const.TILE_RAISE_BUTTON or tile.element = m.const.TILE_DROP_BUTTON
            tile.push(true, false)
        end if
    end if
    m.processCommand()
    if m.action() = "hardland"
        m.effect = m.colors.red
    end if
End Sub

Sub bump_kid()
    if not m.alive or m.room < 0 then return
    tile = m.level.getTileAt(m.blockX, m.blockY, m.room)
    if tile.isSpace()
        if m.faceL()
            m.charX = m.charX + 2
        else
            m.charX = m.charX - 2
        end if
        m.bumpFall()
    else
        y = m.distanceToFloor()
        if y >= 25
            m.bumpFall()
        else
            if m.frameID(24,25) or m.frameID(40,42) or m.frameID(102,106)
                if m.faceL()
                    m.charX = m.charX + 5
                else
                    m.charX = m.charX - 5
                end if
                m.land(tile)
            else
				print "bumping..."
                m.action("bump")
                m.processCommand()
            end if
        end if
    end if
End Sub

Sub start_fall_kid()
    m.fallingBlocks = 0
    if m.charAction.mid(0,4) = "hang"
        blockX = m.blockX
        if m.charAction = "hangstraight"
            if m.face =  m.const.FACE_LEFT
                blockX = blockX + 1
            else
                blockX = blockX - 1
            end if
        end if
        tile = m.level.getTileAt(blockX,m.blockY,m.room)
        if not tile.isSpace()
            tile = m.level.getTileAt(m.blockX, m.blockY, m.room)
            if tile.element = m.const.TILE_WALL
                if m.face =  m.const.FACE_LEFT
                    m.charX = m.charX + 7
                else
                    m.charX = m.charX - 7
                end if
            end if
            m.action("hangdrop")
        else
            m.action("hangfall")
            m.processCommand()
        end if
    else
        act = "stepfall"
        if m.frameID(44)
            act = "rjumpfall"
        else if m.frameID(26)
            act = "jumpfall"
        else if m.frameID(13)
            act = "stepfall2"
        end if
        if m.swordDrawn
            m.droppedOut = true
        end if
        if m.faceL()
            m.level.maskTile(m.blockX + 1,m.blockY,m.room)
        end if
        m.action(act)
        m.processCommand()
    end if
End Sub

Sub try_grab_edge()
	if m.faceL() then offset = -1 else offset = 1
    tileT = m.level.getTileAt(m.blockX, m.blockY - 1, m.room)
    tileTF = m.level.getTileAt(m.blockX + offset, m.blockY - 1, m.room)
    tileTR = m.level.getTileAt(m.blockX - offset, m.blockY - 1, m.room)
    if tileTF.isWalkable() and tileT.element = m.const.TILE_SPACE
        m.grab(m.blockX)
    else if tileT.isWalkable() and tileTR.element = m.const.TILE_SPACE
        m.grab(m.blockX - offset)
    end if
End sub

Sub grab_kid(x as integer)
    if m.faceL()
        m.charX = ConvertBlockXtoX(x) - 2
    else
        m.charX = ConvertBlockXtoX(x + 1) + 1
    end if
    m.charY = ConvertBlockYtoY(m.blockY)
    m.charXVel = 0
    m.charYVel = 0
    m.fallingBlocks = 0
    m.updateBlockXY()
    m.action("hang")
    m.processCommand()
End Sub

Function near_barrier() as boolean
    tile = m.level.getTileAt(m.blockX, m.blockY, m.room)
	if m.faceL()
		tileF = m.level.getTileAt(m.blockX - 1, m.blockY, m.room)
	else
		tileF = m.level.getTileAt(m.blockX + 1, m.blockY, m.room)
	end if
	height = m.getCharBounds().height
    return (tileF.element = m.const.TILE_WALL) or ((tileF.element = m.const.TILE_GATE) and m.faceL() and not tileF.canCross(height)) or ((tile.element = m.const.TILE_GATE) and m.faceR() and not tile.canCross(height)) or ((tile.element = m.const.TILE_TAPESTRY) and m.faceR()) or ((tileF.element = m.const.TILE_TAPESTRY) and m.faceL()) or ((tileF.element = m.const.TILE_TAPESTRY_TOP) and m.faceL())
End Function

Sub injured_kid(singleDamage = false as boolean)
    if (m.health = 0) return
    m.charY = ConvertBlockYtoY(m.blockY)
    if m.charName <> "skeleton"
        if m.swordDrawn or singleDamage
            damage =  1
        else
            damage = m.health
        end if
        m.health = m.health - damage
    end if
    if m.health = 0
        m.action("stabkill")
    else if m.swordDrawn
        m.action("stabbed")
    end if
    m.splash.visible = true
End Sub

Sub fast_sheathe()
    m.flee = true
    m.action("fastsheathe")
    m.swordDrawn = false
    if m.opponent <> invalid then m.opponent.refracTimer = 9
End Sub

Sub block_kid()
    if m.frameID(158) or m.frameID(165)
        if m.opponent <> invalid and m.opponent.frameID(18) then return
        m.action("block")
        if m.opponent <> invalid and m.opponent.frameID(3) then m.processCommand()
    else
        if not m.frameID(167) then return
        m.action("striketoblock")
    end if
    m.allowBlock = false
End Sub

Sub try_engarde()
    if m.opponent.alive and m.canSeeOpponent() and m.canReachOpponent() and m.opponentDistance() < 90
        m.engarde()
        m.flee = false
    end if
End Sub

Function can_do_kid(doAction as integer) as boolean
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
        if m.frameID(frame + 150) then return true
    next
    return false
End Function
