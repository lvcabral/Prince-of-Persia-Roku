' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: July 2016
' **  Updated: August 2016
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function LoadMods() as object
    'Load internal Mods
    mods = ParseJson(ReadAsciiFile("pkg:/mods/mods.json"))
    'Uncomment and edit the line below to add the URL if you are hosting remote mods
    'm.webMods = "http://YOURDOMAIN/MODSFOLDER/"
    'Load remote Mods (if available)
    if m.webMods <> invalid and CacheFile(m.webMods + "mods.json", "mods.json") <> ""
        modsWeb = ParseJson(ReadAsciiFile("tmp:/mods.json"))
        if modsWeb <> invalid then mods.Append(modsWeb)
    end if
    return mods
End Function

Sub DownloadMod(mod as object)
    'Clear screen
    m.mainScreen.Clear(0)
    m.mainScreen.SwapBuffers()
    m.mainScreen.Clear(0)
    'Set mods remote URL
    modUrl = m.webMods + mod.path
    if not m.files.Exists("tmp:/" + mod.path) then m.files.CreateDirectory("tmp:/" + mod.path)
    if mod.levels
        TextBox(m.mainScreen, 620, 50, "Loading " + mod.name + " levels...")
        for l = 1 to 11
            file = "level" + itostr(l) + ".xml"
            CacheFile(modUrl + "levels/" + file, mod.path + file)
        next
        CacheFile(modUrl + "levels/level12a.xml", mod.path + "level12a.xml")
        CacheFile(modUrl + "levels/level12b.xml", mod.path + "level12b.xml")
        CacheFile(modUrl + "levels/princess.xml", mod.path + "princess.xml")
    end if
    if mod.titles
        TextBox(m.mainScreen, 620, 50, "Loading " + mod.name + " titles...")
        CacheFile(modUrl + "titles/intro-screen.png", mod.path + "intro-screen.png")
        CacheFile(modUrl + "titles/message-author.png", mod.path + "message-author.png")
        CacheFile(modUrl + "titles/message-game-name.png", mod.path + "message-game-name.png")
        CacheFile(modUrl + "titles/message-port.png", mod.path + "message-port.png")
        CacheFile(modUrl + "titles/message-presents.png", mod.path + "message-presents.png")
        CacheFile(modUrl + "titles/text-in-the-absence.png", mod.path + "text-in-the-absence.png")
        CacheFile(modUrl + "titles/text-marry-jaffar.png", mod.path + "text-marry-jaffar.png")
        CacheFile(modUrl + "titles/text-screen.png", mod.path + "text-screen.png")
        CacheFile(modUrl + "titles/text-the-tyrant.png", mod.path + "text-the-tyrant.png")
    end if
    if mod.palettes then CacheFile(modUrl + "palettes/wall.pal", mod.path + "wall.pal")
    if mod.sprites and mod.files <> invalid and mod.files.sprites <> invalid
        TextBox(m.mainScreen, 620, 50, "Loading " + mod.name + " sprites...")
        for each file in mod.files.sprites
            if file = "guards"
                CacheFile(modUrl + "sprites/guard.json", mod.path + "guard.json")
                for g = 1 to 7
                    guard = "guard" + itostr(g)
                    CacheFile(modUrl + "sprites/" + guard + ".png", mod.path + guard + ".png")
                next
            else
                CacheFile(modUrl + "sprites/" + file + ".json", mod.path + file + ".json", true)
                CacheFile(modUrl + "sprites/" + file + ".png", mod.path + file + ".png", true)
            end if
        next
    end if
    if mod.sounds and mod.files <> invalid and mod.files.sounds <> invalid
        TextBox(m.mainScreen, 620, 50, "Loading " + mod.name + " sounds...")
        for each file in mod.files.sounds
            CacheFile(modUrl + "sounds/" + file + ".wav", mod.path + file + ".wav", true)
        next
    end if
End Sub

