' ********************************************************************************************************
' ********************************************************************************************************
' **  Prince of Persia for Roku - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: July 2016
' **  Updated: January 2024
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

function LoadMods() as object
    Sleep(500)
    TextBox(m.mainScreen, 620, 50, "Loading...")
    'Load internal Mods
    mods = ParseJson(ReadAsciiFile("pkg:/mods/mods.json"))
    m.webMods = "https://lvcabral.com/pop/mods/"
    'Load remote Mods (if available)
    if m.webMods <> invalid and CacheFile(m.webMods + "mods.json", "mods.json") <> ""
        modsWeb = ParseJson(ReadAsciiFile("tmp:/mods.json"))
        if modsWeb <> invalid
            print modsWeb.Count(); " mods dowloaded"
            mods.Append(modsWeb)
        else
            print "Invalid mods JSON file!"
        end if
    else
        Sleep(1000)
    end if
    return mods
end function

sub DownloadMod(webMod as object)
    ClearScreenBuffers()
    'Set mods remote URL
    modUrl = m.webMods + webMod.path
    if not m.files.Exists("tmp:/" + webMod.path) then m.files.CreateDirectory("tmp:/" + webMod.path)
    if webMod.levels
        TextBox(m.mainScreen, 620, 50, "Loading " + webMod.name + " levels...")
        for l = 1 to 11
            file = "level" + l.toStr() + ".xml"
            CacheFile(modUrl + "levels/" + file, webMod.path + file)
        next
        CacheFile(modUrl + "levels/level12a.xml", webMod.path + "level12a.xml")
        CacheFile(modUrl + "levels/level12b.xml", webMod.path + "level12b.xml")
        CacheFile(modUrl + "levels/princess.xml", webMod.path + "princess.xml")
    end if
    if webMod.titles
        TextBox(m.mainScreen, 620, 50, "Loading " + webMod.name + " titles...")
        CacheFile(modUrl + "titles/intro-screen.png", webMod.path + "intro-screen.png")
        CacheFile(modUrl + "titles/message-author.png", webMod.path + "message-author.png")
        CacheFile(modUrl + "titles/message-game-name.png", webMod.path + "message-game-name.png")
        CacheFile(modUrl + "titles/message-port.png", webMod.path + "message-port.png")
        CacheFile(modUrl + "titles/message-presents.png", webMod.path + "message-presents.png")
        CacheFile(modUrl + "titles/text-in-the-absence.png", webMod.path + "text-in-the-absence.png")
        CacheFile(modUrl + "titles/text-marry-jaffar.png", webMod.path + "text-marry-jaffar.png")
        CacheFile(modUrl + "titles/text-screen.png", webMod.path + "text-screen.png")
        CacheFile(modUrl + "titles/text-the-tyrant.png", webMod.path + "text-the-tyrant.png")
    end if
    if webMod.palettes
        CacheFile(modUrl + "palettes/wall.pal", webMod.path + "wall.pal")
    end if
    if webMod.sprites and webMod.files <> invalid and webMod.files.sprites <> invalid
        TextBox(m.mainScreen, 620, 50, "Loading " + webMod.name + " sprites...")
        for each file in webMod.files.sprites
            if file = "guards"
                CacheFile(modUrl + "sprites/guard.json", webMod.path + "guard.json")
                for g = 1 to 7
                    guard = "guard" + g.toStr()
                    CacheFile(modUrl + "sprites/" + guard + ".png", webMod.path + guard + ".png")
                next
            else
                CacheFile(modUrl + "sprites/" + file + ".json", webMod.path + file + ".json", true)
                CacheFile(modUrl + "sprites/" + file + ".png", webMod.path + file + ".png", true)
            end if
        next
    end if
    if webMod.sounds and webMod.files <> invalid and webMod.files.sounds <> invalid
        TextBox(m.mainScreen, 620, 50, "Loading " + webMod.name + " sounds...")
        for each file in webMod.files.sounds
            CacheFile(modUrl + "sounds/" + file + ".wav", webMod.path + file + ".wav", true)
        next
    end if
end sub

