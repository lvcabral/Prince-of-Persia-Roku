' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: February 2016
' **  Updated: November 2019
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function GetConstants() as object
    const = {}

    const.TIME_LIMIT = 3600

    const.SPRITES_DOS = 0
    const.SPRITES_MAC = 1

    const.CONTROL_VERTICAL = 0
    const.CONTROL_HORIZONTAL = 1

    const.FACE_LEFT = 0
    const.FACE_RIGHT = 1

    const.BLOCK_WIDTH = 32
    const.BLOCK_HEIGHT = 63

    const.TILE_WIDTH = 60
    const.TILE_HEIGHT = 79

    const.ROOM_WIDTH = 320
    const.ROOM_HEIGHT = const.BLOCK_HEIGHT * 3

    const.CMD_FRAME = 0
    const.CMD_NEXTLEVEL = 241
    const.CMD_TAP = 242
    const.CMD_EFFECT = 243
    const.CMD_JARD = 244
    const.CMD_JARU = 245
    const.CMD_DIE = 246
    const.CMD_IFWTLESS = 247
    const.CMD_SETFALL = 248
    const.CMD_ACT = 249
    const.CMD_CHY = 250
    const.CMD_CHX = 251
    const.CMD_DOWN = 252
    const.CMD_UP = 253
    const.CMD_ABOUTFACE = 254
    const.CMD_GOTO = 255

    const.TYPE_DUNGEON = 0
    const.TYPE_PALACE = 1

    const.START_HEALTH = 3
    const.LIMIT_HEALTH = 10

    const.GRAVITY_NORMAL = 3
    const.GRAVITY_WEIGHTLESS = 1
    const.TOP_SPEED_NORMAL = 33
    const.TOP_SPEED_WEIGHTLESS = 4

    const.TILE_SPACE = 0
    const.TILE_FLOOR = 1
    const.TILE_SPIKES = 2
    const.TILE_PILLAR = 3
    const.TILE_GATE = 4
    const.TILE_STUCK_BUTTON = 5
    const.TILE_DROP_BUTTON = 6
    const.TILE_TAPESTRY = 7
    const.TILE_BOTTOM_BIG_PILLAR = 8
    const.TILE_TOP_BIG_PILLAR = 9
    const.TILE_POTION = 10
    const.TILE_LOOSE_BOARD = 11
    const.TILE_TAPESTRY_TOP = 12
    const.TILE_MIRROR = 13
    const.TILE_DEBRIS = 14
    const.TILE_RAISE_BUTTON = 15
    const.TILE_EXIT_LEFT = 16
    const.TILE_EXIT_RIGHT = 17
    const.TILE_SLICER = 18
    const.TILE_TORCH = 19
    const.TILE_WALL = 20
    const.TILE_SKELETON = 21
    const.TILE_SWORD = 22
    const.TILE_BALCONY_LEFT = 23
    const.TILE_BALCONY_RIGHT = 24
    const.TILE_LATTICE_PILLAR = 25
    const.TILE_LATTICE_SUPPORT = 26
    const.TILE_SMALL_LATTICE = 27
    const.TILE_LATTICE_LEFT = 28
    const.TILE_LATTICE_RIGHT = 29
    const.TILE_TORCH_WITH_DEBRIS = 30
    const.TILE_NULL = 31

    const.POTION_EMPTY = 0
    const.POTION_HEALTH = 1
    const.POTION_LIFE = 2
    const.POTION_WEIGHTLESS = 3
    const.POTION_INVERT = 4
    const.POTION_POISON = 5
    const.POTION_OPEN = 6

    const.FIGHT_ATTACK = 0
    const.FIGHT_ALERT  = 1
    const.FIGHT_FROZEN = 2

    const.CHEAT_LEVEL  = 0
    const.CHEAT_HEALTH = 1
    const.CHEAT_TIME   = 2
    const.CHEAT_NONE   = 3

    const.INFO_TIME  = 0
    const.INFO_DEBUG = 1

    const.DO_MOVE = 0
    const.DO_STRIKE = 1
    const.DO_DEFEND = 2
    const.DO_BLOCK = 3
    const.DO_STRIKE_TO_BLOCK = 4
    const.DO_BLOCK_TO_STRIKE = 5

    const.BUTTON_YES = 0
    const.BUTTON_NO = 1
    const.BUTTON_CANCEL = 2

    const.SPECIAL_CONTINUE = 0
    const.SPECIAL_RESET = 1
    const.SPECIAL_FINISH = 2

    return const
