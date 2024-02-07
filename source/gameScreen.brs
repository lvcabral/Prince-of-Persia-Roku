' ********************************************************************************************************
' ********************************************************************************************************
' **  Prince of Persia for Roku - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: May 2016
' **  Updated: February 2024
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

function PlayGame() as boolean
    ClearScreenBuffers()
    'Set offsets
    m.xOff = (m.const.ROOM_WIDTH * m.scale) * m.tileSet.level.rooms[m.kid.room].x
    m.yOff = (m.const.ROOM_HEIGHT * m.scale) * m.tileSet.level.rooms[m.kid.room].y
    canvasX = Cint((m.mainWidth - m.gameWidth) / 2)
    canvasY = Cint((m.mainHeight - m.gameHeight) / 2)
    'Initialize flags and aux variables
    m.oldRoom = m.startRoom
    m.topOffset = 3 * m.scale
    m.speed = 80 '~12 fps
    m.redraw = true
    m.blink = [false, false]
    m.flash = false
    m.debugMode = false
    m.gameOver = false
    m.showTime = false
    m.gamePaused = false
    m.timeShown = 0
    m.finalTime = 0
    'Load wav sounds from Mod (if one is selected)
    if m.sounds.enabled then LoadModSounds()
    'Game Loop
    m.clock.Mark()
    m.timer.Mark()
    while true
        event = m.port.GetMessage()
        if type(event) = "roUniversalControlEvent"
            'Handle Remote Control events
            id = event.GetInt()
            if id = m.code.BUTTON_BACK_PRESSED
                m.audioPlayer.stop()
                if m.kid.alive and m.kid.level.number > 2 and m.settings.saveGame
                    saveOpt = MessageBox(m.mainScreen, 230, 100, "Save Game?")
                    if saveOpt = m.const.BUTTON_YES
                        if m.savedGame = invalid
                            m.savedGame = {}
                        end if
                        m.savedGame.level = m.kid.level.number
                        m.savedGame.checkPoint = m.kid.checkPoint
                        m.savedGame.health = m.startHealth
                        m.savedGame.time = m.levelTime
                        m.savedGame.modId = m.settings.modId
                        m.savedGame.cheat = m.usedCheat
                        SaveGame(m.savedGame)
                    end if
                else
                    saveOpt = MessageBox(m.mainScreen, 230, 100, "Exit Game?", 2)
                    if saveOpt = m.const.BUTTON_NO
                        saveOpt = m.const.BUTTON_CANCEL
                    end if
                end if
                if saveOpt <> m.const.BUTTON_CANCEL
                    DestroyChars()
                    m.debugMode = false
                    m.dark = false
                    return false
                end if
            else if m.gameOver
                m.gameOver = false
                m.status.Clear()
                m.checkPoint = m.kid.checkPoint
                ResetGame()
            else if CommandPause(id)
                m.gamePaused = true
                m.audioPlayer.stop()
            else if CommandRestart(id)
                if not m.debugMode
                    m.checkPoint = m.kid.checkPoint
                    ResetGame()
                else
                    m.dark = not m.dark
                    m.redraw = true
                end if
            else if CommandCheatNext(id)
                if m.settings.cheatMode = m.const.CHEAT_LEVEL
                    NextLevel()
                    m.usedCheat = true
                else if m.settings.cheatMode = m.const.CHEAT_HEALTH
                    if m.kid.maxHealth < m.const.LIMIT_HEALTH and m.kid.alive
                        m.kid.maxHealth++
                        m.kid.health = m.kid.maxHealth
                        PlaySound("big-life-potion", true)
                    end if
                    m.usedCheat = true
                else if m.settings.cheatMode = m.const.CHEAT_TIME
                    m.startTime += 60
                    m.status.Clear()
                    m.showTime = true
                    m.usedCheat = true
                end if
            else if CommandCheatPrev(id)
                if m.settings.cheatMode = m.const.CHEAT_LEVEL
                    PreviousLevel()
                else if m.settings.cheatMode = m.const.CHEAT_HEALTH
                    if m.kid.alive
                        m.kid.injured(true)
                        PlaySound("harm", true)
                    end if
                else if m.settings.cheatMode = m.const.CHEAT_TIME
                    if m.timeLeft > 60
                        m.startTime -= 60
                        m.status.Clear()
                        m.showTime = true
                    end if
                end if
                m.usedCheat = true
            else if CommandSpaceBar(id)
                if m.debugMode or m.settings.infoMode = m.const.INFO_TIME
                    m.redraw = m.debugMode
                    m.debugMode = false
                    m.dark = false
                    m.status.Clear()
                    m.showTime = true
                else
                    m.saveFrameName = ""
                    m.debugMode = true
                    m.kid.haveSword = true
                    m.kid.flee = false
                    version = "v" + m.manifest.major_version + "." + m.manifest.minor_version + "." + m.manifest.build_version
                    m.status.Push({ text: version + " * DEBUG MODE ON", duration: 2, alert: false })
                    m.redraw = true
                end if
            else
                m.kid.cursors.update(id, m.kid.swordDrawn)
            end if
        else if event = invalid
            'Game screen process
            ticks = m.clock.TotalMilliseconds()
            if ticks > m.speed
                m.clock.Mark()
                'Update sprites
                if not m.redraw
                    m.redraw = CheckMapRedraw()
                end if
                KidUpdate()
                if m.redraw or CheckVerticalNav()
                    DrawLevelRooms(m.xOff, m.yOff, m.gameWidth, m.gameHeight)
                end if
                special = CheckSpecialEvents()
                if special = m.const.SPECIAL_CONTINUE
                    GuardsUpdate()
                    CheckForOpponent()
                    TROBsUpdate()
                    MOBsUpdate()
                    MaskUpdate()
                    FlashBackGround()
                    SoundUpdate()
                    if CheckGameTimer()
                        return true
                    end if
                    'Paint Screen
                    m.compositor.AnimationTick(ticks)
                    m.compositor.DrawAll()
                    if m.flip
                        if m.gameScale <> 1.0
                            m.mainScreen.drawscaledobject(m.gameXOff, m.gameYOff, m.gameScale, m.gameScale, FlipVertically(m.gameCanvas))
                        else
                            m.mainScreen.DrawObject(canvasX, canvasY, FlipVertically(m.gameCanvas))
                        end if
                        DrawStatusBar(m.gameScreen, m.gameWidth, m.gameHeight)
                    else
                        DrawStatusBar(m.gameScreen, m.gameWidth, m.gameHeight)
                        if type(m.gameScreen) = "roBitmap"
                            if m.gameScale <> 1.0
                                m.mainScreen.drawscaledobject(m.gameXOff, m.gameYOff, m.gameScale, m.gameScale, m.gameScreen)
                            else
                                m.mainScreen.drawobject(m.gameXOff, m.gameYOff, m.gameScreen)
                            end if
                        end if
                    end if
                    m.mainScreen.SwapBuffers()
                    CheckPause()
                else if special = m.const.SPECIAL_FINISH
                    return true
                end if
            end if
        end if
    end while
