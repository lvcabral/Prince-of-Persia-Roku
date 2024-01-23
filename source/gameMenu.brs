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
    m.mainScreen.Clear(0)
    m.menuDim = { w: 1024, h: 692 }
    scale = Int(GetScale(m.mainScreen, m.menuDim.w, m.menuDim.h))
    centerX = Cint((m.mainScreen.GetWidth() - (m.menuDim.w * scale)) / 2)
    centerY = Cint((m.mainScreen.GetHeight() - (m.menuDim.h * scale)) / 2)
    noTitle = CreateObject("roBitmap", "pkg:/images/menu_back.jpg")
    backImage = CreateObject("roBitmap", "pkg:/images/start_menu.jpg")
    CrossFade(m.mainScreen, centerX, centerY, noTitle, backImage, 4)
    menuFont = m.fonts.reg.getFont("Prince of Persia Game Font", 32, false, false)
    menuMode = m.fonts.reg.getFont("Prince of Persia Game Font", 28, false, false)
    menuLeft = centerX + 368
    menuTop = centerY + 243
    menuMax = 5
    menuGap = 56
    cameras = m.settings.zoomMode
    button = -1
    selected = 0
    cheatKey = -1
    cheatCnt = 0
    while true
        if button <> selected
            m.mainScreen.Clear(0)
            m.mainScreen.DrawObject(centerX, centerY, backImage)
            faceColors = [m.colors.white, m.colors.white, m.colors.white, m.colors.white, m.colors.white, m.colors.white]
            faceColors[selected] = &hFF0000FF
            m.mainScreen.DrawText("Play Classic PC Game", menuLeft, menuTop, faceColors[0], menuFont)
            m.mainScreen.DrawText("Play Classic Mac Game", menuLeft, menuTop + menuGap, faceColors[1], menuFont)
            m.mainScreen.DrawText("Play Community Mods", menuLeft, menuTop + menuGap * 2, faceColors[2], menuFont)
            if m.inSimulator
                m.mainScreen.DrawText("View Control Info", menuLeft, menuTop + menuGap * 3, faceColors[3], menuFont)
            else
                m.mainScreen.DrawText("Setup Control Mode", menuLeft, menuTop + menuGap * 3, faceColors[3], menuFont)
            end if
            m.mainScreen.DrawText("View High Scores", menuLeft, menuTop + menuGap * 4, faceColors[4], menuFont)
            m.mainScreen.DrawText("View Game Credits", menuLeft, menuTop + menuGap * 5, faceColors[5], menuFont)
            if cameras > 1
                mode = (cameras * cameras).toStr() + " rooms"
            else
                mode = "Original"
            end if
            m.mainScreen.DrawText(Substitute("Zoom: {0}", mode), centerX + 436, centerY + 634, m.colors.white, menuMode)
            m.mainScreen.SwapBuffers()
            button = selected
        end if
        key = wait(0, m.port)
        if key <> invalid
            if type(key) = "roUniversalControlEvent"
                key = key.getInt()
            end if
            if key = m.code.BUTTON_UP_PRESSED or key = m.code.BUTTON_RIGHT_PRESSED
                if button > 0
                    selected = button - 1
                    m.sounds.navSingle.Trigger(50)
                else
                    selected = menuMax
                    m.sounds.roll.Trigger(50)
                end if
            else if key = m.code.BUTTON_DOWN_PRESSED or key = m.code.BUTTON_LEFT_PRESSED
                if button < menuMax
                    selected = button + 1
                    m.sounds.navSingle.Trigger(50)
                else
                    selected = 0
                    m.sounds.roll.Trigger(50)
                end if
            else if key = m.code.BUTTON_INFO_PRESSED
                if cameras < 3
                    cameras++
                else
                    cameras = 1
                end if
                m.sounds.select.Trigger(50)
                button = -1
            else if key = m.code.BUTTON_SELECT_PRESSED
                m.sounds.select.Trigger(50)
                if selected < 2
                    m.settings.spriteMode = selected
                    m.settings.modId = invalid
                    m.settings.zoomMode = cameras
                    SaveSettings(m.settings)
                    return cameras
                else if selected = 2
                    modId = ShowModsMenu(m.port)
                    if modId <> ""
                        m.settings.modId = modId
                        if m.mods[modId].sprites
                            m.settings.spriteMode = val(m.settings.modId)
                        else
                            m.settings.spriteMode = m.const.SPRITES_DOS
                        end if
                        return m.settings.zoomMode
                    end if
                else if selected = 3
                    if m.inSimulator
                        ImageScreen("game_control.jpg")
                    else
                        option = OptionsMenu([{ text: "Vertical Control", image: "control_vertical" }, { text: "Horizontal Control", image: "control_horizontal" }], m.settings.controlMode)
                        if option >= 0 and option <> m.settings.controlMode
                            m.settings.controlMode = option
                            SaveSettings(m.settings)
                        end if
                    end if
                else if selected = 4
                    HighscoresScreen()
                else if selected = 5
                    ImageScreen("game_credits.jpg")
                end if
                button = -1
            end if
            if key = m.code.BUTTON_REWIND_PRESSED
                if cheatCnt = 0 or cheatKey = m.code.BUTTON_FAST_FORWARD_PRESSED
                    cheatKey = m.code.BUTTON_REWIND_PRESSED
                    cheatCnt++
                end if
            else if key = m.code.BUTTON_FAST_FORWARD_PRESSED
                if cheatCnt = 3
                    SecretCheatsScreen()
                    button = -1
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
    scale = Int(GetScale(m.mainScreen, m.menuDim.w, m.menuDim.h))
    centerX = Cint((m.mainScreen.GetWidth() - (m.menuDim.w * scale)) / 2)
    centerY = Cint((m.mainScreen.GetHeight() - (m.menuDim.h * scale)) / 2)
    menuFont = m.fonts.reg.getFont("Prince of Persia Game Font", 34, false, false)
    colorWhite = &hFFFFFFFF
    colorRed = &hFF0000FF
    button = -1
    if default <= 1 then selected = default else selected = 0
    backImage = ScaleBitmap(CreateObject("roBitmap", "pkg:/images/options_menu.jpg"), scale)
    while true
        if button <> selected
            m.mainScreen.Clear(0)
            m.mainScreen.DrawObject(centerX, centerY, backImage)
            if selected = 0
                m.mainScreen.DrawText(options[0].text, centerX + 130, centerY + 103, colorRed, menuFont)
                m.mainScreen.DrawText(options[1].text, centerX + 130, centerY + 165, colorWhite, menuFont)
            else
                m.mainScreen.DrawText(options[0].text, centerX + 130, centerY + 103, colorWhite, menuFont)
                m.mainScreen.DrawText(options[1].text, centerX + 130, centerY + 165, colorRed, menuFont)
            end if
            m.mainScreen.DrawObject(centerX, centerY, ScaleBitmap(CreateObject("roBitmap", "pkg:/images/" + options[selected].image + ".png"), scale))
            m.mainScreen.SwapBuffers()
            button = selected
        end if
        key = wait(0, m.port)
        if key <> invalid
            if type(key) = "roUniversalControlEvent"
                key = key.getInt()
            end if
            if key = m.code.BUTTON_DOWN_PRESSED or key = m.code.BUTTON_LEFT_PRESSED or key = m.code.BUTTON_UP_PRESSED or key = m.code.BUTTON_RIGHT_PRESSED
                m.sounds.navSingle.Trigger(50)
                if button = 1
                    selected = 0
                else
                    selected = 1
                end if
            else if key = m.code.BUTTON_BACK_PRESSED
                m.sounds.navSingle.Trigger(50)
                selected = -1
                exit while
            else if key = m.code.BUTTON_SELECT_PRESSED
                m.sounds.select.Trigger(50)
                exit while
            end if
        end if
    end while
    return selected
