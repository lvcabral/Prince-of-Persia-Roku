' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: July 2016
' **  Updated: November 2019
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function LoadMods() as object
    Sleep(500)
    TextBox(m.mainScreen, 620, 50, "Loading...")
    'Load internal Mods
    mods = ParseJson(ReadAsciiFile("pkg:/mods/mods.json"))
    'Uncomment and edit the line below to add the URL if you are hosting remote mods
    'm.webMods = "http://YOURDOMAIN/MODSFOLDER/"
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
End Function

Sub DownloadMod(webMod as object)
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
End Sub

Function GetModImage(modId as dynamic) as string
    cloud = false
    modImage = "pkg:/assets/titles/intro-screen-dos.png"
    modCover = "tmp:/0000001.png"
    if modId <> invalid
        modAA = m.mods[modId]
        if Left(modAA.url,3) = "pkg"
            modImage = modAA.url + modAA.path + modId + "_1.png"
        else
            modImage = CacheFile(m.webMods + modAA.path + modId + "_1.png", modId + "_1.png")
            cloud = true
        end if
        modCover = "tmp:/" + modId + ".png"
    end if
    if modImage <> "" and not m.files.Exists(modCover)
        bmp = GetPaintedBitmap(0, 360, 240, true)
        bmp.DrawObject(20, 20, CreateObject("roBitmap", modImage))
        bmp.DrawLine(19, 19, 19 + 322, 19, m.colors.white)
        bmp.DrawLine(19 + 322, 19, 19 + 322, 19 + 202, m.colors.white)
        bmp.DrawLine(19 + 322, 19 + 202, 19, 19 + 202, m.colors.white)
        bmp.DrawLine(19, 19 + 202, 19, 19, m.colors.white)
        if cloud
            bmp.DrawObject(312, 192, CreateObject("roBitmap", "pkg:/images/icon_cloud.png"))
        end if
        bmp.Finish()
        png = bmp.GetPng(0, 0, 360, 240)
        png.WriteFile(modCover)
    end if
    return modCover
End Function

