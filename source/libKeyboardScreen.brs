' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  libKeyboardScreen.brs - Library to implement a Keyboard Screen
' **  Created: October 2019
' **  Updated: October 2019
' **
' **  Copyright (C) Marcelo Lv Cabral < https://lvcabral.com >
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateKeyBoardScreen() as object
    ' Objects
    this = {buttons:[], canvas: CreateCanvas(), focused: {r:0,c:1}}
    this.screen = this.canvas.screen
    this.codes = m.code
    this.sounds = m.sounds
    this.theme = m.theme
    this.fonts = m.fonts
    this.textFont =  m.fonts.reg.GetDefaultFont(25, false, false)
    this.modes = []
    this.currentMode = 0
    this.capsLock = false
    this.shift = false
    ' Properties
    this.title = ""
    this.text = ""
    this.displayText = ""
    this.blinkCursor = false
    this.maxLength = 20
    this.secure = false
    this.focus = -1
    this.visible = false
    ' Methods
    this.SetMessagePort = set_msg_port
    this.SetTitle = set_title
    this.SetText = set_text
    this.SetDisplayText = set_display_text
    this.SetMaxLength = set_max_length
    this.SetSecureText = set_secure_text
    this.GetText = get_text
    this.AddButton = add_button
    ' this.ClearButtons ' Not Implemented
    this.Show = show_keyboard_screen
    this.Wait = wait_keyboard_screen
    this.Close = close_screen
    this.SetModes = set_keyboard_modes

    ' Initialize Canvas
    this.SetModes()
    this.canvas.SetLayer(0, GetOverhang())
    
    return this
End Function