end function

sub FlipScreen()
    g = GetGlobalAA()
    g.flip = not g.flip
    if g.flip
        g.compositor.SetDrawTo(g.gameCanvas, g.colors.black)
        g.speed = 30
    else
        g.compositor.SetDrawTo(g.gameScreen, g.colors.black)
        g.speed = 80
    end if
end sub

sub KidUpdate()
    m.kid.update()
    kdRegion = m.regions.kid[m.kid.face][m.kid.frameName].Copy()
    if m.kid.cropY < 0
        kdRegion.offset(0, -m.kid.cropY * m.scale, 0, m.kid.cropY * m.scale)
    end if
    if m.kid.faceL()
        anchorX = (m.kid.x * m.scale)
    else
        anchorX = (m.kid.x * m.scale) - kdRegion.GetWidth()
    end if
    anchorY = (m.kid.y * m.scale) - kdRegion.GetHeight() + m.topOffset
    if m.kid.sprite = invalid
        m.kid.sprite = m.compositor.NewSprite(anchorX, anchorY, kdRegion, m.kid.z)
    else
        m.kid.sprite.SetRegion(kdRegion)
        m.kid.sprite.MoveTo(anchorX, anchorY)
    end if
    if m.debugMode then DebugInfo(anchorX, anchorY)
    'Sword Sprite Update
    if m.kid.sword.visible
        if m.kid.sword.sprite <> invalid
            m.kid.sword.sprite.remove()
        end if
        swRegion = m.regions.sword[m.kid.face][m.kid.sword.frameName]
        if swRegion <> invalid
            if m.kid.faceL()
                swX = (m.kid.x - m.kid.sword.x) * m.scale
            else
                swX = (m.kid.x + m.kid.sword.x) * m.scale - swRegion.GetWidth()
            end if
            swY = (m.kid.y + m.kid.sword.y) * m.scale - swRegion.GetHeight() + m.topOffset
            swZ = m.kid.z + m.kid.sword.z
            m.kid.sword.sprite = m.compositor.NewSprite(swX, swY, swRegion, swZ)
        end if
    else if m.kid.sword.sprite <> invalid
        m.kid.sword.sprite.remove()
    end if
    'Harm splash update
    if m.kid.splash.sprite <> invalid
        m.kid.splash.sprite.remove()
    end if
    if m.kid.splash.visible
        spRegion = m.regions.general[m.kid.splash.frameName]
        if spRegion <> invalid
            spX = (m.kid.sprite.GetX() + kdRegion.GetWidth() / 2) - spRegion.GetWidth() / 2
            spY = (m.kid.sprite.GetY() + kdRegion.GetHeight() / 2) - spRegion.GetHeight() / 2
            m.kid.splash.sprite = m.compositor.NewSprite(spX, spY, spRegion, 25)
        end if
    end if
    'Disable Weightless state
    if m.kid.isWeightless and m.sounds.mp3.cycles = 0 then m.kid.isWeightless = false
    'Disable flip screen if kid is dead
    if not m.kid.alive and m.flip then FlipScreen()
    'Check level success
    if m.kid.success and m.sounds.mp3.cycles = 0 then NextLevel()
end sub

sub GuardsUpdate()
    for each guard in m.guards
        guard.update()
        gdRegion = m.regions.guards[guard.charImage][guard.face][guard.frameName]
        if guard.faceL()
            anchorX = (guard.x * m.scale) - m.xOff
        else
            anchorX = (guard.x * m.scale) - gdRegion.GetWidth() - m.xOff
        end if
        anchorY = (guard.y * m.scale) - gdRegion.GetHeight() + m.topOffset - m.yOff
        if m.debugMode and (guard.opponent <> invalid or guard.charName = "shadow")
            DebugGuard(anchorX, anchorY, guard)
        end if
        if guard.sprite = invalid and anchorX > 0 and anchorX <= m.gameWidth and anchorY > 0 and anchorY <= m.gameHeight
            guard.sprite = m.compositor.NewSprite(anchorX, anchorY, gdRegion, guard.z)
            guard.sprite.SetData(guard.charName)
            guard.sprite.SetDrawableFlag(guard.visible)
        else if guard.sprite <> invalid
            guard.sprite.SetRegion(gdRegion)
            guard.sprite.MoveTo(anchorX, anchorY)
            guard.sprite.SetDrawableFlag(guard.visible)
        end if
        'Sword Sprite Update
        if guard.sword.visible and guard.visible and guard.sprite <> invalid
            if guard.sword.sprite <> invalid
                guard.sword.sprite.remove()
            end if
            swRegion = m.regions.sword[guard.face][guard.sword.frameName]
            if swRegion <> invalid
                if guard.faceL()
                    swX = (guard.x - guard.sword.x) * m.scale - m.xOff
                else
                    swX = (guard.x + guard.sword.x) * m.scale - swRegion.GetWidth() - m.xOff
                end if
                swY = (guard.y + guard.sword.y) * m.scale - swRegion.GetHeight() + m.topOffset - m.yOff
                swZ = guard.z + guard.sword.z
                guard.sword.sprite = m.compositor.NewSprite(swX, swY, swRegion, swZ)
            end if
        else if guard.sword.sprite <> invalid
            guard.sword.sprite.remove()
        end if
        'Harm splash update
        if guard.splash.sprite <> invalid then guard.splash.sprite.remove()
        if guard.splash.visible and guard.visible
            spRegion = m.regions.general[guard.splash.frameName]
            if spRegion <> invalid
                spX = (guard.sprite.GetX() + gdRegion.GetWidth() / 2) - spRegion.GetWidth() / 2
                spY = (guard.sprite.GetY() + gdRegion.GetHeight() / 2) - spRegion.GetHeight() / 2
                guard.splash.sprite = m.compositor.NewSprite(spX, spY, spRegion, 25)
            end if
        end if
    next
