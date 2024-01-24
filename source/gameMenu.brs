' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
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

function StartMenu() as integer
    m.mainScreen.clear(0)
    if IsHD()
        m.menu = { w: 1024, h: 692, s: 1 }
    else
        m.menu = { w: 640, h: 433, s: 640 / 1024 }
    end if
    m.menu.x = Cint((m.mainScreen.getWidth() - m.menu.w) / 2)
    m.menu.y = Cint((m.mainScreen.getHeight() - m.menu.h) / 2)
    if IsHD()
        noTitle = CreateObject("roBitmap", "pkg:/images/menu_back.jpg")
        backImage = CreateObject("roBitmap", "pkg:/images/start_menu.jpg")
    else
        noTitle = ScaleToSize(CreateObject("roBitmap", "pkg:/images/menu_back.jpg"), m.menu.w, m.menu.h)
        backImage = ScaleToSize(CreateObject("roBitmap", "pkg:/images/start_menu.jpg"), m.menu.w, m.menu.h)
    end if
    CrossFade(m.mainScreen, m.menu.x, m.menu.y, noTitle, backImage, 4)
    menuFont = m.fonts.reg.getFont("Prince of Persia Game Font", int(30 * m.menu.s), false, false)
    menuMode = m.fonts.reg.getFont("Prince of Persia Game Font", int(28 * m.menu.s), false, false)
    menuLeft = m.menu.x + Cint(368 * m.menu.s)
    menuTop = m.menu.y + Cint(243 * m.menu.s)
    menuMax = 5
    menuGap = 56 * m.menu.s
    redraw = true
    selected = 0
    cheatKey = -1
    cheatCnt = 0
    menuOptions = [
        "Play Classic PC Game",
        "Play Classic Mac Game",
        "Play Community Mods",
        "Game Zoom: Original",
        "Setup Control Mode",
        "High Scores Board"
    ]
    if m.inSimulator then menuOptions[4] = "Game Control Help"
    while true
        if redraw
            m.mainScreen.clear(0)
            m.mainScreen.drawObject(m.menu.x, m.menu.y, backImage)
            if m.settings.zoomMode > 1
                rooms = m.settings.zoomMode * m.settings.zoomMode
                menuOptions[3] = "Game Zoom: " + rooms.toStr() + " rooms"
            else
                menuOptions[3] = "Game Zoom: Original"
            end if
            for i = 0 to menuOptions.count() - 1
                if selected = i
                    m.mainScreen.drawText(menuOptions[i], menuLeft, menuTop + menuGap * i, m.colors.menuOn, menuFont)
                    m.mainScreen.drawText(menuOptions[i], menuLeft + 1, (menuTop + menuGap * i) + 1, m.colors.menuShadow, menuFont)
                else
                    m.mainScreen.drawText(menuOptions[i], menuLeft, menuTop + menuGap * i, m.colors.menuOff, menuFont)
                end if
            next
            m.mainScreen.drawText("Game Credits", m.menu.x + 442 * m.menu.s, m.menu.y + CInt(633 * m.menu.s), m.colors.white, menuMode)
            m.mainScreen.swapBuffers()
            redraw = false
        end if
        event = Wait(0, m.port)
        if Type(event) = "roUniversalControlEvent"
            key = event.getInt()
            print key
            if key = m.code.BUTTON_UP_PRESSED
                if selected > 0
                    selected--
                    m.sounds.navSingle.trigger(50)
                else
                    selected = menuMax
                    m.sounds.roll.trigger(50)
                end if
                redraw = true
            else if key = m.code.BUTTON_DOWN_PRESSED
                if selected < menuMax
                    selected++
                    m.sounds.navSingle.trigger(50)
                else
                    selected = 0
                    m.sounds.roll.trigger(50)
                end if
                redraw = true
            else if key = m.code.BUTTON_INFO_PRESSED
                m.sounds.select.trigger(50)
                ImageScreen("game_credits.jpg")
                redraw = true
            else if key = m.code.BUTTON_SELECT_PRESSED
                m.sounds.select.trigger(50)
                if selected < 2
                    m.settings.spriteMode = selected
                    m.settings.modId = invalid
                    SaveSettings(m.settings)
                    return m.settings.zoomMode
                else if selected = 2
                    modId = ModsScreen(m.port)
                    if modId <> ""
                        m.settings.modId = modId
                        if m.mods[modId].sprites
                            m.settings.spriteMode = Val(m.settings.modId)
                        else
                            m.settings.spriteMode = m.const.SPRITES_DOS
                        end if
                        SaveSettings(m.settings)
                        return m.settings.zoomMode
                    end if
                else if selected = 3
                    if m.settings.zoomMode < 3
                        m.settings.zoomMode++
                    else
                        m.settings.zoomMode = 1
                    end if
                    SaveSettings(m.settings)
                else if selected = 4
                    if m.inSimulator
                        ImageScreen("game_control.jpg")
                    else
                        option = OptionsMenu([{ text: "Vertical Control", image: "control_vertical" }, { text: "Horizontal Control", image: "control_horizontal" }], m.settings.controlMode)
                        if option >= 0 and option <> m.settings.controlMode
                            m.settings.controlMode = option
                            SaveSettings(m.settings)
                        end if
                    end if
                else if selected = 5
                    HighscoresScreen()
                end if
                redraw = true
            end if
            if key = m.code.BUTTON_REWIND_PRESSED
                if cheatCnt = 0 or cheatKey = m.code.BUTTON_FAST_FORWARD_PRESSED
                    cheatKey = m.code.BUTTON_REWIND_PRESSED
                    cheatCnt++
                end if
            else if key = m.code.BUTTON_FAST_FORWARD_PRESSED
                if cheatCnt = 3
                    SecretCheatsScreen()
                    redraw = true
                else if cheatKey = m.code.BUTTON_REWIND_PRESSED
                    cheatKey = m.code.BUTTON_FAST_FORWARD_PRESSED
                end if
            else if key < 100
                cheatKey = -1
                cheatCnt = 0
            end if
        end if
    end while