function GetModIcon(modId as dynamic) as string
    cloud = false
    modImage = "pkg:/assets/titles/intro-screen-dos.png"
    modCover = "tmp:/0000001.png"
    if modId <> invalid
        modAA = m.mods[modId]
        if Left(modAA.url, 3) = "pkg"
            modImage = modAA.url + modAA.path + modId + "_1.png"
        else
            modImage = CacheFile(m.webMods + modAA.path + modId + "_1.png", modId + "_1.png")
            cloud = true
        end if
        modCover = "tmp:/" + modId + ".png"
    end if
    if modImage <> "" and not m.files.Exists(modCover)
        bmp = ScaleToSize(CreateObject("roBitmap", modImage), 256, 160)
        bmp.DrawLine(1, 1, 255, 1, m.colors.white)
        bmp.DrawLine(255, 1, 255, 159, m.colors.white)
        bmp.DrawLine(255, 159, 1, 159, m.colors.white)
        bmp.DrawLine(1, 159, 1, 1, m.colors.white)
        bmp.Finish()
        png = bmp.GetPng(0, 0, 256, 160)
        png.WriteFile(modCover)
    end if
    return modCover
end function

function ModsScreen(port = invalid) as string
    screen = CreateGridScreen()
    if port = invalid then port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    'Load the content
    content = []
    modsCount = m.mods.keys().count()
    screen.SetListCount("1 of " + modsCount.toStr() + " mods")
    screen.ShowMessage("Loading mods...")
    screen.Show()
    modArray = []
    modIndex = 0
    for each modId in m.mods.Keys()
        m.mods[modId].id = modId
        modArray.Push(m.mods[modId])
        imgPath = GetModIcon(modId)
        content.Push({ id: modId, HDPosterUrl: imgPath })
    next
    screen.SetContentList(content)
    modAA = m.mods[modArray[modIndex].id]
    if modAA <> invalid
        screen.SetListName(ModDescription(modAA))
    end if
    selected = ""
    while true
        msg = screen.Wait()
        if msg = invalid
            screen.show()
        else if msg.isScreenClosed()
            selected = ""
            exit while
        else if msg.isListItemFocused()
            idx = msg.GetIndex()
            screen.SetListCount((idx + 1).toStr() + " of " + modsCount.toStr() + " mods")
            item = content[idx]
            modAA = m.mods[item.id]
            if modAA <> invalid
                screen.SetListName(ModDescription(modAA))
            end if
        else if msg.isListItemSelected()
            item = content[msg.GetIndex()]
            if item <> invalid
                selected = item.id
            end if
            exit while
        end if
    end while
    return selected
end function