end sub

sub DestroyChars()
    if m.kid <> invalid
        m.kid.opponent = invalid
        if m.kid.sprite <> invalid
            m.kid.sprite.Remove()
        end if
        if m.kid.sword.sprite <> invalid
            m.kid.sword.sprite.Remove()
        end if
        if m.kid.splash.sprite <> invalid
            m.kid.splash.sprite.Remove()
        end if
        m.kid = invalid
    end if
    if m.reflex <> invalid
        m.reflex.kid.Remove()
        m.reflex.kid = invalid
        m.reflex.mask.Remove()
        m.reflex.mask = invalid
        m.reflex = invalid
    end if
    if m.guards <> invalid and m.guards.Count() > 0
        for each guard in m.guards
            if guard.sprite <> invalid
                guard.sprite.Remove()
            end if
            if guard.sword.sprite <> invalid
                guard.sword.sprite.remove()
            end if
            if guard.splash.sprite <> invalid
                guard.splash.sprite.remove()
            end if
        next
        m.guards.Clear()
    end if
    if m.mouse <> invalid
        if m.mouse.sprite <> invalid
            m.mouse.sprite.Remove()
        end if
        m.mouse = invalid
    end if
end sub

function CheckGameTimer() as boolean
    finishGame = false
    if m.finalTime = 0 then m.timeLeft = m.startTime - m.timer.TotalSeconds()
    if m.kid.alive and m.timeLeft <> m.timeShown and m.timeLeft <= 60
        m.status.Push({ text: m.timeLeft.toStr() + " SECONDS LEFT", duration: 0, alert: false })
        if m.timeLeft <= 0
            PlayScene(m.gameScreen, 16, false)
            return true
        end if
        m.timeShown = m.timeLeft
    else if m.kid.alive and m.timeLeft <> m.timeShown and (m.timeLeft mod 300 = 0 or m.showTime)
        m.status.Push({ text: CInt(m.timeLeft / 60).toStr() + " MINUTES LEFT", duration: 2, alert: false })
        m.timeShown = m.timeLeft
        m.showTime = false
    else if m.kid.alive and m.gamePaused
        m.status.Clear()
        m.status.Push({ text:  "GAME PAUSED", duration: 0, alert: false })
    else if not m.kid.alive and not m.gameOver and m.sounds.mp3.cycles = 0
        m.gameOver = true
        m.debugMode = false
        m.dark = false
        m.status.Clear()
        m.status.Push({ text: "Press Button to Continue", duration: 15, alert: false })
        m.status.Push({ text: "Press Button to Continue", duration: 6, alert: true })
    else if m.gameOver and m.status.Count() = 0
        finishGame = true
    end if
    if finishGame
        m.kid.opponent = invalid
        m.kid.sprite.Remove()
        m.kid = invalid
    end if
    return finishGame
end function