End Function

Function GetCursors(controlMode as integer) as object
    this = {
            code: bslUniversalControlEventCodes()
            up: false
            down: false
            left: false
            right: false
            shift: false
           }
    if m.inSimulator
        this.update = update_cursor_simulator
    else if controlMode = m.const.CONTROL_VERTICAL
        this.update = update_cursor_vertical
    else
        this.update = update_cursor_horizontal
    end if
    return this
End Function

Sub update_cursor_vertical(id as integer, shiftToggle as boolean)
    if id = m.code.BUTTON_UP_PRESSED or id = m.code.BUTTON_A_PRESSED
        m.up = true
    else if id = m.code.BUTTON_DOWN_PRESSED
        m.down = true
    else if id = m.code.BUTTON_LEFT_PRESSED
        m.left = true
    else if id = m.code.BUTTON_RIGHT_PRESSED
        m.right = true
    else if id = m.code.BUTTON_B_PRESSED or id = m.code.BUTTON_INFO_PRESSED
        if shiftToggle
            m.shift = true
        else
            m.shift = not m.shift
        end if
    else if id = m.code.BUTTON_UP_RELEASED or id = m.code.BUTTON_A_RELEASED
        m.up = false
    else if id = m.code.BUTTON_DOWN_RELEASED
        m.down = false
    else if id = m.code.BUTTON_LEFT_RELEASED
        m.left = false
    else if id = m.code.BUTTON_RIGHT_RELEASED
        m.right = false
    else if id = m.code.BUTTON_B_RELEASED or id = m.code.BUTTON_INFO_RELEASED
        if shiftToggle
            m.shift = false
        end if
    end if
End Sub

Sub update_cursor_horizontal(id as integer, shiftToggle as boolean)
    if id = m.code.BUTTON_RIGHT_PRESSED or id = m.code.BUTTON_A_PRESSED
        m.up = true
    else if id = m.code.BUTTON_LEFT_PRESSED
        m.down = true
    else if id = m.code.BUTTON_UP_PRESSED
        m.left = true
    else if id = m.code.BUTTON_DOWN_PRESSED
        m.right = true
    else if id = m.code.BUTTON_B_PRESSED or id = m.code.BUTTON_INFO_PRESSED
        if shiftToggle
            m.shift = true
        else
            m.shift = not m.shift
        end if
    else if id = m.code.BUTTON_RIGHT_RELEASED or id = m.code.BUTTON_A_RELEASED
        m.up = false
    else if id = m.code.BUTTON_LEFT_RELEASED
        m.down = false
    else if id = m.code.BUTTON_UP_RELEASED
        m.left = false
    else if id = m.code.BUTTON_DOWN_RELEASED
        m.right = false
    else if id = m.code.BUTTON_B_RELEASED or id = m.code.BUTTON_INFO_RELEASED
        if shiftToggle
            m.shift = false
        end if
    end if
End Sub

Sub update_cursor_simulator(id as integer, shiftToggle as boolean)
    if id = m.code.BUTTON_UP_PRESSED or id = m.code.BUTTON_SELECT_PRESSED
        m.up = true
    else if id = m.code.BUTTON_DOWN_PRESSED
        m.down = true
    else if id = m.code.BUTTON_LEFT_PRESSED
        m.left = true
    else if id = m.code.BUTTON_RIGHT_PRESSED
        m.right = true
    else if id = m.code.BUTTON_REWIND_PRESSED or id = m.code.BUTTON_PLAY_PRESSED
        if shiftToggle
            m.shift = true
        else
            m.shift = not m.shift
        end if
    else if id = m.code.BUTTON_UP_RELEASED or id = m.code.BUTTON_SELECT_RELEASED
        m.up = false
    else if id = m.code.BUTTON_DOWN_RELEASED
        m.down = false
    else if id = m.code.BUTTON_LEFT_RELEASED
        m.left = false
    else if id = m.code.BUTTON_RIGHT_RELEASED
        m.right = false
    else if id = m.code.BUTTON_REWIND_RELEASED or id = m.code.BUTTON_PLAY_RELEASED
        if shiftToggle
            m.shift = false
        end if
    end if
