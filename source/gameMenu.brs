' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: April 2016
' **  Updated: December 2023
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

function StartMenu() as integer
    m.mainScreen.Clear(0)
    scale = Int(GetScale(m.mainScreen, 640, 432))
    centerX = Cint((m.mainScreen.GetWidth() - (640 * scale)) / 2)
    centerY = Cint((m.mainScreen.GetHeight() - (432 * scale)) / 2)
    backImage = ScaleBitmap(CreateObject("roBitmap", "pkg:/images/start_menu.jpg"), scale)
    CrossFade(m.mainScreen, centerX, centerY, GetPaintedBitmap(m.colors.black, 640 * scale, 432 * scale, true), backImage, 4)
    menuFont = m.fonts.reg.getFont("Prince of Persia Game Font", 26, false, false)
    button = -1
    selected = 0
    while true
        if button <> selected
            m.mainScreen.Clear(0)
            m.mainScreen.DrawObject(centerX, centerY, backImage)
            faceColors = [m.colors.white, m.colors.white, m.colors.white, m.colors.white]
            faceColors[selected] = &hFF0000FF
            m.mainScreen.DrawText("Play Classic Mode", centerX + 225, centerY + 162, faceColors[0], menuFont)
            m.mainScreen.DrawText("Play 4 Rooms Mode", centerX + 215, centerY + 215, faceColors[1], menuFont)
            m.mainScreen.DrawText("Play 9 Rooms Mode", centerX + 215, centerY + 267, faceColors[2], menuFont)
            m.mainScreen.DrawText("Game Settings", centerX + 240, centerY + 319, faceColors[3], menuFont)
            m.mainScreen.SwapBuffers()
            button = selected
        end if
        key = wait(0, m.port)
        if key <> invalid
            if type(key) = "roUniversalControlEvent"
                key = key.getInt()
            end if
            if key = m.code.BUTTON_UP_PRESSED or key = m.code.BUTTON_RIGHT_PRESSED
                m.sounds.navSingle.Trigger(50)
                if button > 0
                    selected = button - 1
                else
                    selected = 3
                end if
            else if key = m.code.BUTTON_DOWN_PRESSED or key = m.code.BUTTON_LEFT_PRESSED
                m.sounds.navSingle.Trigger(50)
                if button < 3
                    selected = button + 1
                else
                    selected = 0
                end if
            else if key = m.code.BUTTON_SELECT_PRESSED
                m.sounds.select.Trigger(50)
                if button < 3
                    return button + 1
                else
                    SettingsMenu()
                    button = -1
                end if
            end if
        end if
    end while
end function

sub SettingsMenu()
    scale = Int(GetScale(m.mainScreen, 640, 432))
    centerX = Cint((m.mainScreen.GetWidth() - (640 * scale)) / 2)
    centerY = Cint((m.mainScreen.GetHeight() - (432 * scale)) / 2)
    menuFont = m.fonts.reg.getFont("Prince of Persia Game Font", 30, false, false)
    colorWhite = &hFFFFFFFF
    colorRed = &hFF0000FF
    button = -1
    selected = m.settings.controlMode
    backImage = ScaleBitmap(CreateObject("roBitmap", "pkg:/images/settings_menu.jpg"), scale)
    while true
        if button <> selected
            m.mainScreen.Clear(0)
            m.mainScreen.DrawObject(centerX, centerY, backImage)
            faceColors = [m.colors.white, m.colors.white, m.colors.white, m.colors.white, m.colors.white]
            faceColors[selected] = &hFF0000FF
            if m.inSimulator
                m.mainScreen.DrawText("Game Control", centerX + 93, centerY + 108, faceColors[0], menuFont)
            else
                m.mainScreen.DrawText("Control Mode", centerX + 93, centerY + 108, faceColors[0], menuFont)
            end if
            m.mainScreen.DrawText("Graphics Mode", centerX + 93, centerY + 161, faceColors[1], menuFont)
            m.mainScreen.DrawText("Mods & Cheats", centerX + 93, centerY + 213, faceColors[2], menuFont)
            m.mainScreen.DrawText("High Scores", centerX + 93, centerY + 265, faceColors[3], menuFont)
            m.mainScreen.DrawText("Game Credits", centerX + 93, centerY + 318, faceColors[4], menuFont)
            m.mainScreen.SwapBuffers()
            button = selected
        end if
        key = wait(0, m.port)
        if key <> invalid
            if type(key) = "roUniversalControlEvent"
                key = key.getInt()
            end if
            if key = m.code.BUTTON_UP_PRESSED or key = m.code.BUTTON_RIGHT_PRESSED
                m.sounds.navSingle.Trigger(50)
                if button > 0
                    selected = button - 1
                else
                    selected = faceColors.Count() - 1
                end if
            else if key = m.code.BUTTON_DOWN_PRESSED or key = m.code.BUTTON_LEFT_PRESSED
                m.sounds.navSingle.Trigger(50)
                if button < faceColors.Count() - 1
                    selected = button + 1
                else
                    selected = 0
                end if
            else if key = m.code.BUTTON_BACK_PRESSED
                m.sounds.navSingle.Trigger(50)
                exit while
            else if key = m.code.BUTTON_SELECT_PRESSED
                m.sounds.select.Trigger(50)
                if selected = 0
                    if m.inSimulator
                        ImageScreen("game_control.jpg")
                    else
                        option = OptionsMenu([{ text: "Vertical Control", image: "control_vertical" }, { text: "Horizontal Control", image: "control_horizontal" }], m.settings.controlMode)
                        if option >= 0 and option <> m.settings.controlMode
                            m.settings.controlMode = option
                            SaveSettings(m.settings)
                        end if
                    end if
                else if selected = 1
                    option = OptionsMenu([{ text: "IBM-PC MS-DOS", image: "graphics_dos" }, { text: "Macintosh Classic", image: "graphics_mac" }], m.settings.spriteMode)
                    if option >= 0 and option <> m.settings.spriteMode
                        m.settings.spriteMode = option
                        m.settings.modId = invalid
                        SaveSettings(m.settings)
                    end if
                else if selected = 2
                    ModsAndCheatsScreen()
                    ResetMainScreen()
                else if selected = 3
                    HighscoresScreen()
                else if selected = 4
                    ImageScreen("game_credits.jpg")
                end if
                button = -1
            end if
        end if
    end while