Function GetModImage(modId as dynamic) as string
    cloud = false
    modImage = "pkg:/assets/titles/intro-screen-dos.png"
    modCover = "tmp:/0000001.png"
    if modId <> invalid
        mod = m.mods[modId]
        if Left(mod.url,3) = "pkg"
            modImage = mod.url + mod.path + modId + "_1.png"
        else
            modImage = CacheFile(m.webMods + mod.path + modId + "_1.png", modId + "_1.png")
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
        if cloud then bmp.DrawObject(312, 192, CreateObject("roBitmap", "pkg:/images/icon_cloud.png"))
        bmp.Finish()
        png = bmp.GetPng(0, 0, 360, 240)
        png.WriteFile(modCover)
    end if
    return modCover
End Function

Sub ModsAndCheatsScreen()
    this = {
            screen: CreateObject("roListScreen")
            port: CreateObject("roMessagePort")
           }
    this.screen.SetMessagePort(this.port)
    this.screen.SetHeader("Mods and Cheats")
    this.modArray = [{name: "(none)", author:"", levels: false, sprites: false, sounds: false}]
    this.modIndex = 0
    for each mod in m.mods.Keys()
        if mod = m.settings.modId then this.modIndex = this.modArray.Count()
        m.mods[mod].id = mod
        this.modArray.Push(m.mods[mod])
    next
    this.fightModes = ["Attack", "Alert", "Frozen"]
    this.fightHelp  = ["Enemies will attack you!", "Enemies will be alert and follow you", "Enemies will be static"]
    this.fightIndex = m.settings.fight
    this.rewFFModes = ["Game Level", "Kid's Health", "Remaining Time"]
    this.rewFFHelp  = ["Keys advance or return levels", "Keys increase or decrease health", "Keys increase or decrease 1 minute"]
    this.rewFFIndex = m.settings.rewFF
    this.okModes    = ["Remaining Time", "Debug Mode"]
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
    while true
        msg = wait(0,this.port)
        if msg.isScreenClosed() then exit while
        if type(msg) = "roListScreenEvent"
            if msg.isListItemFocused()
                listIndex = msg.GetIndex()
                if listIndex < listItems.Count() - 1
                    this.newIcon = "pkg:/images/icon_arrows.png"
                else
                    this.newIcon = "pkg:/images/icon_save.png"
                end if
                if this.oldIcon <> invalid
                    listItems[oldIndex].HDSmallIconUrl = this.oldIcon
                    listItems[oldIndex].SDSmallIconUrl = this.oldIcon
                    this.screen.SetItem(oldIndex, listItems[oldIndex])
                end if
                listItems[listIndex].HDSmallIconUrl = this.newIcon
                listItems[listIndex].SDSmallIconUrl = this.newIcon
                this.screen.SetItem(listIndex, listItems[listIndex])
                oldIndex = listIndex
                if listIndex < listItems.Count() - 1
                    this.oldIcon = "pkg:/images/icon_arrows_bw.png"
                else
                    this.oldIcon = "pkg:/images/icon_save_bw.png"
                end if
            else if msg.isListItemSelected()
                index = msg.GetIndex()
                if index = listItems.Count() - 1 'Save
                    m.settings.modId = this.modArray[this.modIndex].id
                    m.settings.fight = this.fightIndex
                    m.settings.rewFF = this.rewFFIndex
                    m.settings.saveGame = this.saveMode
                    m.settings.okMode = this.okIndex
                    if this.modArray[this.modIndex].sprites
                        m.settings.spriteMode = val(m.settings.modId)
                    else if m.settings.spriteMode <> m.const.SPRITES_MAC
                        m.settings.spriteMode = m.const.SPRITES_DOS
                    end if
                    SaveSettings(m.settings)
                    MessageDialog("Prince of Persia", "Your selections are saved!", this.port)
                end if
            else if msg.isRemoteKeyPressed()
                remoteKey = msg.GetIndex()
                if listIndex = 0 'Mods
                    if remoteKey = m.code.BUTTON_LEFT_PRESSED
                        this.modIndex = this.modIndex - 1
                        if this.modIndex < 0 then this.modIndex = this.modArray.Count() - 1
                    else if remoteKey = m.code.BUTTON_RIGHT_PRESSED
                        this.modIndex = this.modIndex + 1
                        if this.modIndex = this.modArray.Count() then this.modIndex = 0
                    end if
                    saveIndex = listItems.Count() - 1
                    listItems[listIndex].Title = "  Mod: " + this.modArray[this.modIndex].name
                    listItems[listIndex].ShortDescriptionLine1 = ModDescription(this.modArray[this.modIndex])
                    listItems[listIndex].HDPosterUrl = GetModImage(this.modArray[this.modIndex].id)
                    listItems[saveIndex].HDPosterUrl = GetModImage(this.modArray[this.modIndex].id)
                    listItems[listIndex].SDPosterUrl = listItems[listIndex].HDPosterUrl
                    listItems[saveIndex].SDPosterUrl = listItems[listIndex].HDPosterUrl
                    this.screen.SetItem(listIndex, listItems[listIndex])
                    this.screen.SetItem(saveIndex, listItems[saveIndex])
                else if listIndex = 1 'Fight Mode
                    if remoteKey = m.code.BUTTON_LEFT_PRESSED
                        this.fightIndex = this.fightIndex - 1
                        if this.fightIndex < 0 then this.fightIndex = this.fightModes.Count() - 1
                    else if remoteKey = m.code.BUTTON_RIGHT_PRESSED
                        this.fightIndex = this.fightIndex + 1
                        if this.fightIndex = this.fightModes.Count() then this.fightIndex = 0
                    end if
                    listItems[listIndex].Title = "  Fight Mode: " + this.fightModes[this.fightIndex]
                    listItems[listIndex].ShortDescriptionLine1 = this.fightHelp[this.fightIndex]
                    listItems[listIndex].HDPosterUrl = "pkg:/images/fight_" + itostr(this.fightIndex) + ".jpg"
                    listItems[listIndex].SDPosterUrl = listItems[listIndex].HDPosterUrl
                    this.screen.SetItem(listIndex, listItems[listIndex])
                else if listIndex = 2 'Rew and FF
                    if remoteKey = m.code.BUTTON_LEFT_PRESSED
                        this.rewFFIndex = this.rewFFIndex - 1
                        if this.rewFFIndex < 0 then this.rewFFIndex = this.rewFFModes.Count() - 1
                    else if remoteKey = m.code.BUTTON_RIGHT_PRESSED
                        this.rewFFIndex = this.rewFFIndex + 1
                        if this.rewFFIndex = this.rewFFModes.Count() then this.rewFFIndex = 0
                    end if
                    listItems[listIndex].Title ="  REW & FF keys: " + this.rewFFModes[this.rewFFIndex]
                    listItems[listIndex].ShortDescriptionLine1 = this.rewFFHelp[this.rewFFIndex]
                    listItems[listIndex].HDPosterUrl = "pkg:/images/rewff_" + itostr(this.rewFFIndex) + ".jpg"
                    listItems[listIndex].SDPosterUrl = listItems[listIndex].HDPosterUrl
                    this.screen.SetItem(listIndex, listItems[listIndex])
                else if listIndex = 3 'OK Key Mode
                    if remoteKey = m.code.BUTTON_LEFT_PRESSED
                        this.okIndex = this.okIndex - 1
                        if this.okIndex < 0 then this.okIndex = this.okModes.Count() - 1
                    else if remoteKey = m.code.BUTTON_RIGHT_PRESSED
                        this.okIndex = this.okIndex + 1
                        if this.okIndex = this.okModes.Count() then this.okIndex = 0
                    end if
                    listItems[listIndex].Title = "  OK Key: " + this.okModes[this.okIndex]
                    listItems[listIndex].ShortDescriptionLine1 = this.okHelp[this.okIndex]
                    listItems[listIndex].HDPosterUrl = "pkg:/images/okmode_" + itostr(this.okIndex) + ".jpg"
                    listItems[listIndex].SDPosterUrl = listItems[listIndex].HDPosterUrl
                    this.screen.SetItem(listIndex, listItems[listIndex])
                else if listIndex = 4 'Save Game
                    if remoteKey = m.code.BUTTON_LEFT_PRESSED or remoteKey = m.code.BUTTON_RIGHT_PRESSED
                        this.saveMode = not this.saveMode
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
                    listItems[listIndex].Title = "  Saved Game: " + this.saveTitle
                    listItems[listIndex].ShortDescriptionLine1 = this.saveDesc
                    listItems[listIndex].HDPosterUrl = this.saveImage
                    listItems[listIndex].SDPosterUrl = this.saveImage
                    this.screen.SetItem(listIndex, listItems[listIndex])
                end if
                m.sounds.navSingle.Trigger(50)
            end if
        end if
    end while
    return