End Sub

Function CommandRestart(id)
    if m.inSimulator
        return id = m.code.BUTTON_INSTANT_REPLAY_PRESSED
    end if
    return id = m.code.BUTTON_INSTANT_REPLAY_PRESSED or id = m.code.BUTTON_PLAY_PRESSED
End Function

Function CommandCheatNext(id)
    if m.inSimulator
        return id = m.code.BUTTON_B_PRESSED
    end if
    return id = m.code.BUTTON_FAST_FORWARD_PRESSED
End Function

Function CommandCheatPrev(id)
    if m.inSimulator
        return id = m.code.BUTTON_A_PRESSED
    end if
    return id = m.code.BUTTON_REWIND_PRESSED
End Function

Function CommandSpaceBar(id)
    if m.inSimulator
        return id = m.code.BUTTON_FAST_FORWARD_PRESSED or id = m.code.BUTTON_INFO_PRESSED
    end if
    return id = m.code.BUTTON_SELECT_PRESSED
End Function

Function key_u() as boolean
    return m.cursors.up
End Function

Function key_d() as boolean
    return m.cursors.down
End Function

Function key_l() as boolean
    return m.cursors.left
End Function

Function key_r() as boolean
    return m.cursors.right
End Function

Function key_s() as boolean
    return m.cursors.shift
End Function

Function LoadBitmapRegions(scale as float, path as string, jsonFile as string, pngFile = "" as string, flip = false as boolean, simpleScale = false as boolean)
    if pngFile = ""
        pngFile = jsonFile
    end if
    print "loading ";path + jsonFile + ".json"
    json = ParseJson(ReadAsciiFile(path + jsonFile + ".json"))
    regions = {}
    if json <> invalid
        if not flip
            bitmap = ScaleBitmap(CreateObject("roBitmap", path + pngFile + ".png"), scale, simpleScale)
        else
            bitmap = ScaleBitmap(FlipHorizontally(CreateObject("roBitmap", path + pngFile + ".png")), scale, simpleScale)
        end if
        for each name in json.frames
            frame = json.frames[name].frame
            if not flip
                regions.AddReplace(name, CreateObject("roRegion", bitmap, int(frame.x * scale), int(frame.y * scale), int(frame.w * scale), int(frame.h * scale)))
            else
                x = bitmap.GetWidth() - int(frame.w * scale) - int(frame.x * scale)
                regions.AddReplace(name, CreateObject("roRegion", bitmap, x, int(frame.y * scale), int(frame.w * scale), int(frame.h * scale)))
            end if
        next
    end if
    return regions
End Function

Function GenerateFrameNames(prefix as string, start as integer, finish as integer, suffix = "" as string, shuffle = false as boolean, repeatFrame = 1 as integer)
    frameNames = []
    if shuffle
        length = finish-start+1
        frame = rnd(length)-1
        for f = 1 to length
            for r = 1 to repeatFrame
                frameNames.Push(prefix + (frame+start).toStr() + suffix)
            next
            frame = (frame + 1) mod length
        next
    else
        for f = start to finish
            for r = 1 to repeatFrame
                frameNames.Push(prefix + f.toStr() + suffix)
            next
        next
    end if
    return frameNames
End Function

Function GetPaintedBitmap(color as integer, width as integer, height as integer, alpha as boolean)
    bitmap = CreateObject("roBitmap", {width:width, height:height, alphaenable:alpha})
    bitmap.clear(color)
    return bitmap
End Function

Function ScaleBitmap(bitmap as object, scale as float, simpleMode = false as boolean)
    if bitmap = invalid then return bitmap
    if scale = 1.0
        scaled = bitmap
    else if scale = int(scale) or simpleMode
		scaled = CreateObject("roBitmap",{width:int(bitmap.GetWidth()*scale), height:int(bitmap.GetHeight()*scale), alphaenable:true})
		scaled.DrawScaledObject(0,0,scale,scale,bitmap)
    else
        region = CreateObject("roRegion", bitmap, 0, 0, bitmap.GetWidth(), bitmap.GetHeight())
        region.SetScaleMode(1)
        scaled = CreateObject("roBitmap",{width:int(bitmap.GetWidth()*scale), height:int(bitmap.GetHeight()*scale), alphaenable:true})
        scaled.DrawScaledObject(0,0,scale,scale,region)
	end if
    return scaled