end function

function OptionsMenu(options as object, default as integer) as integer
    menuX = m.menu.x + 130 * m.menu.s
    menuY0 = m.menu.y + 103 * m.menu.s
    menuY1 = m.menu.y + 165 * m.menu.s
    menuFont = m.fonts.reg.getFont("Prince of Persia Game Font", 34 * m.menu.s, false, false)
    button = -1
    if default <= 1 then selected = default else selected = 0
    backImage = ScaleBitmap(CreateObject("roBitmap", "pkg:/images/options_menu.jpg"), m.menu.s)
    images = [
        ScaleBitmap(CreateObject("roBitmap", "pkg:/images/" + options[0].image + ".png"), m.menu.s),
        ScaleBitmap(CreateObject("roBitmap", "pkg:/images/" + options[1].image + ".png"), m.menu.s)
    ]
    while true
        if button <> selected
            m.mainScreen.clear(0)
            m.mainScreen.drawObject(m.menu.x, m.menu.y, backImage)
            if selected = 0
                m.mainScreen.drawText(options[0].text, menuX, menuY0, m.colors.menuOn, menuFont)
                m.mainScreen.drawText(options[0].text, menuX + 1, menuY0 + 1, m.colors.menuShadow, menuFont)
                m.mainScreen.drawText(options[1].text, menuX, menuY1, m.colors.menuOff, menuFont)
            else
                m.mainScreen.drawText(options[0].text, menuX, menuY0, m.colors.menuOff, menuFont)
                m.mainScreen.drawText(options[1].text, menuX, menuY1, m.colors.menuOn, menuFont)
                m.mainScreen.drawText(options[1].text, menuX + 1, menuY1 + 1, m.colors.menuShadow, menuFont)
            end if
            m.mainScreen.drawObject(m.menu.x, m.menu.y, images[selected])
            m.mainScreen.swapBuffers()
            button = selected
        end if
        key = wait(0, m.port)
        if key <> invalid
            if type(key) = "roUniversalControlEvent"
                key = key.getInt()
            end if
            if key = m.code.BUTTON_DOWN_PRESSED or key = m.code.BUTTON_LEFT_PRESSED or key = m.code.BUTTON_UP_PRESSED or key = m.code.BUTTON_RIGHT_PRESSED
                m.sounds.navSingle.trigger(50)
                if button = 1
                    selected = 0
                else
                    selected = 1
                end if
            else if key = m.code.BUTTON_BACK_PRESSED
                m.sounds.navSingle.trigger(50)
                selected = -1
                exit while
            else if key = m.code.BUTTON_SELECT_PRESSED
                m.sounds.select.trigger(50)
                exit while
            end if
        end if
    end while
    return selected
end function

