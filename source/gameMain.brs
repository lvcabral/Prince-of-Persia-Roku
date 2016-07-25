' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: February 2016
' **  Updated: July 2016
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************
Library "v30/bslDefender.brs"

Sub Main()
    'Constants
    m.code = bslUniversalControlEventCodes()
    m.const = GetConstants()
    m.colors = { red: &hAA0000FF, green:&h00AA00FF, yellow: &hFFFF55FF, black: &hFF, white: &hFFFFFFFF, gray: &h404040FF, navy: &h100060FF, darkred: &h810000FF }
    'Util objects
    app = CreateObject("roAppManager")
    app.SetTheme(GetTheme())
    m.port = CreateObject("roMessagePort")
    m.clock = CreateObject("roTimespan")
    m.timer = CreateObject("roTimespan")
    m.audioPlayer = CreateObject("roAudioPlayer")
    m.audioPort = CreateObject("roMessagePort")
    m.audioPlayer.SetMessagePort(m.audioPort)
    m.sounds = LoadSounds(true)
    m.files = CreateObject("roFileSystem")
    m.fonts = CreateObject("roFontRegistry")
    m.fonts.Register("pkg:/assets/fonts/PoP.ttf")
    m.bitmapFont = [invalid, LoadBitmapFont(1), LoadBitmapFont(2)]
    m.mods = ParseJson(ReadAsciiFile("pkg:/mods/mods.json"))
    m.manifest = GetManifestArray()
    'Initialize Settings
    m.settings = LoadSettings()
    if m.settings = invalid
        m.settings = {}
        m.settings.controlMode = m.const.CONTROL_VERTICAL
        m.settings.spriteMode = m.const.SPRITES_DOS
    else if m.settings.modId <> invalid and m.mods[m.settings.modId].sprites
        m.settings.spriteMode = Val(m.settings.modId)
    end if
    if m.settings.fight = invalid
        m.settings.fight = m.const.FIGHT_ALERT
        m.settings.rewFF = m.const.REWFF_LEVEL
    end if
    m.maxLevels = 14
    m.status = []
    'Game/Debug switches
    m.debugMode = false ' flag to enable/disable debug code
    m.dark = false 'flag for debugging without map tiles paint
    m.intro = true 'flag to enable/disable intro screens
    m.disclaimer = true 'flag to enable/disable disclaimer
    m.flip = false 'flag to flip the screen vertically
    'Load saved game
    m.savedGame = LoadSavedGame()
    'Load Highscores
    m.highScores = LoadHighScores()
    if m.highScores = invalid then m.highScores = []
    'Check Roku model for performance alert
    if not IsOpenGL()
        MessageDialog("Prince of Persia", "Warning: Your Roku device doesn't support accelerated graphics, this game will not perform well.")
    end if
    while true
        'Intro and Start Menu
        if isHD()
            m.mainScreen = CreateObject("roScreen", true, 854, 480)
        else
            m.mainScreen = CreateObject("roScreen", true, 640, 480)
        end if
        m.mainScreen.SetMessagePort(m.port)
        if m.intro then
            print "Starting intro..."
            PlayIntro(m.mainScreen)
            if m.disclaimer
                PlaySong("scene-1b-princess", true)
                TextScreen(m.mainScreen, "text-disclaimer", m.colors.black, 27000, 0)
            end if
            m.disclaimer = false
            m.audioPlayer.stop()
        end if
        print "Starting menu..."
        m.cameras = StartMenu(m.mainScreen)
        if m.cameras > 0
            'Configure screen/game areas based on the configuration
            SetupGameScreen()
            'Setup initial parameters
            m.currentLevel = 1
            m.startTime = m.const.TIME_LIMIT
            m.startHealth = m.const.START_HEALTH
            'Restore saved game
            if m.savedGame <> invalid
                m.mainScreen.Clear(0)
                option = MessageBox(m.gameScreen, 320, 100, "Restore Saved Game?")
                if option = m.const.BUTTON_YES
                    m.currentLevel = m.savedGame.level
                    m.checkPoint = m.savedGame.checkPoint
                    m.startTime = m.savedGame.time
                    m.startHealth = m.savedGame.health
                    m.settings.modId = m.savedGame.modId
                    if m.savedGame.modId <> invalid and m.mods[m.settings.modId].sprites
                        m.settings.spriteMode = Val(m.settings.modId)
                    else if m.settings.spriteMode > m.const.SPRITES_MAC
                        m.settings.spriteMode = m.const.SPRITES_DOS
                    end if
                else
                    m.checkPoint = invalid
                end if
            else
                option = m.const.BUTTON_NO
            end if
            m.levelTime = m.startTime
            if option <> m.const.BUTTON_CANCEL
                if m.settings.spriteMode = m.const.SPRITES_MAC then suffix = "-mac" else suffix = "-dos"
                'Debug: Uncomment the next two lines to start at a specific location
                'm.currentLevel = 6
                'm.checkPoint = {room: 1, tile:19, face: 1}
                skip = false
                if m.currentLevel = 1
                    print "Starting opening story..."
                    PlaySong("scene-1a-absence")
                    skip = TextScreen(m.mainScreen, "text-in-the-absence" + suffix, m.colors.navy, 15000, 7)
                end if
                if not skip then skip = PlayScene(m.gameScreen, m.currentLevel)
                if m.currentLevel = 1 and not skip
                    TextScreen(m.mainScreen, "text-marry-jaffar" + suffix, m.colors.navy, 18000, 7)
                end if
                'Start game
                ResetGame()
                m.intro = PlayGame()
            else
                m.intro = false
            end if
        else
            m.intro = true
        end if
    end while