sub TROBsUpdate()
    slicerCount = 0
    slicerState = 0
    slicerGap = 0
    for each trob in m.trobs
        if trob.tile.element = m.const.TILE_EXIT_RIGHT and m.kid.room = m.kid.level.prince.room and m.kid.room = trob.tile.room
            'Close Door on the start of every level
            if not trob.tile.dropped and trob.sprite.childBack <> invalid
                trob.tile.state = trob.tile.STATE_OPEN
                trob.tile.child.back.height = (8 + trob.tile.type)
                rgn = trob.sprite.childBack.GetRegion()
                rgn.Offset(0, 50 * m.scale, 0, -50 * m.scale)
                trob.tile.drop()
                PlaySound("exit-door-close")
            end if
        else if trob.tile.element = m.const.TILE_SLICER and trob.tile.roomY = m.kid.blockY and trob.sprite.visible
            'Start slicer(s) when kid is on the same Y
            roomT = trob.tile.room
            roomK = m.kid.room
            roomL = m.tileSet.level.rooms[m.kid.room].links.left
            roomR = m.tileSet.level.rooms[m.kid.room].links.right
            if roomT = roomL or roomT = roomK or roomT = roomR
                if not trob.tile.active
                    trob.tile.start()
                    trob.tile.stage = trob.tile.stage - slicerGap
                    slicerGap = slicerGap + 5
                    if slicerGap = 15
                        slicerGap = 0
                    end if
                end if
            end if
        end if
        'Update TROB state
        trob.tile.update()
        'Paint TROB if needed and is on screen
        if trob.tile.redraw and trob.sprite.visible
            if trob.tile.element = m.const.TILE_GATE
                trob.sprite.childFront.setDrawableFlag(trob.tile.state = trob.tile.STATE_CLOSED)
                if trob.tile.state = trob.tile.STATE_RAISING
                    rgn = trob.sprite.childBack.GetRegion()
                    rgn.offset(0, 1 * m.scale, 0, -1 * m.scale)
                else if trob.tile.state = trob.tile.STATE_DROPPING
                    if trob.tile.stage = 0
                        rgn = trob.sprite.childBack.GetRegion()
                        rgn.offset(0, -1 * m.scale, 0, 1 * m.scale)
                    end if
                else if trob.tile.state = trob.tile.STATE_FAST_DROPPING
                    rgn = trob.sprite.childBack.GetRegion()
                    rgn.offset(0, -10 * m.scale, 0, 10 * m.scale)
                else if trob.tile.state = trob.tile.STATE_CLOSED
                    trob.sprite.childBack.SetRegion(m.regions.tiles[trob.tile.child.back.frameName].Copy())
                end if
            else if trob.tile.element = m.const.TILE_RAISE_BUTTON or trob.tile.element = m.const.TILE_DROP_BUTTON
                if trob.tile.front <> invalid and trob.sprite.front <> invalid
                    trob.sprite.front.setRegion(m.regions.tiles[trob.tile.front])
                    trob.sprite.front.setDrawableFlag(true)
                else if trob.sprite.front <> invalid
                    trob.sprite.front.setDrawableFlag(false)
                end if
                trob.sprite.back.setRegion(m.regions.tiles[trob.tile.back])
            else if trob.tile.element = m.const.TILE_POTION
                if trob.tile.front = trob.tile.key + "_" + m.const.TILE_FLOOR.toStr() + "_fg" or trob.tile.front = trob.tile.key + "_" + m.const.TILE_DEBRIS.toStr() + "_fg"
                    trob.sprite.front.setRegion(m.regions.tiles[trob.tile.front])
                    trob.sprite.back.setRegion(m.regions.tiles[trob.tile.back])
                    if trob.sprite.childFront <> invalid
                        trob.tile.child.front.frames = invalid
                        trob.sprite.childFront.Remove()
                    end if
                end if
            else if trob.tile.element = m.const.TILE_SWORD or trob.tile.element = m.const.TILE_TORCH
                trob.sprite.back.setRegion(m.regions.tiles[trob.tile.back])
            else if trob.tile.element = m.const.TILE_SPIKES
                if trob.tile.modifier = 0
                    trob.sprite.childBack.setRegion(m.regions.tiles[trob.tile.child.back.frameName])
                    trob.sprite.childFront.setRegion(m.regions.tiles[trob.tile.child.front.frameName])
                end if
            else if trob.tile.element = m.const.TILE_SLICER and trob.tile.stage > 0 and trob.tile.stage <= 5
                trob.sprite.childBack.setRegion(m.regions.tiles[trob.tile.child.back.frameName])
                trob.sprite.childFront.setRegion(m.regions.tiles[trob.tile.child.front.frameName])
                if trob.tile.blood.visible
                    bloodX = 12
                    if m.settings.spriteMode = m.const.SPRITES_MAC
                        bloodY = [44, 65, 55, 31, 31]
                        x = (trob.tile.x * m.scale) + (bloodX * m.scale / 2)
                        y = (trob.tile.y * m.scale) + (bloodY[trob.tile.stage - 1] * m.scale / 2)
                    else
                        bloodY = [53, 40, 44, 64, 60]
                        x = (trob.tile.x + bloodX) * m.scale
                        y = (trob.tile.y + bloodY[trob.tile.stage - 1]) * m.scale
                    end if
                    if trob.sprite.blood = invalid
                        rgBlood = m.regions.general[trob.tile.blood.frameName]
                        trob.sprite.blood = m.compositor.NewSprite(x - m.xOff, y - m.yOff, rgBlood, 35)
                        m.map.Push(trob.sprite.blood)
                    else
                        trob.sprite.blood.setRegion(m.regions.general[trob.tile.blood.frameName])
                        trob.sprite.blood.MoveTo(x - m.xOff, y - m.yOff)
                    end if
                end if
            else if trob.tile.element = m.const.TILE_EXIT_RIGHT
                rgn = trob.sprite.childBack.GetRegion()
                if trob.tile.state = trob.tile.STATE_RAISING
                    rgn.offset(0, 1 * m.scale, 0, -1 * m.scale)
                else if trob.tile.state = trob.tile.STATE_DROPPING
                    rgn.offset(0, -10 * m.scale, 0, 10 * m.scale)
                end if
                trob.sprite.childBack.setDrawableFlag(trob.tile.child.back.visible)
                trob.sprite.childFront.setDrawableFlag(trob.tile.child.front.visible)
                if trob.tile.child.front.visible
                    trob.sprite.childBack.SetZ(30)
                end if
            end if
            trob.tile.redraw = false
        end if
    next
end sub

sub MOBsUpdate()
    for each mob in m.mobs
        if mob.tile <> invalid
            'Update MOB state
            mob.tile.update()
            'Paint MOB if needed and is on screen
            if mob.tile.redraw
                if mob.tile.element = m.const.TILE_LOOSE_BOARD
                    if mob.sprite.back <> invalid and mob.sprite.visible
                        mob.sprite.back.setRegion(m.regions.tiles[mob.tile.back])
                    else
                        if mob.tile.backSprite <> invalid
                            mob.tile.backSprite.Remove()
                        end if
                    end if
                    if mob.tile.state = mob.tile.STATE_SHAKING
                        if mob.sprite.visible
                            if mob.sprite.front <> invalid
                                mob.sprite.front.setDrawableFlag(false)
                            end if
                        else
                            if mob.sprite.front <> invalid
                                mob.sprite.front.Remove()
                            end if
                        end if
                    else if mob.tile.state = mob.tile.STATE_INACTIVE
                        if mob.sprite.visible
                            if mob.sprite.front <> invalid
                                mob.sprite.front.setDrawableFlag(true)
                            end if
                        else
                            if mob.sprite.front <> invalid
                                mob.sprite.front.Remove()
                            end if
                        end if
                    else if mob.tile.state = mob.tile.STATE_FALLING
                        if mob.sprite.front <> invalid
                            mob.sprite.front.Remove()
                        end if
                        if mob.sprite.back <> invalid and mob.sprite.visible
                            mob.sprite.back.MoveTo(mob.tile.x * m.scale - m.xOff, mob.tile.y * m.scale - m.yOff)
                        end if
                        if mob.floor = invalid or mob.tile.stage = 0
                            if mob.tile.type = m.const.TYPE_PALACE
                                space = mob.tile.key + "_0_1"
                            else
                                space = mob.tile.key + "_0_0"
                            end if
                            mob.floor = m.tileSet.level.floorStartFall(mob.tile)
                            if mob.sprite.back <> invalid
                                m.map.Push(m.compositor.NewSprite(mob.sprite.back.GetX(), mob.sprite.back.GetY(), m.regions.tiles[space], 10))
                                mob.floor.fromAbove = IsFromAbove(mob.sprite.back, m.kid.sprite)
                            end if
                        end if
                        if mob.floor <> invalid
                            if mob.floor.fromAbove and m.kid.blockX = mob.tile.roomX and CheckPlateHitFromAbove(mob.sprite.back, m.kid.sprite)
                                'print "injured with plate:";m.kid.action();m.kid.blockX
                                m.kid.action("medland")
                                mob.floor.fromAbove = false
                            end if
                        end if
                    else if mob.tile.state = mob.tile.STATE_CRASHED
                        if mob.sprite.back <> invalid
                            mob.sprite.back.Remove()
                        end if
                        if mob.tile.backSprite <> invalid
                            mob.tile.backSprite.Remove()
                        end if
                        if mob.floor <> invalid
                            debris = m.tileSet.level.floorStopFall(mob.floor)
                            if debris <> invalid and debris.backSprite <> invalid and debris.frontSprite <> invalid
                                debris.backSprite.SetRegion(m.regions.tiles[debris.back])
                                debris.frontSprite.SetRegion(m.regions.tiles[debris.front])
                            end if
                            mob.tile.element = m.const.TILE_SPACE
                            mob.tile = invalid
                            mob.floor = invalid
                        end if
                    end if
                end if
                if mob.tile <> invalid
                    mob.tile.redraw = false
                end if
            end if
        end if
    next
