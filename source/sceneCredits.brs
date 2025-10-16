' ********************************************************************************************************
' ********************************************************************************************************
' **  Prince of Persia for Roku - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: April 2016
' **  Updated: October 2024
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function PlayIntro(spriteMode = -1 as integer) as boolean
	screen = m.mainScreen
	scale = Int(GetScale(screen, 320, 200))
	posScale = scale
	if spriteMode = -1
		spriteMode = m.settings.spriteMode
	end if
	if spriteMode = m.const.SPRITES_MAC
		scale /= 2
		suffix = "-mac"
	else
		suffix = "-dos"
	end if
	pngIntro = "pkg:/assets/titles/intro-screen" + suffix + ".png"
	pngPresents = "pkg:/assets/titles/message-presents" + suffix + ".png"
	pngAuthor = "pkg:/assets/titles/message-author" + suffix + ".png"
	pngGame = "pkg:/assets/titles/message-game-name" + suffix + ".png"
	pngPort = "pkg:/assets/titles/message-port" + suffix + ".png"
	'Check if there is a configured mod with custom images
	if spriteMode > m.const.SPRITES_MAC and m.settings.modId <> invalid and m.mods[m.settings.modId].titles
		modPath = m.mods[m.settings.modId].url + m.mods[m.settings.modId].path
        if Left(modPath, 3) = "pkg"
			modPath = modPath + "titles/"
		end if
		if m.files.Exists(modPath + "intro-screen.png")
			pngIntro = modPath + "intro-screen.png"
		end if
		if m.files.Exists(modPath + "message-presents.png")
			pngPresents = modPath + "message-presents.png"
		end if
		if m.files.Exists(modPath + "message-author.png")
			pngAuthor = modPath + "message-author.png"
		end if
		if m.files.Exists(modPath + "message-game-name.png")
			pngGame = modPath + "message-game-name.png"
		end if
		if m.files.Exists(modPath + "message-port.png")
			pngPort = modPath + "message-port.png"
		end if
	end if
	wait(500, m.port)
	skip = false
    centerX = Cint((screen.GetWidth() - (320 * posScale)) / 2)
    centerY = Cint((screen.GetHeight() - (200 * posScale)) / 2)
	intro = ScaleBitmap(CreateObject("roBitmap", pngIntro), scale)
	ImageFadeIn(screen, centerX, centerY, intro, 3)
    PlaySong("main-theme")
    msg = wait(2600, m.port)
    for s = 1 to 5
        if msg <> invalid
            m.audioPlayer.stop()
            return true
        end if
        if s = 1
            screen.DrawObject(centerX, centerY, intro)
            screen.DrawObject(centerX + 96 * posScale, centerY + 106 * posScale, ScaleBitmap(CreateObject("roBitmap", pngPresents),scale))
            delay = 2500
        else if s = 2
            screen.DrawObject(centerX, centerY, intro)
            delay = 2000
        else if s = 3
            screen.DrawObject(centerX, centerY, intro)
            screen.DrawObject(centerX + 96 * posScale, centerY + 122 * posScale, ScaleBitmap(CreateObject("roBitmap", pngAuthor),scale))
            delay = 4000
        else if s = 4
            screen.DrawObject(centerX, centerY, ScaleBitmap(CreateObject("roBitmap", pngIntro),scale))
            delay = 4300
        else if s = 5
            screen.DrawObject(centerX, centerY, intro)
            screen.DrawObject(centerX + 24 * posScale, centerY + 107 * posScale, ScaleBitmap(CreateObject("roBitmap", pngGame),scale))
			if left(pngPort, 9) = "pkg:/mods" or left(pngPort, 5) = "tmp:/"
            	screen.DrawObject(centerX + 48 * posScale, centerY + 184 * posScale, ScaleBitmap(CreateObject("roBitmap", pngPort),scale))
			else
				screen.DrawObject(centerX + 35 * posScale, centerY + 180 * posScale, ScaleBitmap(CreateObject("roBitmap", pngPort),scale))
			end if
            delay = 8700
        end if
        screen.SwapBuffers()
        msg = wait(delay, m.port)
    next
	return skip
End Function

Sub PlayEnding()
	scale = Int(GetScale(m.mainScreen, 320, 200))
	if m.settings.spriteMode = m.const.SPRITES_MAC
		suffix = "-mac"
		introScale = scale / 2
	else
		suffix = "-dos"
		introScale = scale
	end if
	PlaySong("victory")
	TextScreen("text-the-tyrant", m.colors.darkred, 19000, 7)
	if not m.usedCheat then CheckHighScores()
	skip = ShowHighScores(m.mainScreen, 3000)
	if skip then return
	centerX = Cint((m.mainScreen.GetWidth()-(320*scale))/2)
	centerY = Cint((m.mainScreen.GetHeight()-(200*scale))/2)
	intro = ScaleBitmap(CreateObject("roBitmap", "pkg:/assets/titles/intro-screen"+suffix+".png"), introScale)
	ImageFadeIn(m.mainScreen, centerX, centerY, intro, 4)
	wait(95000, m.port)
	m.audioPlayer.stop()
End Sub