Sub show_keyboard_screen()
    txtArray = []
    imgArray = []
    keybPos = {x: 255, y: 280}
    cursorPos = { x: keybPos.x + 770, y: keybPos.y - 96 }
    txtArray.Push({ Text: m.title
                    TextAttrs: {color: m.theme.BreadcrumbTextLeft, font: "Large", HAlign: "Right"}
                    TargetRect: {x: 578, y: 72, w:650, h:36}})
    imgArray.Push({ url: "pkg:/images/keyboard-field.png"
                    CompositionMode: "Source"
                    TargetRect: {x:keybPos.x, y:keybPos.y-110}})
    imgArray.Push({ url: "pkg:/images/keyboard-back.png"
                    CompositionMode: "Source"
                    TargetRect: {x:keybPos.x, y:keybPos.y}})
    if m.secure then text = String(Len(m.text), "*") else text = m.text
    txtArray.Push({
                Text: text
                TextAttrs: {color: "#A7A7A7FF", font: "Medium", HAlign: "Right", elipsis: true}
                TargetRect: {x:keybPos.x+20, y:keybPos.y-90, w:747, h:36}})
    if m.blinkCursor
        m.canvas.SetLayer(3, { url: "pkg:/images/keyboard-cursor.png", TargetRect: cursorPos })
    else
        m.canvas.ClearLayer(3)
    end if
    m.blinkCursor = not m.blinkCursor
    txtArray.Push({
                Text: m.displayText
                TextAttrs: {color: "#666D70FF", font: "Medium", HAlign: "Right"}
                TargetRect: {x:keybPos.x+15, y:keybPos.y-36, w:770, h:36}})
    ' Setup Keyboard
    m.keys = [[],[],[],[]]
    for c = 0 to 11
        for r = 0 to 3 
            char = m.modes[m.currentMode].Mid(c+12*r,1)
            if c > 0 and c < 11
                if c <= 7
                    xc = c-1
                    x = keybPos.x+199 + (46*xc)
                    y = keybPos.y+21 + (46*r)
                else
                    xc = c-8
                    x = keybPos.x+537 + (46*xc)
                    y = keybPos.y+21 + (46*r)
                end if                
                if char <> m.K_SKIP
                    if c = m.focused.c and r = m.focused.r
                        color = "#0094FFFF"
                        imgArray.Push({ url: "pkg:/images/keyboard-key.png"
                                        CompositionMode: "Source"
                                        TargetRect: {x:x, y:y-7}})
                    else
                        color = "#A7A7A7FF"
                    end if
                    txtArray.Push({
                            Text: char
                            TextAttrs: {color: color, font: m.fonts.KeysFont, HAlign: "Center"}
                            TargetRect: {x:x, y:y, w:42, h:32}})
                else
                    txtArray.Push({ color: "#585858FF"
                                    TargetRect: {x:x, y:y-6, w:42, h:42}})
                end if
            else if c = 0
                x = keybPos.x+13
                y = keybPos.y+14 + (46*r)
                if c = m.focused.c and r = m.focused.r
                    if r = 0
                        img = "pkg:/images/keyboard-caps.png"
                    else
                        img = "pkg:/images/keyboard-long.png"
                    end if
                    color = "#0094FFFF"
                    imgArray.Push({ url: img
                                    CompositionMode: "Source"
                                    TargetRect: {x:x, y:y}})
                else
                    color = "#3C3C3CFF"
                end if
                if r > 0
                    if r = 1
                        caption = "abc123"
                    else if r = 2
                        caption = "&%#?"
                    else if r = 3
                        caption = "åÅñÑ"
                    end if
                    txtArray.Push({
                            Text: caption
                            TextAttrs: {color: color, font: m.fonts.KeysFont, HAlign: "Center"}
                            TargetRect: {x:x + 40, y:y + 6, w:106, h:32}})
                end if
            else if c > 10
                if c = m.focused.c and r = m.focused.r
                    x = keybPos.x+692
                    y = keybPos.y+15 + (46*r)
                    color = "#0094FFFF"
                    if r = 0 
                        img = "pkg:/images/keyboard-shift.png"
                    else if r = 1
                        img = "pkg:/images/keyboard-space.png"
                    else if r = 2
                        img = "pkg:/images/keyboard-clear.png"
                    else if r = 3
                        img = "pkg:/images/keyboard-backspace.png"
                    end if
                    imgArray.Push({ url: img
                                    CompositionMode: "Source"
                                    TargetRect: {x:x, y:y}})
                end if
            end if
            m.keys[r].Push(char)
        next
    next
    ' Setup Left Keys
    if m.capsLock
        imgArray.Push({ url: "pkg:/images/keyboard-check.png"
                    TargetRect: {x:keybPos.x+24, y:keybPos.y+25}})
    end if
    img = "pkg:/images/keyboard-bullet-on.png"
    if m.currentMode < 2
        modePos = {x:keybPos.x+17, y:keybPos.y+66}
        if m.focused.c = 0 and m.focused.r = 1
            img = "pkg:/images/keyboard-bullet-sel-on.png"
        end if
    else if m.currentMode < 4
        modePos = {x:keybPos.x+17, y:keybPos.y+112}
        if m.focused.c = 0 and m.focused.r = 2
            img = "pkg:/images/keyboard-bullet-sel-on.png"
        end if
    else
        modePos = {x:keybPos.x+17, y:keybPos.y+158}
        if m.focused.c = 0 and m.focused.r = 3
            img = "pkg:/images/keyboard-bullet-sel-on.png"
        end if
    end if
    
    imgArray.Push({ url: img
                TargetRect: modePos})

    ' Setup Buttons
    if m.buttons.Count() > 0
        menuPos = {x: 224, y: m.screen.GetHeight() - 70 - (36 * m.buttons.Count())}
        for i = 0 to m.buttons.Count() - 1
            if i = m.focus
                imgArray.Push({ url: "pkg:/images/paragraph-bar.png"
                                TargetRect: {x:menuPos.x , y:menuPos.y}})
                txtColor = m.theme.ListItemHighlightText
                if txtColor = invalid
                    txtColor = "#FFFFFFFF"
                end if
            else
                imgArray.Push({ url: "pkg:/images/paragraph-bullet.png"
                                TargetRect: {x:1016 , y:menuPos.y}})
                txtColor = "#666D70FF"
            end if
            txtArray.Push({
                        Text: m.buttons[i].text
                        TextAttrs: {color: txtColor, font: m.textFont, HAlign: "Right"}
                        TargetRect: {x:menuPos.x + 28, y:menuPos.y + 2, w:750, h:30}})
            menuPos.y = menuPos.y + 36
        next
    end if
    m.canvas.SetLayer(1, imgArray)
    m.canvas.SetLayer(2, txtArray)
    m.canvas.Show()
    m.visible = true
End Sub