end sub

sub MaskUpdate()
    'Mask tile
    if m.kid.level.masked.Count() > 0
        masked = false
        for each tt in m.kid.level.masked
            if tt <> invalid and tt.frontSprite <> invalid
                if tt.back <> invalid
                    ts = tt.frontSprite
                    if tt.isMasked
                        masked = true
                        rgn = m.regions.tiles[tt.back].Copy()
                        rgn.offset(0, 0, -33 * m.scale, 0)
                        ts.setRegion(rgn)
                    else if tt.element = m.const.TILE_RAISE_BUTTON or tt.element = m.const.TILE_DROP_BUTTON
                        ts.setDrawableFlag(not tt.active)
                    else if tt.front <> invalid
                        rgn = m.regions.tiles[tt.front]
                        ts.setRegion(rgn)
                    end if
                end if
                tt.redraw = false
            end if
        next
        if masked then return
        m.kid.level.masked.Clear()
    end if
end sub

sub DrawLevelRooms(xOffset = 0 as integer, yOffset = 0 as integer, maxWidth = 1280 as integer, maxHeight = 720 as integer)
    'Clear map if exists
    DestroyMap()
    if m.dark then return
    'Draw level rooms
    m.map = [m.compositor.NewSprite(0, 0, CreateObject("roRegion", GetPaintedBitmap(255, maxWidth, maxHeight, true), 0, 0, maxWidth, maxHeight), 1)]
    m.map[0].SetMemberFlags(0)
    m.trobs = []
    for ry = m.tileSet.level.height - 1 to 0 step -1
        for rx = 0 to m.tileSet.level.width - 1
            r = m.tileSet.level.layout[ry][rx]
            if r <> -1 and m.tileSet.level.rooms[r] <> invalid
                for ty = 2 to 0 step -1
                    if not m.tileSet.level.rooms[r].links.hideLeft and m.tileSet.level.rooms[r].left.count() > 0
                        z = m.tileSet.level.rooms[r].links.leftZ
                        DrawTile(m.tileSet.level.rooms[r].left[ty], xOffset, yOffset, maxWidth, maxHeight, z)
                    end if
                    if m.tileSet.level.rooms[r].right.count() > 0
                        DrawTile(m.tileSet.level.rooms[r].right[ty], xOffset, yOffset, maxWidth, maxHeight)
                    end if
                    for tx = 0 to 9
                        tile = m.tileSet.level.rooms[r].tiles[ty * 10 + tx]
                        DrawTile(tile, xOffset, yOffset, maxWidth, maxHeight)
                        if not m.tileSet.level.rooms[r].links.hideUp and m.tileSet.level.rooms[r].up.count() > 0
                            DrawTile(m.tileSet.level.rooms[r].up[tx], xOffset, yOffset, maxWidth, maxHeight, 15)
                        end if
                    next
                next
            end if
        next
    next
    'print "map repainted"; m.mobs.count()
    m.redraw = false
end sub