End Function

Function ScaleToSize(bitmap as object, width as integer, height as integer, ratio = true as boolean)
    if bitmap = invalid then return bitmap
    if ratio and bitmap.GetWidth() <= width and bitmap.GetHeight() <= height
        scaled = bitmap
    else
        region = CreateObject("roRegion", bitmap, 0, 0, bitmap.GetWidth(), bitmap.GetHeight())
        region.SetScaleMode(1)
        if ratio
            if bitmap.GetWidth() > bitmap.GetHeight()
                scale = width / bitmap.GetWidth()
            else
                scale = height / bitmap.GetHeight()
            end if
            scaled = CreateObject("roBitmap",{width:int(bitmap.GetWidth()*scale), height:int(bitmap.GetHeight()*scale), alphaenable:bitmap.GetAlphaEnable()})
            scaled.DrawScaledObject(0,0,scale,scale,region)
        else
            scaleX = width / bitmap.GetWidth()
            scaleY = height / bitmap.GetHeight()
            scaled = CreateObject("roBitmap",{width:width, height:height, alphaenable:bitmap.GetAlphaEnable()})
            scaled.DrawScaledObject(0,0,scaleX,scaleY,region)
        end if
	end if
    return scaled
End Function

Function FlipVertically(bitmap as object) as object
	flipped = CreateObject("roBitmap",{width:bitmap.GetWidth(), height:bitmap.GetHeight(), alphaenable:bitmap.GetAlphaEnable()})
    columns = bitmap.GetWidth()
    lines = bitmap.GetHeight()
    for l = 0 to columns - 1
        region = CreateObject("roRegion", bitmap, 0, l, columns, 1)
        flipped.DrawObject(0, lines - l - 1, region)
    end for
    return flipped
End Function

Function FlipHorizontally(bitmap as object) as object
	flipped = CreateObject("roBitmap",{width:bitmap.GetWidth(), height:bitmap.GetHeight(), alphaenable:bitmap.GetAlphaEnable()})
    columns = bitmap.GetWidth()
    height = bitmap.GetHeight()
    for c = 0 to columns - 1
        region = CreateObject("roRegion", bitmap, c, 0, 1, height)
        flipped.DrawObject(columns - c - 1, 0, region)
    end for
    return flipped
End Function

Sub CrossFade(screen as object, x as integer, y as integer, objectfadeout as object, objectfadein as object, speed = 1 as integer)
    screen.SetAlphaEnable(true)
    for i = 0 to 255 step speed
        hexcolor = &hFFFFFFFF - i
        hexcolor2  = &hFFFFFF00 + i
        screen.Clear(0)
        screen.DrawObject(x, y, objectfadeout, hexcolor)
        screen.DrawObject(x, y, objectfadein, hexcolor2)
        screen.SwapBuffers()
    end for
End Sub

Function GetScale(screen as object, width as integer, height as integer) as float
    scaleX = screen.GetWidth() / width
    scaleY = screen.GetHeight() / height
    if  scaleX > scaleY
        scale = scaleY
    else
        scale = scaleX
    end if
    return scale
End Function

Function IsHD()
    di = CreateObject("roDeviceInfo")
    return (di.GetUIResolution().height >= 720)
End Function

Function IsfHD()
    di = CreateObject("roDeviceInfo")
    return(di.GetUIResolution().name.lcase() = "fhd")
End Function

Function ConvertX(x)
    return Cint(x * 320 / 140)
End Function

Function ConvertXtoBlockX( x )
    return Int( ( x - 7 ) / 14 )
End Function

Function ConvertYtoBlockY( y )
    return Int( y / m.const.BLOCK_HEIGHT )
End Function

Function ConvertBlockXtoX( blockX )
    return blockX * 14 + 7
End Function

Function ConvertBlockYtoY( blockY )
    return ( blockY + 1 ) * m.const.BLOCK_HEIGHT - 10
End Function

Function BoolToInt(value as Boolean) as Integer
    if value
       return 1
    else
       return 0
    end if
End Function

Function GetManifestArray() as Object
    manifest = ReadAsciiFile("pkg:/manifest")
    lines = manifest.Split(chr(10))
    aa = {}
    for each line in lines
        if line <> ""
            entry = line.Split("=")
            aa.AddReplace(entry[0],entry[1].Trim())
        end if
    end for
    print aa
    return aa