Function wait_keyboard_screen(port) as object
    if port = invalid then port = m.canvas.screen.port
    while true
        event = wait(500, port)
        if type(event) = "roUniversalControlEvent" and event.IsPress()
            index = event.GetInt()
            char = event.GetChar()
            if index = m.codes.BUTTON_LEFT_PRESSED and m.focused.r < 4
                cols = m.keys[m.focused.r].Count()-1
                m.focused.c--
                if m.focused.c < 0 then m.focused.c = cols
                key = m.keys[m.focused.r][m.focused.c]
                while key = m.K_SKIP
                    m.focused.c--
                    if m.focused.c < 0 then m.focused.c = cols
                    key = m.keys[m.focused.r][m.focused.c]
                end while
                m.sounds.navSingle.Trigger(50)
            else if index = m.codes.BUTTON_RIGHT_PRESSED and m.focused.r < 4
                cols = m.keys[m.focused.r].Count()-1
                m.focused.c++
                if m.focused.c > cols then m.focused.c = 0
                key = m.keys[m.focused.r][m.focused.c]
                while key = m.K_SKIP
                    m.focused.c++
                    if m.focused.c > cols then m.focused.c = 0
                    key = m.keys[m.focused.r][m.focused.c]
                end while
                m.sounds.navSingle.Trigger(50)
            else if index = m.codes.BUTTON_UP_PRESSED
                m.focused.r--
                if m.focused.r < 0
                    m.focused.r = 3 + m.buttons.Count()
                else if m.focused.r < 4
                    key = m.keys[m.focused.r][m.focused.c]
                    while key = m.K_SKIP
                        m.focused.r--
                        key = m.keys[m.focused.r][m.focused.c]
                    end while
                end if
                m.focus = m.focused.r - 4
                m.sounds.navSingle.Trigger(50)
            else if index = m.codes.BUTTON_DOWN_PRESSED
                m.focused.r++
                if m.focused.r > 3 + m.buttons.Count()
                    m.focused.r = 0
                else if m.focused.r < 4
                    key = m.keys[m.focused.r][m.focused.c]
                    if key = m.K_SKIP then m.focused.r = 4
                end if
                m.focus = m.focused.r - 4
                m.sounds.navSingle.Trigger(50)
            else if index = m.codes.BUTTON_BACK_PRESSED
                m.sounds.navSingle.Trigger(50)
                m.Close()
                msg = GetScreenMessage(m.focus, "closed")
                exit while
            else if index = m.codes.BUTTON_REWIND_PRESSED or index = 11
                if Len(m.text) > 0
                    m.sounds.roll.Trigger(50)
                    m.text = Left(m.text, Len(m.text)-1)
                else
                    m.sounds.deadend.Trigger(50)
                end if                
            else if index = m.codes.BUTTON_SELECT_PRESSED
                if m.focus >= 0
                    m.sounds.select.Trigger(50)
                    msg = GetScreenMessage(m.buttons[m.focus].id, "button")
                    exit while
                else
                    key = m.keys[m.focused.r][m.focused.c]
                    if key = m.K_CAPS ' Caps Lock
                        m.shift = false
                        m.capsLock = not m.capsLock
                        if m.currentMode = 0 and m.capsLock
                            m.currentMode = 1
                        else if m.currentMode = 1 and not m.capsLock
                            m.currentMode = 0
                        else if m.currentMode = 2 and m.capsLock
                            m.currentMode = 3
                        else if m.currentMode = 3 and not m.capsLock
                            m.currentMode = 2
                        else if m.currentMode = 4 and m.capsLock
                            m.currentMode = 5
                        else if m.currentMode = 5 and not m.capsLock
                            m.currentMode = 4
                        end if
                        m.sounds.select.Trigger(50)
                    else if key = m.K_SHFT ' Shift
                        if m.currentMode = 0
                            m.currentMode = 1
                        else if m.currentMode = 2
                            m.currentMode = 3
                        else if m.currentMode = 4
                            m.currentMode = 5
                        end if
                        m.shift = true
                        m.sounds.select.Trigger(50)
                    else if key = m.K_ABC1 ' Letters and Numbers
                        if m.capsLock or m.shift
                            m.currentMode = 1
                        else
                            m.currentMode = 0
                        end if
                        m.sounds.select.Trigger(50)
                    else if key = m.K_SYMB ' Symbols
                        if m.capsLock or m.shift
                            m.currentMode = 3
                        else
                            m.currentMode = 2
                        end if
                        m.sounds.select.Trigger(50)
                    else if key = m.K_ACNT ' Accents
                        if m.capsLock or m.shift
                            m.currentMode = 5
                        else
                            m.currentMode = 4
                        end if
                        m.sounds.select.Trigger(50)
                    else if key = m.K_WIPE ' Clear
                        if Len(m.text) > 0
                            m.sounds.roll.Trigger(50)
                            m.text = ""
                        else
                            m.sounds.deadend.Trigger(50)
                        end if
                    else if key = m.K_BKSP ' Backspace
                        if Len(m.text) > 0
                            m.sounds.roll.Trigger(50)
                            m.text = Left(m.text, Len(m.text)-1)
                        else
                            m.sounds.deadend.Trigger(50)
                        end if
                    else if key >= m.K_SPAC ' Printable character
                        if Len(m.text) < m.maxLength
                            m.sounds.select.Trigger(50)
                            m.text += key
                        else
                            m.sounds.deadend.Trigger(50)
                        end if
                        if m.shift and not m.capsLock
                            if m.currentMode = 1
                                m.currentMode = 0
                            else if m.currentMode = 3
                                m.currentMode = 2
                            else if m.currentMode = 5
                                m.currentMode = 4
                            end if                            
                        end if
                        m.shift = false
                    end if
                end if
            else if char >= 32 and char <= 126 ' Basic printable ASCII characters
                m.sounds.select.Trigger(50)
                m.text += Chr(char)
            else if char >= 128 and char <= 255 ' Extended printable ASCII characters
                m.sounds.select.Trigger(50)
                m.text += Chr(char)
            end if
        end if
        m.Show()
    end while
    return msg