sub SecretCheatsScreen()
    this = {
        screen: CreateListScreen()
        port: m.port
    }
    this.screen.SetMessagePort(this.port)
    this.screen.SetHeader("Secret Cheats Screen")
    this.fight = " Fight Mode: "
    this.fightModes = ["Attack", "Alert", "Frozen"]
    this.fightHelp = ["Enemies will attack you!", "Enemies will be alert and follow you", "Enemies will be static"]
    this.fightIndex = m.settings.fight
    this.cheat = " Cheat Keys: "
    this.cheatModes = ["Change Level", "Change Health", "Change Time", "(disabled)"]
    this.cheatHelp = ["Advance or return game levels", "Increase or decrease Prince health", "Add or subtract 1 minute", "Cheat Keys disabled"]
    this.cheatIndex = m.settings.cheatMode
    if m.inSimulator then this.info = " Info Key: " else this.info = " OK Key: "
    this.infoModes = ["Remaining Time", "Set Debug Mode"]
    this.infoHelp = ["Show game remaining time", "Turn on/off Debug mode"]
    this.infoIndex = m.settings.infoMode
    this.save = " Saved Game: "
    this.saveMode = m.settings.saveGame
    if this.saveMode
        if m.savedGame <> invalid
            this.saveTitle = SavedGameTitle(m.savedGame)
            this.saveImage = GetModIcon(m.savedGame.modId)
            if m.savedGame.modId <> invalid
                this.saveDesc = m.mods[m.savedGame.modId].name
            else
                this.saveDesc = "Original Game Levels"
            end if
        else
            this.saveTitle = "(enabled)"
            this.saveDesc = ""
        end if
    else
        this.saveTitle = "(disabled)"
        this.saveImage = ""
        this.saveDesc = ""
    end if
    listItems = GetListItems(this)
    this.screen.SetContent(listItems)
    this.screen.Show()
    listIndex = 0
    oldIndex = 0
    this.oldIcon = "pkg:/images/icon_arrows_bw.png"
    while true
        msg = this.screen.Wait(this.port)
        if msg.isScreenClosed()
            exit while
        else if msg.isListItemFocused()
            listIndex = msg.GetIndex()
            this.newIcon = "pkg:/images/icon_arrows.png"
            listItems[listIndex].HDSmallIconUrl = this.newIcon
            listItems[listIndex].SDSmallIconUrl = this.newIcon
            this.screen.SetItem(listIndex, listItems[listIndex], false)
            listItems[oldIndex].HDSmallIconUrl = this.oldIcon
            listItems[oldIndex].SDSmallIconUrl = this.oldIcon
            this.screen.SetItem(oldIndex, listItems[oldIndex])
            oldIndex = listIndex
        else if msg.isRemoteKeyPressed()
            remoteKey = msg.GetIndex()
            if listIndex = 0 'Fight Mode
                if remoteKey = m.code.BUTTON_LEFT_PRESSED
                    this.fightIndex--
                    if this.fightIndex < 0
                        this.fightIndex = this.fightModes.Count() - 1
                    end if
                else if remoteKey = m.code.BUTTON_RIGHT_PRESSED or remoteKey = m.code.BUTTON_SELECT_PRESSED
                    this.fightIndex++
                    if this.fightIndex = this.fightModes.Count()
                        this.fightIndex = 0
                    end if
                end if
                listItems[listIndex].Title = this.fight + this.fightModes[this.fightIndex]
                listItems[listIndex].ShortDescriptionLine1 = this.fightHelp[this.fightIndex]
                listItems[listIndex].HDPosterUrl = "pkg:/images/fight_" + this.fightIndex.toStr() + ".jpg"
                listItems[listIndex].SDPosterUrl = listItems[listIndex].HDPosterUrl
                this.screen.SetItem(listIndex, listItems[listIndex])
                m.settings.fight = this.fightIndex
            else if listIndex = 1 'Cheat Mode
                if remoteKey = m.code.BUTTON_LEFT_PRESSED
                    this.cheatIndex--
                    if this.cheatIndex < 0
                        this.cheatIndex = this.cheatModes.Count() - 1
                    end if
                else if remoteKey = m.code.BUTTON_RIGHT_PRESSED or remoteKey = m.code.BUTTON_SELECT_PRESSED
                    this.cheatIndex++
                    if this.cheatIndex = this.cheatModes.Count()
                        this.cheatIndex = 0
                    end if
                end if
                listItems[listIndex].Title = this.cheat + this.cheatModes[this.cheatIndex]
                listItems[listIndex].ShortDescriptionLine1 = this.cheatHelp[this.cheatIndex]
                listItems[listIndex].HDPosterUrl = "pkg:/images/cheat_" + this.cheatIndex.toStr() + ".jpg"
                listItems[listIndex].SDPosterUrl = listItems[listIndex].HDPosterUrl
                this.screen.SetItem(listIndex, listItems[listIndex])
                m.settings.cheatMode = this.cheatIndex
            else if listIndex = 2 'Info Key Mode
                if remoteKey = m.code.BUTTON_LEFT_PRESSED
                    this.infoIndex--
                    if this.infoIndex < 0
                        this.infoIndex = this.infoModes.Count() - 1
                    end if
                else if remoteKey = m.code.BUTTON_RIGHT_PRESSED or remoteKey = m.code.BUTTON_SELECT_PRESSED
                    this.infoIndex++
                    if this.infoIndex = this.infoModes.Count()
                        this.infoIndex = 0
                    end if
                end if
                listItems[listIndex].Title = this.info + this.infoModes[this.infoIndex]
                listItems[listIndex].ShortDescriptionLine1 = this.infoHelp[this.infoIndex]
                listItems[listIndex].HDPosterUrl = "pkg:/images/infokey_" + this.infoIndex.toStr() + ".jpg"
                listItems[listIndex].SDPosterUrl = listItems[listIndex].HDPosterUrl
                this.screen.SetItem(listIndex, listItems[listIndex])
                m.settings.infoMode = this.infoIndex
            else if listIndex = 3 'Save Game
                if remoteKey = m.code.BUTTON_LEFT_PRESSED or remoteKey = m.code.BUTTON_RIGHT_PRESSED or remoteKey = m.code.BUTTON_SELECT_PRESSED
                    this.saveMode = not this.saveMode
                    m.settings.saveGame = this.saveMode
                end if
                if this.saveMode
                    if m.savedGame <> invalid
                        this.saveTitle = SavedGameTitle(m.savedGame)
                        this.saveImage = GetModIcon(m.savedGame.modId)
                        if m.savedGame.modId <> invalid
                            this.saveDesc = m.mods[m.savedGame.modId].name
                        else
                            this.saveDesc = "Original Game Levels"
                        end if
                    else
                        this.saveTitle = "(enabled)"
                        this.saveDesc = ""
                    end if
                else
                    this.saveTitle = "(disabled)"
                    this.saveImage = ""
                    this.saveDesc = ""
                end if
                listItems[listIndex].Title = this.save + this.saveTitle
                listItems[listIndex].ShortDescriptionLine1 = this.saveDesc
                listItems[listIndex].HDPosterUrl = this.saveImage
                listItems[listIndex].SDPosterUrl = this.saveImage
                this.screen.SetItem(listIndex, listItems[listIndex])
            end if
            if remoteKey = m.code.BUTTON_LEFT_PRESSED or remoteKey = m.code.BUTTON_RIGHT_PRESSED or remoteKey = m.code.BUTTON_SELECT_PRESSED
                m.sounds.navSingle.Trigger(50)
                SaveSettings(m.settings)
            end if
        end if
    end while