sub DrawTile(tile as object, xOffset as integer, yOffset as integer, maxWidth as integer, maxHeight as integer, backZ = 10 as integer, frontZ = 30 as integer)
    if tile = invalid or tile.x = invalid then return
    if tile.isTrob() or tile.isMob()
        obj = { tile: tile, sprite: { visible: false } }
        obj.tile.audio = false
    end if
    x = (tile.x * m.scale) - xOffset
    y = (tile.y * m.scale) - yOffset
    yd = 0
    if x >= -m.const.TILE_WIDTH * m.scale and x <= maxWidth and y >= -m.const.TILE_HEIGHT * m.scale and y <= maxHeight 'only what can be shown
        if tile.isTrob() or tile.isMob()
            obj.sprite.visible = true
            if x < maxWidth - tile.width
                obj.tile.audio = true
            end if
        end if
        if tile.back <> invalid
            tileRegion = m.regions.tiles[tile.back]
            if tileRegion = invalid
                tileRegion = m.regions.tiles[tile.key + "_0"]
            end if
            if tileRegion.GetHeight() > m.const.TILE_HEIGHT * m.scale
                yd = tileRegion.GetHeight() - m.const.TILE_HEIGHT * m.scale
            end if
            sprite = m.compositor.NewSprite(x, y - yd, tileRegion, backZ)
            sprite.SetMemberFlags(0)
            if tile.isWalkable() or tile.element = m.const.TILE_SPACE
                if tile.backSprite <> invalid
                    tile.backSprite.Remove()
                end if
                tile.backSprite = sprite
            end if
            if tile.isTrob() or tile.isMob()
                obj.sprite.back = sprite
            end if
            if tile.isTrob() or not tile.isMob()
                m.map.Push(sprite)
            end if
        end if
        if tile.front <> invalid
            useWDA = (m.settings.SpriteMode > m.const.SPRITES_MAC and m.settings.modId <> invalid and m.mods[m.settings.modId].wda)
            if tile.type = m.const.TYPE_PALACE and tile.element = m.const.TILE_WALL and not useWDA
                useMod = (m.settings.modId <> invalid and m.mods[m.settings.modId].palettes and m.settings.spriteMode = Val(m.settings.modId))
                if useMod
                    modPath = m.mods[m.settings.modId].url + m.mods[m.settings.modId].path
                    if Left(modPath, 3) = "pkg"
                        modPath = modPath + "palettes/"
                    end if
                end if
                if useMod and m.files.Exists(modPath + "wall.pal")
                    wc = LoadPalette(modPath + "wall.pal", 8, 5)
                else
                    wc = m.tileSet.wallColor
                end if
                wp = m.tileSet.level.rooms[tile.room].wallPattern
                bmd = CreateObject("roBitmap", { width: m.const.TILE_WIDTH, height: m.const.TILE_HEIGHT, alphaenable: true })
                bmd.DrawRect(0, 16, 32, 20, wc[wp[tile.roomY][0][tile.roomX]])
                bmd.DrawRect(0, 36, 16, 21, wc[wp[tile.roomY][1][tile.roomX]])
                bmd.DrawRect(16, 36, 16, 21, wc[wp[tile.roomY][1][tile.roomX + 1]])
                bmd.DrawRect (0, 57, 8, 19, wc[wp[tile.roomY][2][tile.roomX]])
                bmd.DrawRect(8, 57, 24, 19, wc[wp[tile.roomY][2][tile.roomX + 1]])
                bmd.DrawRect(0, 76, 32, 3, wc[wp[tile.roomY][3][tile.roomX]])
                bms = ScaleBitmap(bmd, m.scale)
                tb = (m.const.TILE_HEIGHT - m.const.BLOCK_HEIGHT - 3) * m.scale
                seed = Int(Val(Mid(tile.front, InStr(1, tile.front, "_") + 1)))
                DrawWallmark(bms, m.const.BLOCK_WIDTH * m.scale, tb + 10 * m.scale, m.regions.tiles[WallMarks(seed, 0)])
                DrawWallmark(bms, 0, tb + 29 * m.scale, m.regions.tiles[WallMarks(seed, 1)])
                DrawWallmark(bms, 0, tb + 50 * m.scale, m.regions.tiles[WallMarks(seed, 2)])
                DrawWallmark(bms, 0, tb + 63 * m.scale, m.regions.tiles[WallMarks(seed, 3)])
                DrawWallmark(bms, 0, tb + 66 * m.scale, m.regions.tiles[WallMarks(seed, 4)])
                bmd = invalid
                frsp = m.compositor.NewSprite(x, y, CreateObject("roRegion", bms, 0, 0, bms.GetWidth(), bms.GetHeight()), frontZ)
                frsp.SetMemberFlags(0)
            else if tile.element = m.const.TILE_WALL
                wall = Left(tile.front, 3)
                seed = Int(Val(Mid(tile.front, InStr(1, tile.front, "_") + 1)))
                'Create wall bitmap
                rgw = m.regions.tiles[wall]
                bms = CreateObject("roBitmap", { width: rgw.GetWidth(), height: rgw.GetHeight(), alphaenable: true })
                bms.DrawObject(0, 0, rgw)
                'Draw random marks
                if m.regions.tiles["dungeon_wall_mark_1"] <> invalid
                    'Setup pseudo random method
                    m.prandom.seed = seed
                    m.prandom.get(1) 'discard first value
                    r = []
                    r.Push(m.prandom.get(1))
                    r.Push(m.prandom.get(4))
                    r.Push(m.prandom.get(1))
                    r.Push(m.prandom.get(4))
                    'Gray Tile
                    if Right(wall, 2) = "WW" and m.prandom.get(4) = 0
                        bms.DrawObject(0, 16 * m.scale, m.regions.tiles["dungeon_wall_random"])
                    end if
                    'Tile Dividers
                    if wall <> "SWS"
                        divName = "dungeon_wall_divider_" + (r[0] + 1).toStr()
                        bms.DrawObject((8 + r[1]) * m.scale, 37 * m.scale, m.regions.tiles[divName])
                    end if
                    if Left(wall, 2) = "WW"
                        divName = "dungeon_wall_divider_" + (r[2] + 1).toStr()
                        bms.DrawObject(r[3] * m.scale, 58 * m.scale, m.regions.tiles[divName])
                    end if
                    'Wall Marks
                    if wall = "SWS"
                        if m.prandom.get(6) = 0
                            DrawLeftMark(bms, r, m.prandom.get(1))
                        end if
                    else if wall = "SWW"
                        if m.prandom.get(4) = 0
                            DrawRightMark(bms, r, m.prandom.get(3))
                        end if
                        if m.prandom.get(4) = 0
                            DrawLeftMark(bms, r, m.prandom.get(3))
                        end if
                    else if wall = "WWS"
                        if m.prandom.get(4) = 0
                            DrawRightMark(bms, r, m.prandom.get(1) + 2)
                        end if
                        if m.prandom.get(4) = 0
                            DrawLeftMark(bms, r, m.prandom.get(4))
                        end if
                    else if wall = "WWW"
                        if m.prandom.get(4) = 0
                            DrawRightMark(bms, r, m.prandom.get(3))
                        end if
                        if m.prandom.get(4) = 0
                            DrawLeftMark(bms, r, m.prandom.get(4))
                        end if
                    end if
                end if
                if m.debugMode
                    font = m.fonts.reg.GetDefaultFont(12, false, false)
                    bms.DrawText(tile.front, 5, 35, m.colors.white, font)
                end if
                frsp = m.compositor.NewSprite(x, y, CreateObject("roRegion", bms, 0, 0, bms.GetWidth(), bms.GetHeight()), frontZ)
            else
                tr = m.regions.tiles[tile.front]
                if tr = invalid
                    tr = m.regions.tiles[tile.key + "_0"]
                end if
                frsp = m.compositor.NewSprite(x, y, tr, frontZ)
            end if
            frsp.SetMemberFlags(0)
            m.map.Push(frsp)
            if tile.isWalkable() or tile.element = m.const.TILE_SPACE
                'link the tile to allow masking
                if tile.frontSprite <> invalid
                    tile.frontSprite.Remove()
                end if
                tile.frontSprite = frsp
            end if
            if tile.isTrob() or tile.isMob()
                obj.sprite.front = frsp
            end if
            if tile.element = m.const.TILE_SLICER
                if m.debugMode
                    '"debug box "; x;y;tile.getBounds().width;tile.getBounds().height
                    bw = tile.getBounds().width * m.scale
                    bh = tile.getBounds().height * m.scale
                    bmt = CreateObject("roBitmap", { width: bw, height: bh, alphaenable: true })
                    bmt.drawrect(0, 0, bw, bh, &hFF000070)
                    slr = CreateObject("roRegion", bmt, 0, 0, bmt.GetWidth(), bmt.GetHeight())
                    m.map.Push(m.compositor.NewSprite(x + (15 * m.scale), y + (10 * m.scale), slr, 35))
                end if
            end if
        end if
        'Child frames
        chbk = tile.child.back
        chfr = tile.child.front
        if chbk.frameName <> invalid and m.regions.tiles[chbk.frameName] <> invalid
            rgn = m.regions.tiles[chbk.frameName].Copy()
            if tile.element = m.const.TILE_EXIT_RIGHT
                bmd = CreateObject("roBitmap", { width: rgn.GetWidth(), height: rgn.GetHeight() * 2, alphaenable: true })
                bmd.DrawObject(0, rgn.GetHeight(), rgn)
                rgn = CreateObject("roRegion", bmd, 0, rgn.GetHeight(), rgn.GetWidth(), rgn.GetHeight())
                if tileRegion <> invalid
                    if m.settings.spriteMode = m.const.SPRITES_MAC
                        chbk.y = CInt(tileRegion.GetHeight() / m.scale) - 71
                    else
                        chbk.y = CInt(tileRegion.GetHeight() / m.scale) - 67
                    end if
                end if
            end if
            if tile.cropY < 0
                rgn.offset(0, -tile.cropY * m.scale, 0, tile.cropY * m.scale)
            end if
            if rgn.GetHeight() > m.const.TILE_HEIGHT * m.scale
                yd = rgn.GetHeight() - m.const.TILE_HEIGHT * m.scale
            end if
            spbk = m.compositor.NewSprite(x + chbk.x * m.scale, (y - yd) + chbk.y * m.scale, rgn, backZ)
            spbk.setDrawableFlag(chbk.visible)
            spbk.SetMemberFlags(0)
            if tile.isTrob()
                obj.sprite.childBack = spbk
            end if
            m.map.Push(spbk)
        else if tile.child.back.frames <> invalid
            animation = []
            for each frameName in tile.child.back.frames
                animation.Push(m.regions.general[frameName])
            next
            spbk = m.compositor.NewAnimatedSprite(x + chbk.x * m.scale, (y - yd) + chbk.y * m.scale, animation, backZ)
            spbk.SetMemberFlags(0)
            if tile.isTrob()
                obj.sprite.childBack = spbk
            end if
            m.map.Push(spbk)
        end if
        if chfr.frameName <> invalid
            chrg = m.regions.tiles[chfr.frameName]
            if chrg = invalid and Left(chfr.frameName, 2) = "W_"
                chrg = m.regions.tiles["W_15"]
            end if
            spfr = m.compositor.NewSprite(x + chfr.x * m.scale, (y - yd) + chfr.y * m.scale, chrg, frontZ)
            spfr.SetMemberFlags(0)
            spfr.setDrawableFlag(chfr.visible)
            if tile.isTrob()
                obj.sprite.childFront = spfr
            end if
            m.map.Push(spfr)
        else if tile.child.front.frames <> invalid
            animation = []
            for each frameName in tile.child.front.frames
                animation.Push(m.regions.general[frameName])
            next
            spfr = m.compositor.NewAnimatedSprite(x + chfr.x * m.scale, (y - yd) + chfr.y * m.scale, animation, frontZ)
            spfr.SetMemberFlags(0)
            if tile.isTrob()
                obj.sprite.childFront = spfr
            end if
            m.map.Push(spfr)
        end if
    end if
    if tile.isTrob()
        m.trobs.Push(obj)
    else if tile.isMob()
        m.mobs.Push(obj)
    end if
    tile.redraw = false