End Function

Function IsOpenGL() as Boolean
    di = CreateObject("roDeviceInfo")
    gp = di.GetGraphicsPlatform()
    return (lcase(gp)="opengl")
End Function

Function InSimulator() as Boolean
    di = CreateObject("roDeviceInfo")
    return di.hasFeature("simulation_engine")
End Function


'Nullable Boolean
Function NBool(value as dynamic, default = false as boolean) as boolean
    if value <> invalid
        return value
    else
        return default
    end if
End Function

'Nullable Integer
Function NInt(value as dynamic, default = 0 as integer) as integer
    if value <> invalid
        return value
    else
        return default
    end if
End Function

Function RandomArray(min as integer, max as integer) as object
    list = []
    for i = min to max
        list.Push(i)
    next
    return ShuffleArray(list)
End Function

Function ShuffleArray(argArray as object) as object
    rndArray = []
    for i = 0 to argArray.Count() - 1
        intIndex = Rnd(argArray.Count())
        rndArray.Push(argArray[intIndex - 1])
        argArray.Delete(intIndex - 1)
    next
    Return rndArray
End Function

Function ZeroPad(text as string, length = invalid) as string
    if length = invalid then length = 2
    if text.Len() < length
        for i = 1 to length-text.Len()
            text = "0" + text
        next
    end if
    return text
End Function

Function FormatTime(seconds as integer) as string
    textTime = ""
    hasHours = false
    ' Special Check For Zero
    if seconds < 60
        return "0:" + ZeroPad(seconds.toStr())
    end if
    ' Hours
    if seconds >= 3600
        textTime = textTime + int(seconds / 3600).toStr() + ":"
        hasHours = true
        seconds = seconds Mod 3600
    end if
    ' Minutes
    if seconds >= 60
        if hasHours
            textTime = textTime + ZeroPad(int(seconds / 60).toStr()) + ":"
        else
            textTime = textTime + int(seconds / 60).toStr() + ":"
        end if
        seconds = seconds Mod 60
    else
        if hasHours
            textTime = textTime + "00:"
        end if
    end if
    ' Seconds
    textTime = textTime + ZeroPad(seconds.toStr())
    return textTime
End Function

Function LoadPalette(file as string, limit = -1 as integer, ignore = -1 as integer) As Dynamic
    rsp = ReadAsciiFile(file)
    palette = []
    if left(rsp, 8) <> "JASC-PAL"
        print "Invalid Palette file!"
        return palette
    end if
    rsp = rsp.Mid(rsp.InStr("16") + 3)
    rsp = rsp.Replace(Chr(13)+Chr(10), " ")
    rsp = rsp.Replace(Chr(10), " ")
    obj = rsp.Split(" ")
    r = -1
    g = -1
    b = -1
    color = 1
    for i = 3 to 47
        if palette.Count() = limit then exit for
        if r < 0
            r = Val(obj[i])
        else if g < 0
            g = Val(obj[i])
        else if b < 0
            b = Val(obj[i])
            if color <> ignore
                palette.Push(RGBA(r,g,b))
            end if
            r = -1
            g = -1
            b = -1
            color++
        end if
    next
    return palette
End Function

Function RGBA(r as integer, g as integer, b as integer, a = &HFF as integer)
    return ((r << 24) + (g << 16) + (b << 8) + a)
End Function

'------- Download Functions --------
Function CacheFile(url as string, file as string, overwrite = false as boolean) as string
    tmpFile = "tmp:/" + file
    if overwrite or not m.files.Exists(tmpFile)
        http = CreateObject("roUrlTransfer")
        http.SetCertificatesFile("common:/certs/ca-bundle.crt")
        http.AddHeader("Content-Type", "application/json")
        http.EnableEncodings(true)
        http.SetUrl(url)
        ret = http.GetToFile(tmpFile)
        if ret = 200
            print "CacheFile: "; url; " to "; tmpFile
        else
            print "File not cached! http return code: "; ret
            tmpFile = ""
        end if
    end if
    return tmpFile
End Function

'------- Random Functions -------
Function CreatePseudoRandom()
    return {seed: 0, get: get_prandom, seq: seq_prandom}
End Function

Function get_prandom(max as integer) as integer
    m.seed = m.seed * 214013 + 2531011
    return ((m.seed >> 16) mod (max + 1))