end sub

function GetListItems(menu as object)
    listItems = []
    listItems.Push({
        Title: menu.fight + menu.fightModes[menu.fightIndex]
        HDSmallIconUrl: "pkg:/images/icon_arrows.png"
        SDSmallIconUrl: "pkg:/images/icon_arrows.png"
        HDPosterUrl: "pkg:/images/fight_" + menu.fightIndex.toStr() + ".jpg"
        SDPosterUrl: "pkg:/images/fight_" + menu.fightIndex.toStr() + ".jpg"
        ShortDescriptionLine1: menu.fightHelp[menu.fightIndex]
        ShortDescriptionLine2: "Use Left and Right to select a Fight Mode"
    })
    listItems.Push({
        Title: menu.cheat + menu.cheatModes[menu.cheatIndex]
        HDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
        SDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
        HDPosterUrl: "pkg:/images/cheat_" + menu.cheatIndex.toStr() + ".jpg"
        SDPosterUrl: "pkg:/images/cheat_" + menu.cheatIndex.toStr() + ".jpg"
        ShortDescriptionLine1: menu.cheatHelp[menu.cheatIndex]
        ShortDescriptionLine2: "Use Left and Right to set cheat keys mode"
    })
    listItems.Push({
        Title: menu.info + menu.infoModes[menu.infoIndex]
        HDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
        SDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
        HDPosterUrl: "pkg:/images/infokey_" + menu.infoIndex.toStr() + ".jpg",
        SDPosterUrl: "pkg:/images/infokey_" + menu.infoIndex.toStr() + ".jpg",
        ShortDescriptionLine1: menu.infoHelp[menu.infoIndex]
        ShortDescriptionLine2: "Use Left and Right to set key mode"
    })
    listItems.Push({
        Title: menu.save + menu.saveTitle
        HDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
        SDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
        HDPosterUrl: menu.saveImage,
        SDPosterUrl: menu.saveImage,
        ShortDescriptionLine1: menu.saveDesc,
        ShortDescriptionLine2: "Use Left and Right to enable/disable save"
    })
    return listItems
end function

function ModDescription(modAA as object) as string
    if modAA.author = "" then return "Original Game Levels"
    modAuthor = " by " + modAA.author + " - Custom "
    modFeatures = ""
    if modAA.levels then modFeatures = "levels"
    if modAA.sprites
        if modFeatures <> ""
            modFeatures = modFeatures + ", "
        end if
        modFeatures = modFeatures + "sprites"
    end if
    if modAA.sounds
        if modFeatures <> ""
            modFeatures = modFeatures + ", "
        end if
        modFeatures = modFeatures + "sounds"
    end if
    regex = CreateObject("roRegex", ",(?=[^,]+$)", "i")
    return modAA.name + modAuthor + regex.replace(modFeatures," and")
end function

function SavedGameTitle(game as object) as string
    return "Level " + game.level.toStr() + " at " + CInt(game.time / 60).toStr() + "min"
end function