end sub

sub DrawWallmark(bms as object, x, y, region)
    if x > 0
        x = x - region.GetWidth()
    end if
    bms.DrawObject(x, y - region.GetHeight(), region)
end sub

sub DrawLeftMark(bms as object, r as object, rn as integer)
    i = 0
    xw = 0
    if rn > 3
        i = 2
        xw = r[3] - r[2] + 6
    else if rn > 1
        i = 1
        xw = r[1] - r[0] + 6
    end if
    if rn = 2 or rn = 3
        xw = xw + 8
    end if
    if rn mod 2 = 0
        yw = 16 + (21 * i)
        bms.DrawObject(xw * m.scale, yw * m.scale, m.regions.tiles["dungeon_wall_mark_1"])
    else
        yw = 33 + (21 * i)
        bms.DrawObject(xw * m.scale, yw * m.scale, m.regions.tiles["dungeon_wall_mark_2"])
    end if
end sub

sub DrawRightMark(bms as object, r as object, rn as integer)
    i = 0
    xw = 24
    if rn > 3
        i = 2
        xw = r[1] - 3
    else if rn > 1
        i = 1
        xw = r[1] - 3
    end if
    if rn > 1
        xw = xw + 8
    end if
    if rn mod 2 = 0
        yw = 17 + (21 * i)
        bms.DrawObject(xw * m.scale, yw * m.scale, m.regions.tiles["dungeon_wall_mark_3"])
    else
        yw = 27 + (21 * i)
        bms.DrawObject(xw * m.scale, yw * m.scale, m.regions.tiles["dungeon_wall_mark_4"])
    end if
end sub

sub DestroyMap()
    if m.mobs <> invalid
        new = []
        for each mob in m.mobs
            if mob.tile <> invalid and mob.tile.element = m.const.TILE_LOOSE_BOARD
                if mob.tile.fall
                    new.Push(mob)
                else if mob.sprite.back <> invalid
                    mob.sprite.back.remove()
                end if
            end if
        next
        m.mobs.clear()
        m.mobs = new
    else
        m.mobs = []
    end if
    if m.map <> invalid
        for each sprite in m.map
            if sprite <> invalid
                sprite.remove()
            end if
        next
    end if
end sub

