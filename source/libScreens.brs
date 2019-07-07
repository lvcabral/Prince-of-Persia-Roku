' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  libCanvas.brs - Library with generic methods for Screen objects
' **  Created: June 2018
' **  Updated: July 2019
' **
' **  Copyright (C) Marcelo Lv Cabral < https://lvcabral.com >
' ********************************************************************************************************
' ********************************************************************************************************

'-----
' Generic Methods

Sub close_screen()
    m.visible = false
    m.canvas.Close()
End Sub

Sub set_list_style(style as string)
    m.listStyle = style
End Sub

Sub set_display_mode(mode as string)
    m.displayMode = mode
End Sub

Sub set_breadcrumb_text(leftText as string, rightText as string)
    font = m.canvas.fonts.large
    wl = font.GetOneLineWidth(leftText, 500)
    wr = font.GetOneLineWidth(rightText, 500)
    xr = 1228 - wr
    xb = xr - 22
    xl = xr - wl - 28
    m.breadCrumb = []
    m.breadCrumb.Push({ Text: leftText
                        TextAttrs: {color: m.theme.BreadcrumbTextLeft, font: font, HAlign: "Left"}
                        TargetRect: {x:xl, y:72, w:wl, h:24}})
    m.breadCrumb.Push({ Text: "•"
                        TextAttrs: {color: m.theme.BreadcrumbDelimiter, font: font, HAlign: "Left"}
                        TargetRect: {x:xb, y:72, w:20, h:24}})
    m.breadCrumb.Push({ Text: rightText
                        TextAttrs: {color: m.theme.BreadcrumbTextRight, font: font, HAlign: "Left"}
                        TargetRect: {x:xr, y:72, w:wr, h:24}})   
End Sub

Sub set_focused_item(index as integer)
    m.focus = index
    if m.visible then m.Show()
End Sub

Sub set_content_item(index as integer, item as object, refresh = true as boolean)
    bmp = CreateObject("roBitmap",{width:250, height:250, alphaenable:true})
    pst = ScaleToSize(CreateObject("roBitmap", item.HDPosterUrl), 250, 250)
    if pst <> invalid
        if pst.GetWidth() < 250 then offX = (250 - pst.GetWidth()) / 2 else offX = 0
        if pst.GetHeight() < 250 then offY = (250 - pst.GetHeight()) / 2 else offY = 0
        bmp.DrawObject(offX, offY, pst)
    else
        print "invalid content image:"; item.HDPosterUrl
    end if
    AddToCache(item.HDPosterUrl + "250x250", bmp)
    m.content[index] = item
    if m.visible and refresh then m.Show()
End Sub

Function get_content_list() as object
    return m.content
End Function

'------ 
' Generic Functions

Function GetOverhang()
    theme = m.theme
    overhang = []
    overhang.Push({ Color: "#000000FF", CompositionMode: "Source", url: theme.OverhangSliceHD})
    if theme.OverhangLogoHD <> invalid
        overhang.Push({ url: theme.OverhangLogoHD, TargetRect: {x: int(val(theme.OverhangOffsetHD_X)), y: int(val(theme.OverhangOffsetHD_Y))} })
    end if
    return overhang
End Function

Function GetScreenMessage(index as integer, event as string)
    this = {index: index, event: event}
    this.isListItemFocused = function() as boolean
        return (m.event = "focused")
    end function
    this.isListItemSelected = function() as boolean
        return (m.event = "selected")
    end function
    this.isScreenClosed = function() as boolean
        return (m.event = "closed")
    end function
    this.isRemoteKeyPressed = function() as boolean
        return (m.event = "remote")
    end function
    this.isButtonPressed = function() as boolean
        return (m.event = "button")
    end function
    this.GetIndex = function() as integer
        return m.index
    end function
    return this
End Function

Sub InitCache()
    g = GetGlobalAA()
    if g.files = invalid then g.files = CreateObject("roFileSystem")
    if g.cache = invalid 
        g.cache = {}
        g.cacheId = 0
    end if
End Sub

Function AddToCache(fileName as string, bmp as object) as string
    g = GetGlobalAA()
    tmpFile = g.cache.Lookup(fileName)
    if tmpFile = invalid
        g.cacheId++
        tmpFile = "tmp:/cached" + g.cacheId.toStr() + ".png"
        g.cache.AddReplace(fileName,tmpFile)
    end if
    if not g.files.Exists(tmpFile)
        png = bmp.GetPng(0, 0, bmp.GetWidth(), bmp.GetHeight())
        png.WriteFile(tmpFile)
    end if
    return tmpFile
End Function

Function CachedFile(fileName as string) as string
    g = GetGlobalAA()
    tmpFile = g.cache.Lookup(fileName)
    if tmpFile = invalid then tmpFile = ""
    return tmpFile
End Function