End Sub

Function GetMenuItems(menu as object)
    listItems = []
    listItems.Push({
                Title: "  Mod: " + menu.modName
                HDSmallIconUrl: "pkg:/images/icon_arrows.png"
                SDSmallIconUrl: "pkg:/images/icon_arrows.png"
                HDPosterUrl: menu.modImage
                SDPosterUrl: menu.modImage
                ShortDescriptionLine1: ModDescription(menu.modArray[menu.modIndex])
                ShortDescriptionLine2: "Use Left and Right to select a Mod"
                })
    listItems.Push({
                Title: "  Fight Mode: " + menu.fightModes[menu.fightIndex]
                HDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
                SDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
                HDPosterUrl: "pkg:/images/fight_" + itostr(menu.fightIndex) + ".jpg"
                SDPosterUrl: "pkg:/images/fight_" + itostr(menu.fightIndex) + ".jpg"
                ShortDescriptionLine1: menu.fightHelp[menu.fightIndex]
                ShortDescriptionLine2: "Use Left and Right to select a Fight Mode"
                })
    listItems.Push({
                Title: "  REW & FF Keys: " + menu.rewFFModes[menu.rewFFIndex]
                HDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
                SDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
                HDPosterUrl: "pkg:/images/rewff_" + itostr(menu.rewFFIndex) + ".jpg"
                SDPosterUrl: "pkg:/images/rewff_" + itostr(menu.rewFFIndex) + ".jpg"
                ShortDescriptionLine1: menu.rewFFHelp[menu.rewFFIndex]
                ShortDescriptionLine2: "Use Left and Right to set arrow keys mode"
                })
    listItems.Push({
                Title: "  OK Key: " + menu.okModes[menu.okIndex]
                HDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
                SDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
                HDPosterUrl: "pkg:/images/okmode_" + itostr(menu.okIndex) + ".jpg",
                SDPosterUrl: "pkg:/images/okmode_" + itostr(menu.okIndex) + ".jpg",
                ShortDescriptionLine1: menu.okHelp[menu.okIndex]
                ShortDescriptionLine2: "Use Left and Right to set OK key mode"
                })
    listItems.Push({
                Title: "  Saved Game: " + menu.saveTitle
                HDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
                SDSmallIconUrl: "pkg:/images/icon_arrows_bw.png"
                HDPosterUrl: menu.saveImage,
                SDPosterUrl: menu.saveImage,
                ShortDescriptionLine1: menu.saveDesc,
                ShortDescriptionLine2: "Use Left and Right to enable/disable save"
                })
    listItems.Push({
                Title: "  Save Selections!"
                HDSmallIconUrl: "pkg:/images/icon_save_bw.png"
                SDSmallIconUrl: "pkg:/images/icon_save_bw.png"
                HDPosterUrl: menu.modImage
                SDPosterUrl: menu.modImage
                ShortDescriptionLine1: "Using cheats (fight mode or keys)" + chr(10) + "disables highscore record"
                ShortDescriptionLine2: "Press OK to save"
                })
    return listItems
End Function

Function ModDescription(mod as object) as string
    if mod.author = "" then return "Original Game Levels"
    modAuthor = "Author: " + mod.author + chr(10)
    modFeatures = ""
    if mod.levels then modFeatures = "Levels"
    if mod.sprites then
        if modFeatures <> "" then modFeatures = modFeatures + ", "
        modFeatures = modFeatures + "Sprites"
    end if
    if mod.sounds then
        if modFeatures <> "" then modFeatures = modFeatures + ", "
        modFeatures = modFeatures + "Sounds"
    end if
    return modAuthor + modFeatures
End Function

Function SavedGameTitle(game as object) as string
    return "Level: " + itostr(game.level) + "  Time: "  + itostr(CInt(game.time / 60)) + "min"
End Function
