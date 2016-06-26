' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: February 2016
' **  Updated: June 2016
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

    const.DO_MOVE = 0
    const.DO_STRIKE = 1
    const.DO_DEFEND = 2
    const.DO_BLOCK = 3
    const.DO_STRIKE_TO_BLOCK = 4
    const.DO_BLOCK_TO_STRIKE = 5

    const.BUTTON_YES = 0
    const.BUTTON_NO = 1
    const.BUTTON_CANCEL = 2

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
    if controlMode = m.const.CONTROL_VERTICAL
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

Function LoadBitmapRegions(scale as float, folder as string, jsonFile as string, pngFile = "" as string, flip = false as boolean, simpleScale = false as boolean) as object
    path = "pkg:/assets/sprites/" + folder + "/"
    if pngFile = ""
        pngFile = jsonFile
    end if
    json = ParseJson(ReadAsciiFile(path + jsonFile + ".json"))
    regions = {}
    if json <> invalid
        if not flip
            bitmap = ScaleBitmap(CreateObject("robitmap", path + pngFile + ".png"), scale, simpleScale)
        else
            bitmap = ScaleBitmap(FlipHorizontally(CreateObject("robitmap", path + pngFile + ".png")), scale, simpleScale)
        end if
        for each name in json.frames
            frame = json.frames.lookup(name).frame
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

Function GenerateFrameNames(prefix as string, start as integer, finish as integer, suffix = "" as string, shuffle = false as boolean, repeatFrame = 1 as integer) as object
    frameNames = []
    if shuffle
        length = finish-start+1
        frame = rnd(length)-1
        for f = 1 to length
            for r = 1 to repeatFrame
                frameNames.Push(prefix + itostr(frame+start) + suffix)
            next
            frame = (frame + 1) mod length
        next
    else
        for f = start to finish
            for r = 1 to repeatFrame
                frameNames.Push(prefix + itostr(f) + suffix)
            next
        next
    end if
    return frameNames
End Function

Function GetPaintedBitmap(color as integer, width as integer, height as integer, alpha as boolean) as object
    bitmap = CreateObject("roBitmap", {width:width, height:height, alphaenable:alpha})
    bitmap.clear(color)
    return bitmap
End Function

Function ScaleBitmap(bitmap as object, scale as float, simpleMode = false as boolean) as object
	if scale = int(scale) or simpleMode
		scaled = CreateObject("roBitmap",{width:int(bitmap.GetWidth()*scale), height:int(bitmap.GetHeight()*scale), alphaenable:bitmap.GetAlphaEnable()})
		scaled.DrawScaledObject(0,0,scale,scale,bitmap)
    else if scale <> 1.0
        region = CreateObject("roRegion", bitmap, 0, 0, bitmap.GetWidth(), bitmap.GetHeight())
        region.SetScaleMode(1)
        scaled = CreateObject("roBitmap",{width:int(bitmap.GetWidth()*scale), height:int(bitmap.GetHeight()*scale), alphaenable:bitmap.GetAlphaEnable()})
        scaled.DrawScaledObject(0,0,scale,scale,region)
    else
		scaled = bitmap
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
    return (di.GetUIResolution().name <> "sd")
End Function

Function IsfHD()
    di = CreateObject("roDeviceInfo")
    return(di.GetUIResolution() = "fhd")
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

Function itostr(i As Integer) As String
    str = Stri(i)
    return strTrim(str)
End Function

Function strTrim(str As String) As String
    st = CreateObject("roString")
    st.SetString(str)
    return st.Trim()
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
    lines = manifest.Tokenize(chr(10))
    aa = {}
    for each line in lines
        entry = line.Tokenize("=")
        aa.AddReplace(entry[0],entry[1].Trim())
    end for
    print aa
    return aa
End Function

Function IsOpenGL() as Boolean
    di = CreateObject("roDeviceInfo")
    model = Val(Left(di.GetModel(),1))
    return (model = 3 or model = 4 or model = 6)
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

'------- Roku Screens Functions ----
Sub MessageDialog(title, text) As Integer
    port = CreateObject("roMessagePort")
    screen = CreateObject("roScreen")
    screen.SetMessagePort(port)
    d = CreateObject("roMessageDialog")
    d.SetTitle(title)
    d.SetText(text)
    d.SetMessagePort(port)
    d.AddButton(1, "Okay")
    d.Show()
    msg = wait(0, port)
End Sub

'------- Registry Functions -------
Function GetRegistryString(key as String, default = "") As String
    sec = CreateObject("roRegistrySection", "PoP")
    if sec.Exists(key)
        return sec.Read(key)
    endif
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
        if obj <> invalid
            return obj.savedGame
        end if
    end if
    return invalid
End Function
