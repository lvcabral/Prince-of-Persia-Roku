' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: June 2016
' **  Updated: June 2016
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function CheckSpecialEvents() as boolean
    if m.currentLevel = 1 and m.kid.room = 1
        'Close Gate on Level 1 startup
        button = m.tileSet.level.getTileAt(2, 0, 5)
        gate = m.tileSet.level.getTileAt(9, 0, 5)
        if gate.element = m.const.TILE_GATE and gate.state = gate.STATE_OPEN
            gate.audio = true
            if button.element = m.const.TILE_DROP_BUTTON then button.push(false, false)
        end if
    else if m.currentLevel = 3 and m.kid.room = 1
        'Skelleton is alive!
        if m.guards.Count() = 0 or m.kid.blockY = 0 or m.kid.level.exitOpen = 0 then return false
        if not m.guards[0].visible
            skeleton = m.guards[0]
            skeleton.active = true
            skeleton.visible = true
            skeleton.refracTimer = 9
            skeleton.action("arise")
            for x = 5 to 7
                tile = m.kid.level.getTileAt(x, 1, 1)
                if x = 5
                    tile.element = m.const.TILE_FLOOR
                    tile.back = tile.key + "_1"
                    tile.front = tile.back + "_fg"
                end if
                DrawTile(tile, m.xOff, m.yOff, m.gameWidth, m.gameHeight)
            next
            PlaySound("skeleton")
        end if
    else if m.currentLevel = 4 and m.kid.room = 4 and m.kid.level.exitOpen > 0
        'Show Mirror on Level 4
        if m.kid.level.exitOpen = 1 and m.kid.blockY = 0
            tile = m.kid.level.getTileAt(4, 0, 4)
            tile.element = m.const.TILE_MIRROR
            tile.back  = tile.key + "_mirror"
            tile.front = tile.back + "_fg"
            if tile.backSprite <> invalid and tile.frontSprite <> invalid
                print "Redraw mirror tile"
                tile.backSprite.SetRegion(m.tileSet.regions.lookup(tile.back))
                tile.frontSprite.SetRegion(m.tileSet.regions.lookup(tile.front))
            end if
            tile.redraw  = true
            m.kid.level.exitOpen = 2
        else if m.kid.level.exitOpen = 2 and m.kid.blockY = 0
            PlaySound("suspense")
            m.kid.level.exitOpen = 3
        else if m.kid.level.exitOpen = 3
            if m.guards.Count() = 0 then return false
            shadow = m.guards[0]
            if m.kid.charAction <> "runjump" and m.kid.blockX = 4 and m.kid.blockY = 0
                'Show mirror reflex
                kdRegion = m.kid.regions[Abs(m.kid.face - 1)].Lookup(m.kid.frameName).Copy()
                reflexPos = (150 * m.scale) - Abs(m.kid.sprite.GetX() - (150 * m.scale)) - kdRegion.GetWidth()
                if m.reflex = invalid
                    m.reflex = {}
                    m.reflex.kid = m.compositor.NewSprite(reflexPos, m.kid.sprite.GetY(), kdRegion, m.kid.z)
                    bmp = GetPaintedBitmap(m.colors.black, 36 * m.scale, 56 * m.scale, true)
                    rgn = CreateObject("roRegion", bmp, 0, 0, bmp.GetWidth(), bmp.GetHeight())
                    if m.settings.spriteMode = m.const.SPRITES_DOS
                        m.reflex.mask = m.compositor.NewSprite(96 * m.scale, 3 * m.scale, rgn, 35)
                    else
                        m.reflex.mask = m.compositor.NewSprite(94 * m.scale, 3 * m.scale, rgn, 35)
                    end if
                else
                    m.reflex.kid.SetRegion(kdRegion)
                    m.reflex.kid.MoveTo(reflexPos, m.kid.sprite.GetY())
                    m.reflex.kid.SetDrawableFlag(true)
                    m.reflex.mask.SetDrawableFlag(true)
                end if
            else if m.kid.charAction = "runjump" and m.kid.blockX < 8 and m.kid.blockY = 0
                'Split kid and shadow when jumping through the mirror
                if shadow.blockY > 0 and shadow.action() = "stand"
                    shadow.charX = ConvertBlockXtoX(1)
                    shadow.charY = ConvertBlockYtoY(0)
                    shadow.action("runjump")
                else if m.kid.blockX = 3
                    PlaySound("mirror")
                else if shadow.sprite.GetX() >= (129 * m.scale) and shadow.action() = "runjump"
                    shadow.visible = true
                end if
            else if not shadow.visible and shadow.action() <> "runjump" and shadow.action() <> "stand"
                shadow.room = 4
                shadow.charX = ConvertBlockXtoX(1)
                shadow.charY = ConvertBlockYtoY(1)
                shadow.action("stand")
            else if shadow.room <> 4 and shadow.blockY > 0 and shadow.action() = "stand"
                shadow.visible = false
            else if m.reflex <> invalid then
                m.reflex.kid.SetDrawableFlag(false)
                m.reflex.mask.SetDrawableFlag(false)
            end if
        end if
    else if m.currentLevel = 6
        if m.kid.room = 1
            'Shadow appearance and behavior
            if m.guards.Count() = 0 then return false
            shadow = m.guards[0]
            if not shadow.visible
                PlaySound("suspense")
                shadow.visible = true
            else if m.kid.blockX < 4
                if shadow.blockX = 0 and shadow.action() = "stand" then
                    shadow.action("step")
                end if
            end if
        else if m.kid.room = 3
            'Automatically change from level 6 to Level 7
            if m.cameras = 1 or m.kid.blockY = 2 then NextLevel()
        end if
    else if m.currentLevel = 8 and m.kid.level.exitOpen > 0
        if m.kid.room = 16
            'The Mouse saves the day!
            if m.mouse = invalid
                if m.wait = invalid then m.wait = 1 else m.wait = m.wait + 1
                if m.wait < 110 then return false
                m.mouse = CreateMouse(m.tileSet.level, 12, 6, m.const.FACE_LEFT)
                m.mouse.action("scurry")
            else if m.mouse.room = 12 and m.mouse.blockX = 6 and m.mouse.meet
                m.mouse.sprite.Remove()
                return false
            end if
            m.mouse.update()
            msRegion = m.mouse.regions[m.mouse.face].lookup(m.mouse.frameName)
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
        if m.kid.room = 2
            m.kid.leapOfFaith = true
        else if m.kid.room = 13
            m.kid.leapOfFaith = (m.kid.blockX > 5)
        else if m.kid.room = 23
            'Automatically change from level 12 to Level 13
            NextLevel()
        else
            m.kid.leapOfFaith = false
        end if
        'Leap of faith mode - make space into floor
        if m.kid.leapOfFaith
            tile = m.kid.level.getTileAt(m.kid.blockX, m.kid.blockY, m.kid.room)
            if tile.redraw
                DrawTile(tile, m.xOff, m.yOff, m.gameWidth, m.gameHeight)
                if m.kid.blockX = 9 and m.kid.room = 13
                    for x = 0 to 9
                        tile = m.kid.level.getTileAt(x, m.kid.blockY, 2)
                        DrawTile(tile, m.xOff, m.yOff, m.gameWidth, m.gameHeight)
                    next
                else
                    for x = m.kid.blockX + 1 to 9
                        tile = m.kid.level.getTileAt(x, m.kid.blockY, m.kid.room)
                        DrawTile(tile, m.xOff, m.yOff, m.gameWidth, m.gameHeight)
                    next
                end if
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
                if tile.element = m.const.TILE_LOOSE_BOARD and not tile.fall
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
        return true
    end if
    return false
End Function
