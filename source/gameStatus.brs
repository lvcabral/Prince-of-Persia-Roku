' ********************************************************************************************************
' ********************************************************************************************************
' **  Prince of Persia for Roku - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: April 2016
' **  Updated: January 2024
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

sub DrawStatusBar(screen as object, width as integer, height as integer)
    screen.DrawRect(0, height - (8 * m.scale), width, (8 * m.scale), m.colors.black)
    lifeFull = m.regions.general["kid-live"]
    lifeEmpty = m.regions.general["kid-emptylive"]
    if m.settings.spriteMode = m.const.SPRITES_MAC
        lifePos = 8 * m.scale
    else
        lifePos = 6 * m.scale
    end if
    if m.kid.health = 1
        if m.blink[0]
            screen.drawobject(0, height - lifePos, lifeFull)
        else
            screen.drawobject(0, height - lifePos, lifeEmpty)
        end if
        m.blink[0] = not m.blink[0]
    else if m.kid.health > 1
        for h = 0 to m.kid.health - 1
            screen.drawobject(lifeFull.GetWidth() * h + h, height - lifePos, lifeFull)
        next
    end if
    if m.kid.health < m.kid.maxHealth
        for h = m.kid.health to m.kid.maxHealth - 1
            screen.drawobject(lifeFull.GetWidth() * h + h, height - lifePos, lifeEmpty)
        next
    end if
    enemy = m.kid.opponent
    if enemy <> invalid and enemy.health > 0 and enemy.sprite <> invalid and enemy.charName <> "skeleton"
        if enemy.swordDrawn or (enemy.sprite.GetX() > 0 and enemy.sprite.GetX() < m.gameScreen.GetWidth())
            if enemy.health = 1
                if m.blink[1]
                    guardLife = m.regions.general[enemy.charImage + "-live"]
                    screen.drawobject(width - guardLife.GetWidth(), height - lifePos, guardLife)
                end if
                m.blink[1] = not m.blink[1]
            else
                for h = 1 to enemy.health
                    guardLife = m.regions.general[enemy.charImage + "-live"]
                    screen.drawobject(width - guardLife.GetWidth() * h, height - lifePos, guardLife)
                next
            end if
        end if
    end if
    if m.status.Count() > 0
        text = m.status[0].text
        if m.status[0].duration = 0
            if m.status.count() > 1
                m.status.Delete(0)
            end if
        else if m.status[0].mark = invalid
            m.status[0].mark = m.timer.TotalMilliseconds()
            m.status[0].count = 0
        else
            timeGap = m.timer.TotalMilliseconds() - m.status[0].mark
            if timeGap >= m.status[0].duration * 1000
                m.status.Delete(0)
            else if m.status[0].alert
                if timeGap > m.status[0].count + 500
                    m.status[0].count = m.status[0].count + 500
                    if m.status[0].count mod 1000 = 0
                        PlaySound("status-alert")
                    end if
                end if
                if m.status[0].count mod 1000 <> 0
                    text = ""
                end if
            end if
        end if
        if text <> ""
            x = int(width / 2) - (Len(text) * (7 * m.scale)) / 2
            y = height - (8 * m.scale)
            m.bitmapFont.write(screen, text, x, y, m.scale)
        end if
    end if

    if not m.inSimulator
        if m.kid.swordDrawn or m.kid.cursors.shift
            borderColor = m.colors.white
        else
            borderColor = m.colors.gray
        end if
        borderScale = 1
        if m.settings.zoomMode = 1 and m.scale = 1
            borderScale = 2
        end if
        DrawBorder(m.mainScreen, m.gameWidth * borderScale, m.gameHeight * borderScale, borderColor, 2)
    end if
end sub

sub DrawBorder(screen as object, width as integer, height as integer, color as integer, offset as integer)
    leftX = Cint((screen.GetWidth() - width) / 2) - offset
    rightX = leftX + width + offset * 2
    topY = Cint((screen.GetHeight() - height) / 2) - offset
    bottomY = topY + height + offset * 2
    screen.DrawLine(leftX, topY, rightX, topY, color)
    screen.DrawLine(rightX, topY, rightX, bottomY, color)
    screen.DrawLine(rightX, bottomY, leftX, bottomY, color)
    screen.DrawLine(leftX, bottomY, leftX, topY, color)
