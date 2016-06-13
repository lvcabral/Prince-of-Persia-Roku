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
Library "v30/bslDefender.brs"

Sub Main()
    'Constants
    m.code = bslUniversalControlEventCodes()
    m.const = GetConstants()
    m.colors = { red: &hFF000080, green:&h00FF0080, blue: &h0000FF80, yellow: &hFFD80080, black: &hFF, white: &hFFFFFFFF, gray: &h404040FF, navy: &h100060FF, darkred: &h810000FF }
    'Util objects
    m.port = CreateObject("roMessagePort")
    m.clock = CreateObject("roTimespan")
    m.timer = CreateObject("roTimespan")
    m.compositor = CreateObject("roCompositor")
    m.audioPlayer = CreateObject("roAudioPlayer")
    m.audioPort = CreateObject("roMessagePort")
    m.audioPlayer.SetMessagePort(m.audioPort)
    m.sounds = LoadSounds(true)
    m.fonts = CreateObject("roFontRegistry")
    m.fonts.Register("pkg:/assets/fonts/PoP.ttf")
    m.bitmapFont = [invalid, LoadBitmapFont(1), LoadBitmapFont(2)]
    m.manifest = GetManifestArray()
    'Initialize Settings
    m.settings = LoadSettings()
    if m.settings = invalid
        m.settings = {}
        m.settings.controlMode = m.const.CONTROL_VERTICAL
        m.settings.spriteMode = m.const.SPRITES_DOS
    end if
    'Game/Debug switches
    m.debugMode = false ' flag to enable/disable debug code
    m.dark = false 'flag for debugging without map tiles paint
    m.fight = m.const.FIGHT_ATTACK 'parameter to set opponents fight behavior
    m.intro = true 'flag to enable/disable intro screens
    'Load saved game
    m.savedGame = LoadSavedGame()
    m.maxLevels = 14
    m.status = []
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
            PlaySong("scene-1b-princess", true)
            TextScreen(m.mainScreen, "text-disclaimer", m.colors.black, 27000, 0)
            m.audioPlayer.stop()
        end if
        print "Starting menu..."
        m.cameras = StartMenu(m.mainScreen)
        'Configure screen/game areas based on the configuration
        SetupGameScreen()
        'Load general assets
        if m.settings.spriteMode = m.const.SPRITES_DOS
            suffix = "-dos"
            m.general = LoadBitmapRegions(m.scale, "general", "general-dos")
        else
            suffix = "-mac"
            m.general = LoadBitmapRegions(m.scale / 2, "general", "general-mac")
        end if
        m.currentLevel = 1
        m.startTime = m.const.TIME_LIMIT
        m.startHealth = m.const.START_HEALTH
        'Load saved game
        if m.savedGame <> invalid
            m.mainScreen.Clear(0)
            option = MessageBox(m.gameScreen, 320, 100, "Restore Saved Game?")
            if option = m.const.BUTTON_YES
                m.currentLevel = m.savedGame.level
                m.checkPoint = m.savedGame.checkPoint
                m.startTime = m.savedGame.time
                m.startHealth = m.savedGame.health
            else
                m.checkPoint = invalid
            end if
        else
            option = m.const.BUTTON_NO
        end if
        if option <> m.const.BUTTON_CANCEL
            'Debug: Uncomment the next two lines to start at a specific location
            'm.currentLevel = 3
            'm.checkPoint = {room: 7, tile:7, face: 1}
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
    end while
End Sub

Sub NextLevel()
    g = GetGlobalAA()
    if g.currentLevel = g.maxLevels then return
    g.currentLevel = g.currentLevel + 1
    g.checkPoint = invalid
    PlayScene(g.gameScreen, g.currentLevel)
    ResetGame()
End Sub

Sub PreviousLevel()
    g = GetGlobalAA()
    if g.currentLevel = 1 or g.currentLevel = g.maxLevels then return
    g.currentLevel = g.currentLevel - 1
    g.checkPoint = invalid
    ResetGame()
End Sub

Sub ResetGame()
    g = GetGlobalAA()
    if g.currentLevel = g.maxLevels and g.cameras > 1
        'Force final level always to be shown in Classic 1 room mode
        g.cameras = 1
        g.scale = 2.0
        if IsHD()
            ResetScreen(854, 480, 640, 400)
        else
            ResetScreen(640, 480, 640, 400)
        end if
        if g.settings.spriteMode = m.const.SPRITES_DOS
            g.general = LoadBitmapRegions(g.scale, "general", "general-dos")
        else
            m.general = LoadBitmapRegions(g.scale/2, "general", "general-mac")
        end if
    end if
    g.tileSet = LoadTiles(g.currentLevel)
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
        g.kid.startLevel(g.tileSet.level, g.startRoom, g.startTile, g.startFace)
    end if
    g.xOff = (g.const.ROOM_WIDTH * g.scale) * g.tileSet.level.rooms[g.startRoom].x
    g.yOff = (g.const.ROOM_HEIGHT * g.scale) * g.tileSet.level.rooms[g.startRoom].y
    g.oldRoom = g.startRoom
    g.floor = invalid
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
        g.guards.Push(CreateGuard(g.tileSet.level, ginfo.room, ginfo.location - 1, ginfo.direction, ginfo.skill, ginfo.type, ginfo.colors, ginfo.active, ginfo.visible))
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
        xOff = Cint((mainWidth-gameWidth)/2)
        yOff = Cint((mainHeight-gameHeight)/2)
        drwRegions = dfSetupDisplayRegions(g.mainScreen, xOff, yOff, gameWidth, gameHeight)
        g.gameScreen = drwRegions.main
    else
        g.gameScreen = g.mainScreen
    end if
    g.gameScreen.SetAlphaEnable(true)
    g.compositor.SetDrawTo(g.gameScreen, g.colors.black)
End Sub