end function

sub HighScoresScreen()
    scale = Int(GetScale(m.mainScreen, m.menuDim.w, m.menuDim.h))
    centerX = Cint((m.mainScreen.GetWidth() - (m.menuDim.w * scale)) / 2)
    centerY = Cint((m.mainScreen.GetHeight() - (m.menuDim.h * scale)) / 2)
    backImage = ScaleBitmap(CreateObject("roBitmap", "pkg:/images/highscores_back.jpg"), scale)

    ' Enable code below to test High Scores list
    ' if m.highScores = invalid or m.highScores.count() = 0
    '     m.highScores = [
    '         { name: "Marcelo Cabral", time: 3000 },
    '         { name: "Jordan Mechner", time: 1000 }
    '     ]
    ' end if

    while true
        m.mainScreen.Clear(0)
        m.mainScreen.DrawObject(centerX, centerY, backImage)
        xn = centerX + 72 * 3
        xt = centerX + 217 * 3
        ys = centerY + 85 * 3
        c = 0
        for each score in m.highScores
            m.bitmapFont.write(m.mainScreen, score.name, xn, ys, 3.0)
            m.bitmapFont.write(m.mainScreen, FormatTime(score.time), xt, ys, 3.0)
            ys += (12 * 3)
            c++
            if c = 7 then exit for
        next
        if m.highScores.Count() > 0
            m.bitmapFont.write(m.mainScreen, "[ Press * to reset the High Scores ]", xn - 52, 370, 3.0)
        else
            m.bitmapFont.write(m.mainScreen, "< No High Scores are recorded yet >", xn - 52, ys + 108, 3.0)
        end if
        m.mainScreen.SwapBuffers()
        key = wait(0, m.port)
        if key <> invalid
            if type(key) = "roUniversalControlEvent"
                key = key.getInt()
            end if
            if key = m.code.BUTTON_INFO_PRESSED and m.highScores.Count() > 0
                m.sounds.select.Trigger(50)
                saveOpt = MessageBox(m.mainScreen, 230, 100, "Reset Scores?", 2)
                if saveOpt = m.const.BUTTON_YES
                    m.highScores = []
                    SaveHighScores(m.highScores)
                end if
            else if key < 100
                m.sounds.navSingle.Trigger(50)
                exit while
            end if
        end if
    end while