End Sub

Sub NextLevel()
    g = GetGlobalAA()
    if g.currentLevel = g.maxLevels then return
    g.currentLevel = g.currentLevel + 1
    g.startHealth = g.kid.maxHealth
    g.levelTime = g.timeLeft
    g.checkPoint = invalid
    PlayScene(g.gameScreen, g.currentLevel)
    ResetGame()
End Sub

Sub PreviousLevel()
    g = GetGlobalAA()
    if g.currentLevel = 1 or g.currentLevel = g.maxLevels then return
    g.currentLevel = g.currentLevel - 1
    g.startHealth = g.kid.maxHealth
    g.checkPoint = invalid
    ResetGame()
End Sub

Sub ResetGame()
    g = GetGlobalAA()
    if g.currentLevel = g.maxLevels and g.cameras > 1
        'Force final level always to be shown in Classic 1 room mode
        g.cameras = 1
        SetupGameScreen()
        g.kid = invalid
    end if
    if g.settings.modId <> invalid and g.mods[g.settings.modId].levels
        g.tileSet = LoadTiles(g.currentLevel, g.mods[g.settings.modId].url)
    else
        g.tileSet = LoadTiles(g.currentLevel)
    end if
    LoadGameSprites(g.tileSet.spriteMode, g.tileSet.level.type, g.scale, g.tileSet.level.guards)
    if g.checkPoint <> invalid
        g.startRoom = g.checkPoint.room
        g.startTile = g.checkPoint.tile
        g.startFace = g.checkPoint.face
    else
        g.startRoom = g.tileSet.level.prince.room
        g.startTile = g.tileSet.level.prince.location - 1
        g.startFace = g.tileSet.level.prince.direction
    end if
    if g.kid = invalid
        g.kid = CreateKid(g.tileSet.level, g.startRoom, g.startTile, g.startFace, g.startHealth)
    else
        g.kid.startLevel(g.tileSet.level, g.startRoom, g.startTile, g.startFace, g.startHealth)
    end if
    g.xOff = (g.const.ROOM_WIDTH * g.scale) * g.tileSet.level.rooms[g.startRoom].x
    g.yOff = (g.const.ROOM_HEIGHT * g.scale) * g.tileSet.level.rooms[g.startRoom].y
    g.oldRoom = g.startRoom
    g.floor = invalid
    if g.flip then FlipScreen()
    g.redraw = true
    if g.mobs <> invalid
        for each mob in g.mobs
            if mob.tile <> invalid then mob.tile.fall = false
            if mob.sprite.back <> invalid then mob.sprite.back.Remove()
        next
    end if
    if g.guards = invalid then g.guards = []
    if g.guards.Count() > 0
        for each guard in g.guards
            if guard.sprite <> invalid then  guard.sprite.Remove()
            if guard.sword.sprite <> invalid then guard.sword.sprite.remove()
            if guard.splash.sprite <> invalid then guard.splash.sprite.remove()
        next
        g.guards.Clear()
    end if
    for i = 0 to g.tileSet.level.guards.Count() - 1
        ginfo = g.tileSet.level.guards[i]
        if g.tileSet.level.rooms[ginfo.room] <> invalid
            g.guards.Push(CreateGuard(g.tileSet.level, ginfo.room, ginfo.location - 1, ginfo.direction, ginfo.skill, ginfo.type, ginfo.colors, ginfo.active, ginfo.visible))
        end if
    next
    g.status.Clear()
    If g.currentLevel < g.maxLevels - 1
        g.status.Push({ text: "LEVEL " + itostr(m.currentLevel), duration: 2, alert: false})
        g.showTime = true
    end if
    StopAudio()