end sub

sub DebugInfo(x as integer, y as integer)
    if x <> m.saveX or y <> m.saveY or m.kid.frameName <> m.saveFrameName
        strDebug = str(x) + "," + str(y) + " " + m.kid.action() + " " + m.kid.frameName + " R:" + m.kid.room.toStr() + " T:" + m.kid.blockX.toStr() + "," + m.kid.blockY.toStr()
        'print strDebug
        m.status.Push({ text: strDebug, duration: 0, alert: false })
        m.saveX = x
        m.saveY = y
        m.saveFrameName = m.kid.frameName
    end if
end sub

sub DebugGuard(x as integer, y as integer, guard as object)
    if x <> m.guardX or y <> m.guardY or guard.frameName <> m.guardFrameName
        if guard.room = 22
            strDebug = "guard: " + str(x) + "," + str(y) + " " + guard.action() + " " + guard.frameName + " R:" + guard.room.toStr() + " T:" + guard.blockX.toStr() + "," + guard.blockY.toStr()
            'print strDebug
            m.guardX = x
            m.guardY = y
            m.guardFrameName = guard.frameName
        end if
    end if
end sub

function LoadBitmapFont() as dynamic
    rsp = ReadAsciiFile("pkg:/assets/fonts/prince-fnt.xml")
    xml = CreateObject("roXMLElement")
    if not xml.Parse(rsp)
        print "Can't parse feed"
        return invalid
    else if xml.font = invalid
        print "Missing font tag"
        return invalid
    end if
    xmlChars = xml.getnamedelements("chars").getchildelements()
    bitmap = CreateObject("roBitmap", "pkg:/assets/fonts/prince-fnt.png")
    this = {}
    for each char in xmlChars
        charAttr = char.getAttributes()
        name = "chr" + charAttr["id"]
        x = val(charAttr["x"])
        y = val(charAttr["y"])
        width = val(charAttr["width"])
        height = val(charAttr["height"])
        yoffset = val(charAttr["yoffset"])
        yOff = (height + yoffset - 11)
        letter = CreateObject("roRegion", bitmap, x, y, width, height)
        this.AddReplace(name, { image: letter, yOffset: yOff })
    next
    this.write = write_text
    return this
end function

function write_text(screen as object, text as string, x as integer, y as integer, scale = 1.0 as float) as object
    xOff = 2 * scale
    yOff = 8 * scale
    for c = 0 to len(text) - 1
        ci = asc(text.mid(c, 1))
        'Convert accented characters not supported by the font
        if (ci > 191 and ci < 199) or (ci > 223 and ci < 231) 'A
            ci = 65
        else if ci = 199 or ci = 231 'C
            ci = 67
        else if (ci > 199 and ci < 204) or (ci > 231 and ci < 236) 'E
            ci = 69
        else if (ci > 203 and ci < 208) or (ci > 235 and ci < 240) 'I
            ci = 73
        else if ci = 208 'D
            ci = 68
        else if ci = 209 or ci = 241 'N
            ci = 78
        else if (ci > 209 and ci < 215) or (ci > 241 and ci < 247)'O
            ci = 79
        else if ci = 215 'X
            ci = 88
        else if ci = 216 '0
            ci = 48
        else if (ci > 216 and ci < 221) or (ci > 248 and ci < 253) 'U
            ci = 85
        else if ci = 221 'Y
            ci = 89
        else if ci > 160
            ci = 32
        end if
        'write the letter
        letter = m["chr" + ci.toStr()]
        if letter <> invalid
            yl = y + (yOff - letter.image.GetHeight() * scale)
            screen.drawscaledobject(x, yl + letter.yOffset * scale, scale, scale, letter.image)
            x += (letter.image.GetWidth() * scale + xOff)
        end if
    next
end function