sub FlashBackGround()
    if m.kid.effect.color <> m.colors.black and m.kid.effect.cycles > 0
        m.flash = not m.flash
        if m.flash
            bmp = GetPaintedBitmap(m.kid.effect.color, m.gameWidth, m.gameHeight, true)
            m.kid.effect.cycles = m.kid.effect.cycles - 1
        else
            bmp = GetPaintedBitmap(m.colors.black, m.gameWidth, m.gameHeight, true)
        end if
        m.map[0].SetRegion(CreateObject("roRegion", bmp, 0, 0, m.gameWidth, m.gameHeight))
    else if m.flash
        bmp = GetPaintedBitmap(m.colors.black, m.gameWidth, m.gameHeight, true)
        m.map[0].SetRegion(CreateObject("roRegion", bmp, 0, 0, m.gameWidth, m.gameHeight))
        m.kid.effect.cycles = 0
        m.flash = false
    end if
end sub

function CheckMapRedraw() as boolean
    redraw = false
    if m.cameras = 1 and m.kid.sprite <> invalid
        kidWidth = m.kid.sprite.GetRegion().GetWidth() / m.scale
        midWidth = cint(kidWidth / 2)
        if m.kid.room <> m.oldRoom and m.kid.room >= 0
            if m.kid.x + midWidth + 6 < 0
                m.kid.baseX = m.kid.baseX + m.const.ROOM_WIDTH
                redraw = true
            end if
            if redraw
                m.xOff = (m.const.ROOM_WIDTH * m.scale) * m.tileSet.level.rooms[m.kid.room].x
                m.oldRoom = m.kid.room
                print "changed camera focus left - new offsets:"; m.xOff; m.yOff
            end if
        else if m.kid.blockX = 9 and m.tileSet.level.rooms[m.oldRoom].links.right > 0
            if m.kid.swordDrawn
                gap = midWidth
            else
                gap = 0
            end if
            if m.kid.x + gap > m.const.ROOM_WIDTH
                m.kid.baseX = m.kid.baseX - m.const.ROOM_WIDTH
                redraw = true
            end if
            if redraw
                nextRoom = m.tileSet.level.rooms[m.oldRoom].links.right
                m.xOff = (m.const.ROOM_WIDTH * m.scale) * m.tileSet.level.rooms[nextRoom].x
                m.oldRoom = nextRoom
                'print "changed camera focus right - new offsets:"; m.xOff; m.yOff
            end if
        end if
    else if m.kid.sprite <> invalid
        factorX = int(m.gameWidth / 320)
        factorY = int(m.gameHeight / 200)
        kidWidth = m.kid.sprite.GetRegion().GetWidth()
        midWidth = cint(kidWidth / 2)
        if m.kid.x > m.gameWidth
            nextRoom = m.tileSet.level.rooms[m.kid.room].links.right
            if nextRoom > 0 and abs(m.tileSet.level.rooms[nextRoom].x - m.tileSet.level.rooms[m.startRoom].x) mod factorX = 0
                m.kid.baseX = m.kid.baseX - m.gameWidth
                m.xOff = m.const.ROOM_WIDTH * m.tileSet.level.rooms[nextRoom].x
                redraw = true
            end if
        else if m.kid.x + midWidth + 6 < 0
            if abs(m.tileSet.level.rooms[m.kid.room].x - m.tileSet.level.rooms[m.startRoom].x) mod factorX <> 0
                m.kid.baseX = m.kid.baseX + m.gameWidth
                m.xOff = m.const.ROOM_WIDTH * (m.tileSet.level.rooms[m.kid.room].x - (factorX - 1))
                redraw = true
            end if
        else if m.kid.y > m.gameHeight
            if abs(m.tileSet.level.rooms[m.kid.room].y - m.tileSet.level.rooms[m.startRoom].y) mod factorY = 0
                m.kid.baseY = m.kid.baseY - (m.const.ROOM_HEIGHT * factorY)
                m.yOff = m.const.ROOM_HEIGHT * m.tileSet.level.rooms[m.kid.room].y
                redraw = true
            end if
        else if m.kid.y < 0
            if abs(m.tileSet.level.rooms[m.kid.room].y - m.tileSet.level.rooms[m.startRoom].y) mod factorY <> 0
                m.kid.baseY = m.kid.baseY + (m.const.ROOM_HEIGHT * factorY)
                m.yOff = m.const.ROOM_HEIGHT * (m.tileSet.level.rooms[m.kid.room].y - (factorY - 1))
                redraw = true
            end if
        end if
    end if
    return redraw
end function

function CheckVerticalNav() as boolean
    if m.cameras = 1
        if m.kid.room <> m.oldRoom and m.kid.room >= 0
            if m.kid.room = m.tileSet.level.rooms[m.oldRoom].links.up or m.kid.room = m.tileSet.level.rooms[m.oldRoom].links.down
                m.yOff = (m.const.ROOM_HEIGHT * m.scale) * m.tileSet.level.rooms[m.kid.room].y
                m.oldRoom = m.kid.room
                return true
            end if
        end if
    end if
    return false
end function

function IsFromAbove(st as object, sk as object) as boolean
    return (st.GetY() + st.GetRegion().GetHeight()) < sk.GetY()
end function

function CheckPlateHitFromAbove(st as object, sk as object) as boolean
    stW = st.GetRegion().GetWidth()
    stH = st.GetRegion().GetHeight()
    skW = sk.GetRegion().GetWidth()
    skH = sk.GetRegion().GetHeight()
    res = false
    if (st.GetX() + stW) > sk.GetX()
        if st.GetX() < (sk.GetX() + skW)
            if (st.GetY() + stH) >= sk.GetY()
                if (st.GetY() + stH) - skH < sk.GetY()
                    'print "hit: "; st.GetX();"<";(sk.GetX() + skW); " and ";  (st.GetX() + stW);">";sk.GetX()
                    res = true
                end if
            end if
        end if
    end if
    return res
end function

sub CheckForOpponent()
    if m.settings.fight = m.const.FIGHT_FROZEN then return
    for each guard in m.guards
        if guard.room = m.kid.room and guard.alive and guard.opponent = invalid and guard.active
            m.kid.opponent = guard
            guard.opponent = m.kid
        else if m.kid.opponent = invalid and guard.opponent <> invalid
            guard.opponent = invalid
        end if
    next
end sub

sub CheckPause()
    while m.gamePaused
        event = Wait(0, m.port)
        if type(event) = "roUniversalControlEvent"
            id = event.GetInt()
            if CommandPause(id) or id = m.code.BUTTON_BACK_PRESSED
                m.status.Clear()
                m.gamePaused = false
            end if
        end if
    end while
end sub