end sub

function OptionsMenu(options as object, default as integer) as integer
    scale = Int(GetScale(m.mainScreen, 640, 432))
    centerX = Cint((m.mainScreen.GetWidth() - (640 * scale)) / 2)
    centerY = Cint((m.mainScreen.GetHeight() - (432 * scale)) / 2)
    menuFont = m.fonts.reg.getFont("Prince of Persia Game Font", 26, false, false)
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
                m.mainScreen.DrawText(options[0].text, centerX + 88, centerY + 57, colorRed, menuFont)
                m.mainScreen.DrawText(options[1].text, centerX + 80, centerY + 109, colorWhite, menuFont)
            else
                m.mainScreen.DrawText(options[0].text, centerX + 88, centerY + 57, colorWhite, menuFont)
                m.mainScreen.DrawText(options[1].text, centerX + 80, centerY + 109, colorRed, menuFont)
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
    scale = Int(GetScale(m.mainScreen, 640, 432))
    centerX = Cint((m.mainScreen.GetWidth() - (640 * scale)) / 2)
    centerY = Cint((m.mainScreen.GetHeight() - (432 * scale)) / 2)
    backImage = ScaleBitmap(CreateObject("roBitmap", "pkg:/images/highscores_back.jpg"), scale)
    while true
        m.mainScreen.Clear(0)
        m.mainScreen.DrawObject(centerX, centerY, backImage)
        xn = centerX + 72 * 2
        xt = centerX + 217 * 2
        ys = centerY + 85 * 2
        c = 0
        for each score in m.highScores
            m.bitmapFont.write(m.mainScreen, score.name, xn, ys, 2.0)
            m.bitmapFont.write(m.mainScreen, FormatTime(score.time), xt, ys, 2.0)
            ys += (12 * 2)
            c++
            if c = 7 then exit for
        next
        if m.highScores.Count() > 0
            m.bitmapFont.write(m.mainScreen, "[ Press * to reset the High Scores ]", xn - 52, 370, 2.0)
        else
            m.bitmapFont.write(m.mainScreen, "< No High Scores are recorded yet >", xn - 52, ys + 8, 2.0)
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
    scale = Int(GetScale(m.mainScreen, 640, 432))
    centerX = Cint((m.mainScreen.GetWidth() - (640 * scale)) / 2)
    centerY = Cint((m.mainScreen.GetHeight() - (432 * scale)) / 2)
    m.mainScreen.Clear(0)
    m.mainScreen.DrawObject(centerX, centerY, ScaleBitmap(CreateObject("roBitmap", "pkg:/images/"+ imageFile), scale))
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

sub TextBox(screen as object, width as integer, height as integer, text as string, border = false as boolean)
    leftX = Cint((screen.GetWidth() - width) / 2)
    topY = Cint((screen.GetHeight() - height) / 2)
    xt = leftX + int(width / 2) - (Len(text) * 13) / 2
    yt = topY + height / 2 - 15
    m.mainScreen.SwapBuffers()
    screen.DrawRect(leftX, topY, width, height, m.colors.black)
    m.bitmapFont.write(screen, text, xt, yt, 2.0)
    if border then DrawBorder(screen, width, height, m.colors.white, 0)
    m.mainScreen.SwapBuffers()
end sub