end sub

sub ImageScreen(imageFile)
    scale = Int(GetScale(m.mainScreen, m.menuDim.w, m.menuDim.h))
    centerX = Cint((m.mainScreen.GetWidth() - (m.menuDim.w * scale)) / 2)
    centerY = Cint((m.mainScreen.GetHeight() - (m.menuDim.h * scale)) / 2)
    m.mainScreen.Clear(0)
    m.mainScreen.DrawObject(centerX, centerY, ScaleBitmap(CreateObject("roBitmap", "pkg:/images/" + imageFile), scale))
    m.mainScreen.SwapBuffers()
    while true
        key = wait(0, m.port)
        if type(key) = "roUniversalControlEvent"
            key = key.getInt()
        end if
        if key <> invalid and key < 100 then exit while
    end while
end sub

function MessageBox(screen as object, width as integer, height as integer, text as string, options = 3 as integer) as integer
    leftX = Cint((screen.GetWidth() - width) / 2)
    topY = Cint((screen.GetHeight() - height) / 2)
    xt = leftX + int(width / 2) - ((Len(text) + 1) * 14) / 2
    xb = leftX + int(width / 2) - (13 * 14) / 2
    yt = topY + height / 2 - 25
    button = -1
    selected = m.const.BUTTON_YES
    while true
        if button <> selected
            screen.DrawRect(leftX, topY, width, height, m.colors.black)
            m.bitmapFont.write(screen, text, xt, yt, 2.0)
            DrawBorder(screen, width, height, m.colors.white, 0)
            boff = [0, 60, 100]
            line = [42, 28, 84]
            m.bitmapFont.write(screen, "Yes", xb + boff[0], yt + 30, 2.0)
            m.bitmapFont.write(screen, "No", xb + boff[1], yt + 30, 2.0)
            if options = 3
                m.bitmapFont.write(screen, "Cancel", xb + boff[2], yt + 30, 2.0)
            end if
            screen.DrawLine(xb + boff[selected], yt + 50, xb + boff[selected] + line[selected], yt + 50, m.colors.white)
            m.mainScreen.SwapBuffers()
            button = selected
        end if
        key = wait(0, m.port)
        if key <> invalid
            if type(key) = "roUniversalControlEvent"
                key = key.getInt()
            end if
            if key = m.code.BUTTON_LEFT_PRESSED or key = m.code.BUTTON_UP_PRESSED
                m.sounds.navSingle.Trigger(50)
                if button > m.const.BUTTON_YES
                    selected = button - 1
                else
                    selected = options - 1
                end if
            else if key = m.code.BUTTON_RIGHT_PRESSED or key = m.code.BUTTON_DOWN_PRESSED
                m.sounds.navSingle.Trigger(50)
                if button < options - 1
                    selected = button + 1
                else
                    selected = m.const.BUTTON_YES
                end if
            else if key = m.code.BUTTON_BACK_PRESSED
                m.sounds.navSingle.Trigger(50)
                return m.const.BUTTON_CANCEL
            else if key = m.code.BUTTON_SELECT_PRESSED
                m.sounds.select.Trigger(50)
                return selected
            end if
        end if
    end while
end function

sub TextBox(screen as object, width as integer, height as integer, text as string, border = false, scale = 2.0)
    leftX = Cint((screen.GetWidth() - width) / 2)
    topY = Cint((screen.GetHeight() - height) / 2)
    xt = leftX + int(width / 2) - (Len(text) * 13) / 2
    yt = topY + height / 2 - 15
    m.mainScreen.SwapBuffers()
    screen.DrawRect(leftX, topY, width, height, m.colors.black)
    m.bitmapFont.write(screen, text, xt, yt, scale)
    if border then DrawBorder(screen, width, height, m.colors.white, 0)
    m.mainScreen.SwapBuffers()
end sub