End Function

Sub set_keyboard_modes()
    'Constants
    m.K_CAPS = Chr(14)
    m.K_SHFT = Chr(15)
    m.K_ABC1 = Chr(1)
    m.K_SYMB = Chr(2)
    m.K_ACNT = Chr(3)
    m.K_SPAC = Chr(32)
    m.K_WIPE = Chr(4)
    m.K_SKIP = Chr(9)
    m.K_BKSP = Chr(127)
    m.K_DBQT = Chr(34)
    ' Keyboard Modes
    lowerCase =  m.K_CAPS + "abcdefg123" + m.K_SHFT
    lowerCase += m.K_ABC1 + "hijklmn456" + m.K_SPAC
    lowerCase += m.K_SYMB + "opqrstu789" + m.K_WIPE
    lowerCase += m.K_ACNT + "vwxyz-_@0." + m.K_BKSP
    m.modes.Push(lowerCase)
    upperCase =  m.K_CAPS + "ABCDEFG123" + m.K_SHFT
    upperCase += m.K_ABC1 + "HIJKLMN456" + m.K_SPAC
    upperCase += m.K_SYMB + "OPQRSTU789" + m.K_WIPE
    upperCase += m.K_ACNT + "VWXYZ-_@0." + m.K_BKSP
    m.modes.Push(upperCase)
    lowerSymb =  m.K_CAPS + "!?*#$%^´ˆ˜" + m.K_SHFT
    lowerSymb += m.K_ABC1 + "&,:;`'" + m.K_DBQT + "¨¯¸ "
    lowerSymb += m.K_SYMB + "(){}[]~=+×" + m.K_WIPE
    lowerSymb += m.K_ACNT + "¡¿<>|\/÷±‰" + m.K_BKSP
    m.modes.Push(lowerSymb)
    upperSymb =  m.K_CAPS + "•·¢£¤¥€¼½¾" + m.K_SHFT
    upperSymb += m.K_ABC1 + "®©™«»‹›“”„" + m.K_SPAC
    upperSymb += m.K_SYMB + "¦†‡§ƒµ¶‘’‚" + m.K_WIPE
    upperSymb += m.K_ACNT + "¹²³º°ª…–—" + m.K_SKIP + m.K_BKSP
    m.modes.Push(upperSymb)
    lowerAcnt =  m.K_CAPS + "àáâãäåæýÿš" + m.K_SHFT
    lowerAcnt += m.K_ABC1 + "èéêëìíîžðþ" + m.K_SPAC
    lowerAcnt += m.K_SYMB + "ïòóôõöøß" + m.K_SKIP + m.K_SKIP + m.K_WIPE
    lowerAcnt += m.K_ACNT + "œùúûüçñ" + m.K_SKIP + m.K_SKIP + m.K_SKIP + m.K_BKSP
    m.modes.Push(lowerAcnt)
    upperAcnt =  m.K_CAPS + "ÀÁÂÃÄÅÆÝŸŠ" + m.K_SHFT
    upperAcnt += m.K_ABC1 + "ÈÉÊËÌÍÎŽÐÞ" + m.K_SPAC
    upperAcnt += m.K_SYMB + "ÏÒÓÔÕÖØ" + m.K_SKIP + m.K_SKIP + m.K_SKIP + m.K_WIPE
    upperAcnt += m.K_ACNT + "ŒÙÚÛÜÇÑ" + m.K_SKIP + m.K_SKIP + m.K_SKIP + m.K_BKSP
    m.modes.Push(upperAcnt)
End Sub

Sub set_display_text(text as string)
    m.displayText = text
End Sub

Sub set_max_length(length as integer)
    m.maxLength = length
End Sub

Sub set_secure_text(secure as boolean)
    m.secure = secure
End Sub