' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: June 2016
' **  Updated: August 2016
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function CheckSpecialEvents() as integer
    if m.currentLevel = 1 and m.kid.room = 1
        'Close Gate on Level 1 startup
        button = m.tileSet.level.getTileAt(2, 0, 5)
        for y = 0 to  2
            gate = m.tileSet.level.getTileAt(9, y, 5)
            if gate.element = m.const.TILE_GATE and gate.state = gate.STATE_OPEN
                gate.audio = true
                exit for
            end if
        next
        if button.element = m.const.TILE_DROP_BUTTON and button.pushes = 0 then button.push(false, false)
    else if m.currentLevel = 3
        'Room 2 gate sound shall be heard from anywhere
        gate = m.tileSet.level.getTileAt(9, 0, 2)
        if gate <> invalid and gate.element = m.const.TILE_GATE and not gate.audio then gate.audio = true
        if m.kid.room = 1
            'Skeleton is alive!
            if m.guards.Count() = 0 or m.kid.blockY = 0 or m.kid.level.exitOpen = 0
                return m.const.SPECIAL_CONTINUE
            end if
            skeleton = m.guards[0]
            if not skeleton.visible and skeleton.room = 1 and (m.kid.action() = "softland" or m.kid.action() = "stand")
                tile = m.kid.level.getTileAt(5, 1, 1)
                if tile.element = m.const.TILE_SKELETON
                    skeleton.active = true
                    skeleton.visible = true
                    skeleton.refracTimer = 20
                    skeleton.action("arise")
                    PlaySound("skeleton")
                    tile.element = m.const.TILE_FLOOR
                    tile.back = tile.key + "_1"
                    tile.front = tile.back + "_fg"
                    if tile.backSprite <> invalid and tile.frontSprite <> invalid
                        tile.backSprite.SetRegion(m.regions.tiles.Lookup(tile.back))
                        tile.frontSprite.SetRegion(m.regions.tiles.Lookup(tile.front))
                    end if
                end if
            end if
        else if m.kid.room = 2 and m.kid.blockY = 0
            'Save check point
            if m.kid.checkPoint.room <> 2
                m.kid.checkPoint = {room: 2, tile: 6, face: m.const.FACE_RIGHT}
            else
                tile = m.kid.level.getTileAt(4, 0, 7)
                if tile.element = m.const.TILE_LOOSE_BOARD
                    tile.element = m.const.TILE_SPACE
                    tile.back  = tile.key + "_0"
                    tile.front = tile.key + "_0_fg"
                    debris = m.kid.level.getTileAt(4, 2, 22)
                    debris.element = m.const.TILE_DEBRIS
                    debris.back  = debris.key + "_" + itostr(debris.element)
                    debris.front = debris.key + "_" + itostr(debris.element) + "_fg"
                    m.redraw = true
                end if
            end if
        end if
        'Skeleton fall and show again
        if m.guards.Count() > 0 and m.guards[0].room = 3
            skeleton = m.guards[0]
            if skeleton.visible and skeleton.action() = "stand" and not skeleton.meet
                skeleton.visible = false
            else if not skeleton.visible
                skeleton.charX = ConvertBlockXtoX(5)
                skeleton.charY = ConvertBlockYtoY(1)
                skeleton.face = m.const.FACE_RIGHT
                skeleton.fallingBlocks = 0
                skeleton.charXVel = 0
                skeleton.charYVel = 0
                skeleton.action("stand")
                skeleton.swordDrawn = false
                skeleton.active = true
                skeleton.visible = true
                skeleton.meet = true
            end if
        end if
    else if m.currentLevel = 4 and m.kid.room = 4 and m.kid.level.exitOpen > 0
        'Show Mirror on Level 4
        if m.kid.level.exitOpen = 1 and m.kid.blockY = 0
            tile = m.kid.level.getTileAt(4, 0, 4)
            tile.element = m.const.TILE_MIRROR
            tile.back  = tile.key + "_13"
            tile.front = tile.back + "_fg"
            if tile.backSprite <> invalid and tile.frontSprite <> invalid
                tile.backSprite.SetRegion(m.regions.tiles.Lookup(tile.back))
                tile.frontSprite.SetRegion(m.regions.tiles.Lookup(tile.front))
            end if
            tile.redraw  = true
            m.kid.level.exitOpen = 2
        else if m.kid.level.exitOpen = 2 and m.kid.blockY = 0
            PlaySound("suspense")
            m.kid.level.exitOpen = 3
        else if m.kid.level.exitOpen = 3
            if m.guards.Count() = 0 then return m.const.SPECIAL_CONTINUE
            tile = m.kid.level.getTileAt(m.kid.blockX, m.kid.blockY, m.kid.room)
            shadow = m.guards[0]
            if m.kid.charAction <> "runjump" and tile.element = m.const.TILE_MIRROR
                'Show mirror reflex
                kdRegion = m.regions.kid[Abs(m.kid.face - 1)].Lookup(m.kid.frameName).Copy()
                ctrMirror = tile.backSprite.GetX() + (22 * m.scale)
                reflexPos =  ctrMirror - Abs(m.kid.sprite.GetX() - ctrMirror) - kdRegion.GetWidth()
                if m.reflex = invalid
                    m.reflex = {}
                    m.reflex.kid = m.compositor.NewSprite(reflexPos, m.kid.sprite.GetY(), kdRegion, m.kid.z - 2)
                    bmp = GetPaintedBitmap(m.colors.black, 36 * m.scale, 56 * m.scale, true)
                    rgn = CreateObject("roRegion", bmp, 0, 0, bmp.GetWidth(), bmp.GetHeight())
                    if m.settings.spriteMode = m.const.SPRITES_MAC
                        maskX = tile.backSprite.GetX() - (34 * m.scale)
                    else
                        maskX = tile.backSprite.GetX() - (31 * m.scale)
                    end if
                    maskY = tile.backSprite.GetY() + (16 * m.scale)
                    m.reflex.mask = m.compositor.NewSprite(maskX, maskY, rgn, m.kid.z - 1)
                else
                    m.reflex.kid.SetRegion(kdRegion)
                    m.reflex.kid.MoveTo(reflexPos, m.kid.sprite.GetY())
                    m.reflex.kid.SetDrawableFlag(true)
                    m.reflex.mask.SetDrawableFlag(true)
                end if
            else if m.kid.charAction = "runjump" and m.kid.blockX < 8 and m.kid.blockY = 0
                'Split kid and shadow when jumping through the mirror
                if shadow.blockY > 0 and shadow.action() = "stand"
                    shadow.meet = false
                    shadow.charX = ConvertBlockXtoX(1)
                    shadow.charY = ConvertBlockYtoY(0)
                    shadow.action("runjump")
                else if m.kid.blockX = 4
                    shadow.meet = true
                else if m.kid.blockX = 3
                    PlaySound("mirror")
                end if
            else if m.reflex <> invalid
                m.reflex.kid.SetDrawableFlag(false)
                m.reflex.mask.SetDrawableFlag(false)
            end if
            if shadow.meet and shadow.sprite.GetX() >= tile.backSprite.GetX() and shadow.action() = "runjump"
                shadow.visible = true
            else if not shadow.visible and shadow.action() <> "runjump" and shadow.action() <> "stand"
                'Restore Shadow position
                shadow.room = 4
                shadow.baseX  = m.kid.level.rooms[shadow.room].x * m.const.ROOM_WIDTH
                shadow.baseY  = m.kid.level.rooms[shadow.room].y * m.const.ROOM_HEIGHT
                shadow.charX = ConvertBlockXtoX(2)
                shadow.charY = ConvertBlockYtoY(1)
                shadow.action("stand")
            end if
            if shadow.visible and shadow.blockY > 0
                'Hide Shadow
                shadow.visible = false
                shadow.action("stand")
                shadow.active = false
            end if
        end if
    else if m.currentLevel = 5
        'Shadow drinks potion before kid
        if m.guards.Count() = 0 or m.guards[0].charName <> "shadow"
            return m.const.SPECIAL_CONTINUE
        end if
        shadow = m.guards[0]
        if m.kid.room = 24 and m.kid.blockX = 6 and m.kid.blockY = 1 and not shadow.meet
            shadow.visible = true
            shadow.meet = true
            shadow.action("startrun")
        end if
        if shadow.visible
            if shadow.action() = "running" and shadow.faceR()
                tile = m.tileSet.level.getTileAt(shadow.blockX, shadow.blockY, shadow.room)
                if tile.element = m.const.TILE_POTION and tile.hasObject
                    shadow.action("drinkpotion")
                    m.tileSet.level.removeObject(shadow.blockX, shadow.blockY, shadow.room)
                end if
            else if shadow.action() = "stand"
                if shadow.faceR()
                    shadow.action("turn")
                else
                    shadow.action("startrun")
                end if
            else if shadow.room <> 24 and shadow.faceL()
                shadow.action("stand")
                shadow.visible = false
            end if
        end if
    else if m.currentLevel = 6
        if m.kid.room = 1
            'Shadow appearance and behavior
            if m.guards.Count() = 0 or m.guards[0].charName <> "shadow"
                return m.const.SPECIAL_CONTINUE
            end if
            shadow = m.guards[0]
            if not shadow.visible
                PlaySound("suspense")
                shadow.visible = true
            else if m.kid.blockX < 4
                if shadow.blockX = 0 and shadow.action() = "stand"
                    shadow.action("step11")
                end if
            end if
            if m.kid.level.exitOpen = 0
                m.kid.level.exitOpen = m.kid.level.rooms[1].links.down
            end if
        else if m.kid.room = m.kid.level.exitOpen
            'Automatically change from level 6 to Level 7
            if m.cameras = 1 or m.kid.blockY = 2
                NextLevel()
                return m.const.SPECIAL_RESET
            end if
        end if
    else if m.currentLevel = 8 and m.kid.level.exitOpen > 0
        if m.kid.room = 16
            'The Mouse saves the day!
            if m.mouse = invalid
                if m.wait = invalid then m.wait = 1 else m.wait = m.wait + 1
                if m.wait < 110 then return m.const.SPECIAL_CONTINUE
                m.mouse = CreateMouse(m.tileSet.level, 12, 6, m.const.FACE_LEFT)
                m.mouse.action("scurry")
            else if m.mouse.room = 12 and m.mouse.blockX = 6 and m.mouse.meet
                m.mouse.sprite.Remove()
                return m.const.SPECIAL_CONTINUE
            end if
            m.mouse.update()
            msRegion = m.regions.mouse[m.mouse.face].Lookup(m.mouse.frameName)
            if m.mouse.faceL()
                anchorX = (m.mouse.x * m.scale) - m.xOff
            else
                anchorX = (m.mouse.x * m.scale) - msRegion.GetWidth() - m.xOff
            end if
            anchorY = (m.mouse.y * m.scale) - msRegion.GetHeight() + m.topOffset - m.yOff
            if m.mouse.sprite = invalid and anchorX > 0 and anchorX <= m.gameWidth and anchorY > 0 and anchorY <= m.gameHeight
                m.mouse.sprite = m.compositor.NewSprite(anchorX, anchorY, msRegion, m.mouse.z)
            else if m.mouse.sprite <> invalid
                m.mouse.sprite.SetRegion(msRegion)
                m.mouse.sprite.MoveTo(anchorX,anchorY)
            end if
            if m.mouse.room = 16 and m.mouse.blockX = 7 and not m.mouse.meet
                if m.mouse.distanceToEdge() < 7 and m.mouse.charAction <> "leave"
                    m.mouse.action("leave")
                    m.mouse.meet = true
                end if
            end if
        else
            m.wait = 0
        end if
    else if m.currentLevel = 12
        'Shadow appearance
        if m.guards.Count() = 0 or m.guards[0].charName <> "shadow"
            return m.const.SPECIAL_CONTINUE
        end if
        shadow = m.guards[0]
        m.kid.leapOfFaith = false
        if m.kid.room = 15 and not shadow.meet
            if m.kid.blockX = 9 and m.kid.blockY = 1
                m.kid.level.removeObject(1, 0, 15)
                m.kid.health = m.kid.maxHealth
            else if m.kid.blockX <= 6 and m.kid.blockY = 0 and not shadow.visible
                shadow.charY = 0
                shadow.startfall()
                shadow.visible = true
            else if not shadow.active and shadow.visible and shadow.action() = "stoop"
                shadow.action("standup")
                shadow.active = true
                shadow.refracTimer = 9
            else if not shadow.alive and m.kid.alive
                m.kid.action("dropdead")
            else if shadow.visible and m.kid.action() = "fastsheathe" and shadow.active
                shadow.action("fastsheathe")
                shadow.opponent = invalid
                shadow.swordDrawn = false
                m.kid.opponent = invalid
                shadow.active = false
                shadow.meet = true
            end if
        else if (m.kid.room = 15 or m.kid.room = 2) and shadow.meet
            if shadow.visible
                objList = m.kid.sprite.CheckMultipleCollisions()
                if objList <> invalid
                    for each obj in objList
                        if obj.GetData() = "shadow"
                            m.kid.effect.color =  m.colors.white
                            m.kid.effect.cycles = 10
                            m.kid.cycles = 50
                            m.kid.face = shadow.face
                            shadow.visible = false
                            shadow.action("stand")
                            exit for
                        end if
                    next
                end if
                if m.kid.action() <> shadow.action() and shadow.visible
                    shadow.action(m.kid.action())
                end if
            else if m.kid.cycles > 0
                if m.kid.cycles = 1 then PlaySound("success")
                if m.kid.cycles mod 2 = 0
                    swRegion = m.regions.guards.shadow[m.kid.face].Lookup("shadow-" + itostr(m.kid.frame))
                    if swRegion <> invalid then m.kid.sprite.SetRegion(swRegion)
                end if
                m.kid.cycles = m.kid.cycles - 1
            else if m.kid.room = 2 and shadow.meet and not shadow.visible and m.kid.cycles = 0
                m.kid.leapOfFaith = true
            end if
        else if m.kid.room = 13 and shadow.meet and not shadow.visible and m.kid.cycles = 0
            m.kid.leapOfFaith = (m.kid.blockX > 5)
        else if m.kid.room = 23
            'Automatically change from level 12 to Level 13
            NextLevel()
        end if
        'Leap of faith mode - make space into floor
        if m.kid.leapOfFaith
            tile = m.kid.level.getTileAt(m.kid.blockX, m.kid.blockY, m.kid.room)
            if tile.redraw and tile.backSprite <> invalid and tile.frontSprite <> invalid
                tile.backSprite.SetRegion(m.regions.tiles.Lookup(tile.back))
                tile.frontSprite.SetRegion(m.regions.tiles.Lookup(tile.front))
            end if
        end if
    else if m.currentLevel = 13
        if m.kid.room = 23 or m.kid.room = 16
            'Drop all loose plates from above
            rndArray = RandomArray(2, 7)
            for x = 0 to rndArray.Count() - 1
                if m.kid.room = 23
                    tile = m.kid.level.getTileAt(rndArray[x], 2, 17)
                else
                    tile = m.kid.level.getTileAt(rndArray[x], 2, 1)
                end if
                if tile.backSprite <> invalid and tile.element = m.const.TILE_LOOSE_BOARD and not tile.fall
                    tile.shake(true)
                    exit for
                end if
            next
        else if m.kid.room = 1 and m.guards.Count() > 0
            'Meet Jaffar
            if m.guards[0].alive
                if not m.guards[0].meet
                    PlaySound("jaffar-meet")
                    m.guards[0].meet = true
                end if
            else if m.finalTime = 0
                m.finalTime = m.timeLeft
                m.showTime = true
            end if
        else if m.kid.room = 3 and m.guards.Count() > 0
            'Open the door if Jaffar is dead
            if not m.guards[0].alive
                if m.kid.level.exitOpen = 0
                    button = m.kid.level.getTileAt(0, 0, 24)
                    if button.element = m.const.TILE_RAISE_BUTTON then button.push(false, false)
                end if
            end if
        end if
    else if m.currentLevel = 14 and m.kid.room = 5
        'Saving the princess!
        PlayScene(m.gameScreen, 15, false)
        PlayEnding()
        return m.const.SPECIAL_FINISH
    end if
    return m.const.SPECIAL_CONTINUE
End Function