End Sub

Sub SetupGameScreen()
	m.scale = 1.0
	if IsHD()
		if m.cameras = 3 '3x3
			maxResolution = true
			m.gameWidth = 960
			m.gameHeight = 600
		else if m.cameras = 2 '2x2
			maxResolution = false
			m.gameWidth = 640
			m.gameHeight = 400
		else 'classic 1x1 scale 2
			maxResolution = false
			m.cameras = 1
			m.gameWidth = 640
			m.gameHeight = 400
			m.scale = 2.0
		end if
		if maxResolution
			m.mainWidth = 1280
			m.mainHeight = 720
		else
			m.mainWidth = 854
			m.mainHeight = 480
		end if
	else
		if m.cameras = 3 '2x3
			maxResolution = true
			m.gameWidth = 640
			m.gameHeight = 600
		else if m.cameras = 2 '2x2
			maxResolution = false
			m.gameWidth = 640
			m.gameHeight = 400
		else 'classic 1x1 scale 2
			maxResolution = false
			m.cameras = 1
			m.gameWidth = 640
			m.gameHeight = 400
			m.scale = 2.0
		end if
		if maxResolution
			m.mainWidth = 854
			m.mainHeight = 626
		else
			m.mainWidth = 640
			m.mainHeight = 480
		end if
	end if
    ResetScreen(m.mainWidth, m.mainHeight, m.gameWidth, m.gameHeight)
End Sub

Sub ResetScreen(mainWidth as integer, mainHeight as integer, gameWidth as integer, gameHeight as integer)
    g = GetGlobalAA()
    g.mainScreen = CreateObject("roScreen", true, mainWidth, mainHeight)
    g.mainScreen.SetMessagePort(g.port)
    if mainWidth <> gameWidth or mainHeight <> gameHeight
        xOff = Cint((mainWidth-gameWidth) / 2)
        yOff = Cint((mainHeight-gameHeight) / 2)
        drwRegions = dfSetupDisplayRegions(g.mainScreen, xOff, yOff, gameWidth, gameHeight)
        g.gameScreen = drwRegions.main
    else
        g.gameScreen = g.mainScreen
    end if
    g.gameScreen.SetAlphaEnable(true)
    g.compositor = CreateObject("roCompositor")
    g.compositor.SetDrawTo(g.gameScreen, g.colors.black)
    g.gameCanvas = CreateObject("roBitmap",{width:gameWidth, height:gameHeight, alphaenable:true})
End Sub