Sub ModsAndCheatsScreen()
    m.mainScreen = CreateObject("roScreen", true, 1280, 720)
    m.mainScreen.SetMessagePort(m.port)
    this = {
            screen: CreateListScreen()
            port: m.port
           }
    this.screen.SetMessagePort(this.port)
    this.screen.SetHeader("Mods and Cheats")
    this.modArray = [{name: "(none)", author:"", levels: false, sprites: false, sounds: false}]
    this.modIndex = 0
    for each modId in m.mods.Keys()
        if modId = m.settings.modId then this.modIndex = this.modArray.Count()
        m.mods[modId].id = modId
        this.modArray.Push(m.mods[modId])
    next
    this.fightModes = ["Attack", "Alert", "Frozen"]
    this.fightHelp  = ["Enemies will attack you!", "Enemies will be alert and follow you", "Enemies will be static"]
    this.fightIndex = m.settings.fight
    this.rewFFModes = ["Change Level", "Change Health", "Change Time", "(disabled)"]
    this.rewFFHelp  = ["Advance or return game levels", "Increase or decrease Prince health", "Add or subtract 1 minute", "Cheat Keys disabled"]
    this.rewFFIndex = m.settings.rewFF
    this.okModes    = ["Show Remaining Time", "Enable Debug Mode"]
    this.okHelp     = ["Show game remaining time", "Turn on/off Debug mode"]
    this.okIndex    = m.settings.okMode
    if m.settings.modId <> invalid
        this.modName = m.mods[m.settings.modId].name
    else
        this.modName = this.modArray[0].name
    end if
    this.modImage = GetModImage(m.settings.modId)
    this.saveMode = m.settings.saveGame
    if this.saveMode
        if m.savedGame <> invalid
            this.saveTitle = SavedGameTitle(m.savedGame)
            this.saveImage = GetModImage(m.savedGame.modId)
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
    listItems = GetMenuItems(this)
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
            if listIndex = 0 'Mods
                if remoteKey = m.code.BUTTON_LEFT_PRESSED
                    this.modIndex--
                    if this.modIndex < 0
                        this.modIndex = this.modArray.Count() - 1
                    end if
                else if remoteKey = m.code.BUTTON_RIGHT_PRESSED
                    this.modIndex++
                    if this.modIndex = this.modArray.Count()
                        this.modIndex = 0
                    end if
                end if
                listItems[listIndex].Title = " Mod: " + this.modArray[this.modIndex].name
                listItems[listIndex].ShortDescriptionLine1 = ModDescription(this.modArray[this.modIndex])
                listItems[listIndex].HDPosterUrl = GetModImage(this.modArray[this.modIndex].id)
                listItems[listIndex].SDPosterUrl = listItems[listIndex].HDPosterUrl
                this.screen.SetItem(listIndex, listItems[listIndex])
                m.settings.modId = this.modArray[this.modIndex].id
                if this.modArray[this.modIndex].sprites
                    m.settings.spriteMode = val(m.settings.modId)
                else if m.settings.spriteMode <> m.const.SPRITES_MAC
                    m.settings.spriteMode = m.const.SPRITES_DOS
                end if
            else if listIndex = 1 'Fight Mode
                if remoteKey = m.code.BUTTON_LEFT_PRESSED
                    this.fightIndex--
                    if this.fightIndex < 0
                        this.fightIndex = this.fightModes.Count() - 1
                    end if
                else if remoteKey = m.code.BUTTON_RIGHT_PRESSED
                    this.fightIndex++
                    if this.fightIndex = this.fightModes.Count()
                        this.fightIndex = 0
                    end if
                end if
                listItems[listIndex].Title = " Fight Mode: " + this.fightModes[this.fightIndex]
                listItems[listIndex].ShortDescriptionLine1 = this.fightHelp[this.fightIndex]
                listItems[listIndex].HDPosterUrl = "pkg:/images/fight_" + this.fightIndex.toStr() + ".jpg"
                listItems[listIndex].SDPosterUrl = listItems[listIndex].HDPosterUrl
                this.screen.SetItem(listIndex, listItems[listIndex])
                m.settings.fight = this.fightIndex
            else if listIndex = 2 'Rew and FF
                if remoteKey = m.code.BUTTON_LEFT_PRESSED
                    this.rewFFIndex--
                    if this.rewFFIndex < 0
                        this.rewFFIndex = this.rewFFModes.Count() - 1
                    end if
                else if remoteKey = m.code.BUTTON_RIGHT_PRESSED
                    this.rewFFIndex++
                    if this.rewFFIndex = this.rewFFModes.Count()
                        this.rewFFIndex = 0
                    end if
                end if
                listItems[listIndex].Title =" REW & FF keys: " + this.rewFFModes[this.rewFFIndex]
                listItems[listIndex].ShortDescriptionLine1 = this.rewFFHelp[this.rewFFIndex]
                listItems[listIndex].HDPosterUrl = "pkg:/images/rewff_" + this.rewFFIndex.toStr() + ".jpg"
                listItems[listIndex].SDPosterUrl = listItems[listIndex].HDPosterUrl
                this.screen.SetItem(listIndex, listItems[listIndex])
                m.settings.rewFF = this.rewFFIndex
            else if listIndex = 3 'OK Key Mode
                if remoteKey = m.code.BUTTON_LEFT_PRESSED
                    this.okIndex--
                    if this.okIndex < 0
                        this.okIndex = this.okModes.Count() - 1
                    end if
                else if remoteKey = m.code.BUTTON_RIGHT_PRESSED
                    this.okIndex++
                    if this.okIndex = this.okModes.Count()
                        this.okIndex = 0
                    end if
                end if
                listItems[listIndex].Title = " OK Key: " + this.okModes[this.okIndex]
                listItems[listIndex].ShortDescriptionLine1 = this.okHelp[this.okIndex]
                listItems[listIndex].HDPosterUrl = "pkg:/images/okmode_" + this.okIndex.toStr() + ".jpg"
                listItems[listIndex].SDPosterUrl = listItems[listIndex].HDPosterUrl
                this.screen.SetItem(listIndex, listItems[listIndex])
                m.settings.okMode = this.okIndex
            else if listIndex = 4 'Save Game
                if remoteKey = m.code.BUTTON_LEFT_PRESSED or remoteKey = m.code.BUTTON_RIGHT_PRESSED
                    this.saveMode = not this.saveMode
                    m.settings.saveGame = this.saveMode
                end if
                if this.saveMode
                    if m.savedGame <> invalid
                        this.saveTitle = SavedGameTitle(m.savedGame)
                        this.saveImage = GetModImage(m.savedGame.modId)
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
                listItems[listIndex].Title = " Saved Game: " + this.saveTitle
                listItems[listIndex].ShortDescriptionLine1 = this.saveDesc
                listItems[listIndex].HDPosterUrl = this.saveImage
                listItems[listIndex].SDPosterUrl = this.saveImage
                this.screen.SetItem(listIndex, listItems[listIndex])
            end if
            if remoteKey = m.code.BUTTON_LEFT_PRESSED or remoteKey = m.code.BUTTON_RIGHT_PRESSED
                m.sounds.navSingle.Trigger(50)
                SaveSettings(m.settings)
            end if
        end if
    end while