End Function

Function seq_prandom(seed as integer, n as integer, p as integer, max as integer) as integer
    r0 = -1
    r1 = -1
	m.seed = seed
    m.get(1)
    for i = 0 to n
        if i mod p = 0 then r0 = -1
        while true
            r1 = m.get(max)
            if r1 <> r0 then exit while
        end while
        r0 = r1
    next
    return r1
End Function

Function MessageDialog(port, title, text, buttons = ["OK"], default = 0, overlay = false) As Integer
    if port = invalid
        if m.port = invalid
            port = CreateObject("roMessagePort")
        else
            port = m.port
        end if
    end if
    s = CreateMessageDialog()
    s.SetTitle(title)
    s.SetText(text)
    s.SetMessagePort(port)
    s.EnableOverlay(overlay)
    for b = 0 to buttons.Count()-1
        s.AddButton(b, buttons[b])
    next
    s.SetFocusedMenuItem(default)
    s.Show()
    result = 99 'nothing pressed
    while true
        msg = s.wait(port)
        if msg.isButtonPressed()
            result = msg.GetIndex()
            exit while
        else if msg.isScreenClosed()
            exit while
        end if
    end while
    return result
End Function

Function KeyboardScreen(title = "", prompt = "", text = "", button1 = "Okay", button2= "Cancel", secure = false, port = invalid) as string
    m.mainScreen = CreateObject("roScreen", true, 1280, 720)
    m.mainScreen.SetMessagePort(m.port)
    m.mainScreen.SetAlphaEnable(true)
    if port = invalid then port = CreateObject("roMessagePort")
    result = ""
    screen = CreateKeyBoardScreen()
    screen.SetMessagePort(port)
    screen.SetTitle(title)
    screen.SetDisplayText(prompt)
    screen.SetText(text)
    screen.AddButton(1, button1)
    screen.AddButton(2, button2)
    screen.SetSecureText(secure)
    screen.Show()
    while true
        msg = screen.wait(port)
        if msg.isScreenClosed()
            exit while
        else if msg.isButtonPressed()
            if msg.GetIndex() = 1 and screen.GetText().Trim() <> "" 'Ok
                result = screen.GetText()
                exit while
            else if msg.GetIndex() = 2 'Cancel
                result = ""
                exit while
            end if
        end if
    end while
    screen.Close()
    ResetMainScreen()
    return result
End Function

Sub ResetMainScreen()
    if isHD()
        m.mainScreen = CreateObject("roScreen", true, 768, 432)
    else
        m.mainScreen = CreateObject("roScreen", true, 720, 540)
    end if
    m.mainScreen.SetMessagePort(m.port)
    m.mainScreen.SetAlphaEnable(true)
End Sub

'------- Registry Functions -------
Function GetRegistryString(key as String, default = "") As String
    sec = CreateObject("roRegistrySection", "PoP")
    if sec.Exists(key)
        return sec.Read(key)
    end if
    return default
End Function

Sub SaveRegistryString(key As String, value As String)
    sec = CreateObject("roRegistrySection", "PoP")
    sec.Write(key, value)
    sec.Flush()
End Sub

Sub SaveSettings(settings as Object)
    SaveRegistryString("Settings", FormatJSON({settings: settings}, 1))
End Sub

Function LoadSettings() as Dynamic
    json = GetRegistryString("Settings")
    if json <> ""
        obj = ParseJSON(json)
        if obj <> invalid
            return obj.settings
        end if
    end if
    return invalid
End Function

Sub SaveGame(game as Object)
    SaveRegistryString("SavedGame", FormatJSON({savedGame: game}, 1))
End Sub

Function LoadSavedGame() as Dynamic
    json = GetRegistryString("SavedGame")
    if json <> ""
        obj = ParseJSON(json)
        if obj <> invalid and obj.savedGame <> invalid
            return obj.savedGame
        end if
    end if
    return invalid
End Function

Sub SaveHighScores(scores as Object)
    SaveRegistryString("HighScores", FormatJSON({highScores: scores}, 1))
End Sub

Function LoadHighScores() as Dynamic
    json = GetRegistryString("HighScores")
    if json <> ""
        obj = ParseJSON(json)
        if obj <> invalid and obj.highScores <> invalid
            return obj.highScores
        end if
    end if
    return invalid
End Function