sub HighScoresScreen()
    backImage = ScaleBitmap(CreateObject("roBitmap", "pkg:/images/highscores_back.jpg"), m.menu.s)
    fontScale = 3.0 * m.menu.s

    ' Uncomment code below to test High Scores list
    ' if m.highScores = invalid or m.highScores.count() = 0
    '     m.highScores = [
    '         { name: "Jordan", time: 3550 },
    '         { name: "David", time: 3450 },
    '         { name: "Norbert", time: 3350 },
    '         { name: "Marcelo", time: 3230 },
    '         { name: "oitofelix", time: 3100 }
    '     ]
    ' end if

    while true
        m.mainScreen.clear(0)
        m.mainScreen.drawObject(m.menu.x, m.menu.y, backImage)
        xn = m.menu.x + 232 * m.menu.s
        xt = m.menu.x + 686 * m.menu.s
        ys = m.menu.y + 275 * m.menu.s
        c = 0
        for each score in m.highScores
            m.bitmapFont.write(m.mainScreen, score.name, xn, ys, fontScale)
            m.bitmapFont.write(m.mainScreen, FormatTime(score.time), xt, ys, fontScale)
            ys += (12 * 3) * m.menu.s
            c++
            if c = 7 then exit for
        next
        if m.highScores.Count() > 0
            m.bitmapFont.write(m.mainScreen, "[ Press * to reset the High Scores ]", m.menu.x + 157 * m.menu.s, m.menu.y + 560 * m.menu.s, fontScale)
        else
            m.bitmapFont.write(m.mainScreen, "< No High Scores are recorded yet >", m.menu.x + 157 * m.menu.s, ys + 108 * m.menu.s, fontScale)
        end if
        m.mainScreen.swapBuffers()
        key = wait(100, m.port)
        if key <> invalid
            if type(key) = "roUniversalControlEvent"
                key = key.getInt()
            end if
            if key = m.code.BUTTON_INFO_PRESSED and m.highScores.Count() > 0
                m.sounds.select.trigger(50)
                saveOpt = MessageBox(m.mainScreen, 230, 100, "Reset Scores?", 2)
                if saveOpt = m.const.BUTTON_YES
                    m.highScores = []
                    SaveHighScores(m.highScores)
                end if
            else if key = m.code.BUTTON_BACK_PRESSED
                m.sounds.navSingle.trigger(50)
                exit while
            end if
        end if
    end while
end sub

sub ImageScreen(imageFile)
    m.mainScreen.clear(0)
    m.mainScreen.drawObject(m.menu.x, m.menu.y, ScaleBitmap(CreateObject("roBitmap", "pkg:/images/" + imageFile), m.menu.s))
    m.mainScreen.swapBuffers()
    while true
        event = wait(0, m.port)
        if type(event) = "roUniversalControlEvent"
            key = event.getInt()
            if key = m.code.BUTTON_BACK_PRESSED then exit while
        end if
    end while
end sub

function MessageBox(screen as object, width as integer, height as integer, text as string, options = 3 as integer) as integer
    leftX = Cint((screen.getWidth() - width) / 2)
    topY = Cint((screen.getHeight() - height) / 2)
    xt = leftX + int(width / 2) - ((Len(text) + 1) * 14) / 2
    xb = leftX + int(width / 2) - (13 * 14) / 2
    yt = topY + height / 2 - 25
    button = -1
    selected = m.const.BUTTON_YES
    while true
        if button <> selected
            screen.drawRect(leftX, topY, width, height, m.colors.black)
            m.bitmapFont.write(screen, text, xt, yt, 2.0)
            DrawBorder(screen, width, height, m.colors.white, 0)
            boff = [0, 60, 100]
            line = [42, 28, 84]
            m.bitmapFont.write(screen, "Yes", xb + boff[0], yt + 30, 2.0)
            m.bitmapFont.write(screen, "No", xb + boff[1], yt + 30, 2.0)
            if options = 3
                m.bitmapFont.write(screen, "Cancel", xb + boff[2], yt + 30, 2.0)
            end if
            screen.drawLine(xb + boff[selected], yt + 50, xb + boff[selected] + line[selected], yt + 50, m.colors.white)
            m.mainScreen.swapBuffers()
            button = selected
        end if
        key = wait(0, m.port)
        if key <> invalid
            if type(key) = "roUniversalControlEvent"
                key = key.getInt()
            end if
            if key = m.code.BUTTON_LEFT_PRESSED or key = m.code.BUTTON_UP_PRESSED
                m.sounds.navSingle.trigger(50)
                if button > m.const.BUTTON_YES
                    selected = button - 1
                else
                    selected = options - 1
                end if
            else if key = m.code.BUTTON_RIGHT_PRESSED or key = m.code.BUTTON_DOWN_PRESSED
                m.sounds.navSingle.trigger(50)
                if button < options - 1
                    selected = button + 1
                else
                    selected = m.const.BUTTON_YES
                end if
            else if key = m.code.BUTTON_BACK_PRESSED
                m.sounds.navSingle.trigger(50)
                return m.const.BUTTON_CANCEL
            else if key = m.code.BUTTON_SELECT_PRESSED
                m.sounds.select.trigger(50)
                return selected
            end if
        end if
    end while
end function

sub TextBox(screen as object, width as integer, height as integer, text as string, border = false, scale = 2.0)
    leftX = Cint((screen.getWidth() - width) / 2)
    topY = Cint((screen.getHeight() - height) / 2)
    xt = leftX + int(width / 2) - (Len(text) * 13) / 2
    yt = topY + height / 2 - 15
    m.mainScreen.swapBuffers()
    screen.drawRect(leftX, topY, width, height, m.colors.black)
    m.bitmapFont.write(screen, text, xt, yt, scale)
    if border then DrawBorder(screen, width, height, m.colors.white, 0)
    m.mainScreen.swapBuffers()
end sub