Function TextScreen(pngFile as string, color as integer, waitTime = 0 as integer, fadeIn = 4 as integer, spriteMode = -1 as integer) as boolean
	screen = m.mainScreen
    screen.Clear(0)
    scale = Int(GetScale(screen, 320, 200))
    centerX = Cint((screen.GetWidth() - (320 * scale)) / 2)
    centerY = Cint((screen.GetHeight() - (200 * scale)) / 2)
	canvas = GetPaintedBitmap(&HFF, 320 * scale, 200 * scale, true)
	if spriteMode = -1 then spriteMode = m.settings.spriteMode
	useMod = (m.settings.modId <> invalid and m.mods[m.settings.modId].titles)
	if useMod
		modPath = m.mods[m.settings.modId].url + m.mods[m.settings.modId].path
		if Left(modPath, 3) = "pkg"
			modPath = modPath + "titles/"
		end if
	end if
	if spriteMode = m.const.SPRITES_MAC
		canvas.DrawObject(0, 0, ScaleBitmap(CreateObject("roBitmap", "pkg:/assets/titles/text-screen-mac.png"), scale / 2))
		bmp = CreateObject("roBitmap", "pkg:/assets/titles/" + pngFile + "-mac.png")
	else if useMod and m.files.Exists(modPath + "text-screen.png")
		canvas.DrawObject(0, 0, ScaleBitmap(CreateObject("roBitmap", modPath + "text-screen.png"), scale))
		bmp = CreateObject("roBitmap", modPath + pngFile + ".png")
	else
		canvas.DrawObject(0, 0, ScaleBitmap(CreateObject("roBitmap", "pkg:/assets/titles/text-screen-dos.png"), scale))
		bmp = CreateObject("roBitmap", "pkg:/assets/titles/" + pngFile + "-dos.png")
    end if
	if bmp = invalid and m.files.Exists( "pkg:/assets/titles/" + pngFile + ".png")
		bmp = CreateObject("roBitmap", "pkg:/assets/titles/" + pngFile + ".png")
	end if
	if bmp.GetWidth() <= 320
		bmp = ScaleBitmap(bmp, scale)
	else
		bmp = ScaleBitmap(bmp, scale / 2)
	end if
	canvas.DrawRect(16 * scale, 16 * scale, 288 * scale, 156 * scale, color)
	canvas.DrawObject(30 * scale, 25 * scale, bmp)
	if fadeIn > 0
		ImageFadeIn(screen, centerX, centerY, canvas, fadeIn)
	else
		screen.DrawObject(centerX, centerY, canvas)
		screen.SwapBuffers()
	end if
	while true
    	key = wait(waitTime, m.port)
		if type(key) = "roUniversalControlEvent"
			key = key.getInt()
		end if
		if key = invalid or key < 100 then exit while
	end while
	return (key <> invalid)
End Function

Sub CheckHighScores()
    counter = 0
    index = -1
    newScores = []
    if m.highScores.Count() = 0
        index = 0
        newScores.Push({name: "", time: m.timeLeft})
    else
        for each score in m.highScores
            if m.timeLeft > score.time and index < 0
                index = counter
                newScores.Push({name: "", time: m.timeLeft})
                counter++
                if counter = 7
					exit for
				end if
            end if
            newScores.Push(score)
            counter++
            if counter = 7
				exit for
			end if
        next
		if counter < 7 and index < 0
			index = counter
			newScores.Push({name: "", time: m.timeLeft})
		end if
    end if
    if index >= 0
        newScores[index].name = KeyboardScreen("", "Please type your name")
        m.highScores = newScores
        SaveHighScores(m.highScores)
    end if
End Sub

Function ShowHighScores(screen as object, waitTime = 0 as integer) as boolean
	screen.Clear(0)
	scale = Int(GetScale(screen, 320, 200))
	centerX = Cint((screen.GetWidth()-(320*scale))/2)
	centerY = Cint((screen.GetHeight()-(200*scale))/2)
	canvas = GetPaintedBitmap(m.colors.darkred, 320 * scale, 200 * scale, true)
	if m.settings.spriteMode = m.const.SPRITES_MAC
		canvas.DrawObject(0, 0, ScaleBitmap(CreateObject("roBitmap", "pkg:/assets/titles/text-screen-mac.png"), scale / 2))
		canvas.DrawObject(22 * scale, 22 * scale, ScaleBitmap(CreateObject("roBitmap", "pkg:/assets/titles/message-game-name-mac.png"), scale / 2))
	else
		canvas.DrawObject(0, 0, ScaleBitmap(CreateObject("roBitmap", "pkg:/assets/titles/text-screen-dos.png"), scale))
		canvas.DrawObject(22 * scale, 22 * scale, ScaleBitmap(CreateObject("roBitmap", "pkg:/assets/titles/message-game-name-dos.png"), scale))
	end if
	xn = 72 * scale
	xt = 217 * scale
	ys = 85 * scale
	for each score in m.highScores
	    m.bitmapFont.write(canvas, score.name, xn, ys, 2.0)
	    m.bitmapFont.write(canvas, FormatTime(score.time), xt, ys, 2.0)
	    ys += (12 * scale)
	next
	screen.DrawObject(centerX, centerY, canvas)
	screen.SwapBuffers()
	screen.DrawObject(centerX, centerY, canvas)
	screen.SwapBuffers()
	while true
    	key = wait(waitTime, m.port)
		if type(key) = "roUniversalControlEvent"
			key = key.getInt()
		end if
		if key = invalid or key < 100 then exit while
	end while
	return (key<>invalid)
End Function