End Sub

Function GetMenuItems(menu as object)
    listItems = []
    listItems.Push({
                Title: " Mod: " + menu.modName
                HDSmallIconUrl: "pkg:/images/icon_arrows.png"
                SDSmallIconUrl: "pkg:/images/icon_arrows.png"
                HDPosterUrl: menu.modImage
                SDPosterUrl: menu.modImage
                ShortDescriptionLine1: ModDescription(menu.modArray[menu.modIndex])
                ShortDescriptionLine2: "Use Left and Right to select a Mod"
                })
    listItems.Push({
                Title: " Fight Mode: " + menu.fightModes[menu.fightIndex]
                HDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
                SDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
                HDPosterUrl: "pkg:/images/fight_" + menu.fightIndex.toStr() + ".jpg"
                SDPosterUrl: "pkg:/images/fight_" + menu.fightIndex.toStr() + ".jpg"
                ShortDescriptionLine1: menu.fightHelp[menu.fightIndex]
                ShortDescriptionLine2: "Use Left and Right to select a Fight Mode"
                })
    listItems.Push({
                Title: " REW & FF Keys: " + menu.rewFFModes[menu.rewFFIndex]
                HDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
                SDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
                HDPosterUrl: "pkg:/images/rewff_" + menu.rewFFIndex.toStr() + ".jpg"
                SDPosterUrl: "pkg:/images/rewff_" + menu.rewFFIndex.toStr() + ".jpg"
                ShortDescriptionLine1: menu.rewFFHelp[menu.rewFFIndex]
                ShortDescriptionLine2: "Use Left and Right to set cheat keys mode"
                })
    listItems.Push({
                Title: " OK Key: " + menu.okModes[menu.okIndex]
                HDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
                SDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
                HDPosterUrl: "pkg:/images/okmode_" + menu.okIndex.toStr() + ".jpg",
                SDPosterUrl: "pkg:/images/okmode_" + menu.okIndex.toStr() + ".jpg",
                ShortDescriptionLine1: menu.okHelp[menu.okIndex]
                ShortDescriptionLine2: "Use Left and Right to set OK key mode"
                })
    listItems.Push({
                Title: " Saved Game: " + menu.saveTitle
                HDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
                SDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
                HDPosterUrl: menu.saveImage,
                SDPosterUrl: menu.saveImage,
                ShortDescriptionLine1: menu.saveDesc,
                ShortDescriptionLine2: "Use Left and Right to enable/disable save"
                })
    return listItems
End Function

Function ModDescription(modAA as object) as string
    if modAA.author = "" then return "Original Game Levels"
    modAuthor = "Author: " + modAA.author + chr(10)
    modFeatures = ""
    if modAA.levels then modFeatures = "Levels"
    if modAA.sprites
        if modFeatures <> ""
            modFeatures = modFeatures + ", "
        end if
        modFeatures = modFeatures + "Sprites"
    end if
    if modAA.sounds
        if modFeatures <> ""
            modFeatures = modFeatures + ", "
        end if
        modFeatures = modFeatures + "Sounds"
    end if
    return modAuthor + modFeatures
End Function

Function SavedGameTitle(game as object) as string
    return "Level " + game.level.toStr() + " at "  + CInt(game.time / 60).toStr() + "min"
End Function