Sub LoadGameSprites(spriteMode as integer, levelType as integer, scale as float, guards = [] as object)
    g = GetGlobalAA()
    if g.regions = invalid then g.regions = {spriteMode: spriteMode, levelType: levelType, scale: scale}
    path = "pkg:/assets/sprites/"
    if spriteMode = g.const.SPRITES_MAC
        suffix = "-mac"
        scale = scale / 2.0
    else
        suffix = "-dos"
    end if
    'print "scales: "; g.regions.scale; scale
    print "SpriteModes: "; g.regions.spriteMode; spriteMode
    'Check if a Mod with sprites is loaded
    useModSprite = (g.settings.modId <> invalid and g.mods[g.settings.modId].sprites and spriteMode = Val(g.settings.modId))
    'Load Regions
    if g.regions.general = invalid or g.regions.spriteMode <> spriteMode or g.regions.scale <> scale
        g.regions.scenes = LoadBitmapRegions(scale, path + "scenes/", "scenes" + suffix)
        if useModSprite and g.files.Exists("pkg:/mods/" + g.mods[g.settings.modId].url + "sprites/general.png")
            g.regions.general = LoadBitmapRegions(scale, "pkg:/mods/" + g.mods[g.settings.modId].url + "sprites/", "general")
        else
            g.regions.general = LoadBitmapRegions(scale, path + "general/", "general" + suffix)
        end if
        sprites = ["kid", "sword", "princess", "mouse", "vizier"]
        for each name in sprites
            fullPath = path + name + "/"
            fullName = name + suffix
            if useModSprite and g.files.Exists("pkg:/mods/" + g.mods[g.settings.modId].url + "sprites/" + name + ".png")
                fullPath = "pkg:/mods/" + g.mods[g.settings.modId].url + "sprites/"
                fullName = name
            end if
            charArray = []
            charArray.Push(LoadBitmapRegions(scale, fullPath, fullName, fullName, false))
            charArray.Push(LoadBitmapRegions(scale, fullPath, fullName, fullName, true))
            g.regions.AddReplace(name, charArray)
        next
    end if
    g.regions.guards = {}
    for i = 0 to guards.Count() - 1
        charArray = []
        if guards[i].type = "guard" then png = guards[i].type + itostr(guards[i].colors) else png = guards[i].type
        fullPath = path + "guards/"
        fullName = guards[i].type + suffix
        fullImage = png + suffix
        if useModSprite and g.files.Exists("pkg:/mods/" + g.mods[g.settings.modId].url + "sprites/" + png + ".png")
            fullPath = "pkg:/mods/" + g.mods[g.settings.modId].url + "sprites/"
            fullName = guards[i].type
            fullImage = png
        end if
        charArray.Push(LoadBitmapRegions(scale, fullPath, fullName, fullImage, false))
        charArray.Push(LoadBitmapRegions(scale, fullPath, fullName, fullImage, true))
        g.regions.guards.AddReplace(png, charArray)
    next
    if levelType >= 0
        if g.regions.tiles = invalid or g.regions.spriteMode <> spriteMode or g.regions.levelType <> levelType or g.regions.scale <> scale
            g.regions.tiles = invalid
            fullPath = path + "tiles/"
            if levelType = g.const.TYPE_DUNGEON
                fullName = "dungeon" + suffix
                if useModSprite and g.files.Exists("pkg:/mods/" + g.mods[g.settings.modId].url + "sprites/dungeon.png")
                    fullPath = "pkg:/mods/" + g.mods[g.settings.modId].url + "sprites/"
                    fullName = "dungeon"
                end if
            else
                fullName = "palace" + suffix
                if useModSprite and g.files.Exists("pkg:/mods/" + g.mods[g.settings.modId].url + "sprites/palace.png")
                    fullPath = "pkg:/mods/" + g.mods[g.settings.modId].url + "sprites/"
                    fullName = "palace"
                end if
            end if
            g.regions.tiles = LoadBitmapRegions(scale, fullPath, fullName)
        end if
    end if
    g.regions.spriteMode = spriteMode
    g.regions.levelType = levelType
    g.regions.scale = scale
End Sub

Function GetTheme() as object
    theme = {
                BackgroundColor: "#000000",
                OverhangSliceSD: "pkg:/images/overhang_sd.jpg",
                OverhangSliceHD: "pkg:/images/overhang_hd.jpg",
                ListScreenHeaderText: "#FFFFFF",
                ListScreenDescriptionText: "#FFFFFF",
                ListItemHighlightText: "#FF0000"
            }
    return theme
End Function
