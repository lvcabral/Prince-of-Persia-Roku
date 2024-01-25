' ********************************************************************************************************
' ********************************************************************************************************
' **  Prince of Persia for Roku - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  libCanvas.brs - Library with generic methods for Screen objects
' **  Created: June 2018
' **  Updated: February 2024
' **
' **  Copyright (C) Marcelo Lv Cabral < https://lvcabral.com >
' ********************************************************************************************************
' ********************************************************************************************************

'-----
' Generic Methods

sub close_screen()
    m.visible = false
    m.canvas.Close()
end sub

sub set_list_style(style as string)
    m.listStyle = style
end sub

sub set_display_mode(mode as string)
    m.displayMode = mode
end sub

sub set_breadcrumb_text(leftText as string, rightText as string)
    font = m.canvas.fonts.large
    wl = font.GetOneLineWidth(leftText, 500)
    wr = font.GetOneLineWidth(rightText, 500)
    xr = 1228 - wr
    xb = xr - 22
    xl = xr - wl - 28
    m.breadCrumb = []
    m.breadCrumb.Push({ Text: leftText
        TextAttrs: { color: m.theme.BreadcrumbTextLeft, font: font, HAlign: "Left" }
        TargetRect: { x: xl, y: 72, w: wl, h: 30 } })
    m.breadCrumb.Push({ Text: "•"
        TextAttrs: { color: m.theme.BreadcrumbDelimiter, font: font, HAlign: "Left" }
        TargetRect: { x: xb, y: 72, w: 20, h: 30 } })
    m.breadCrumb.Push({ Text: rightText
        TextAttrs: { color: m.theme.BreadcrumbTextRight, font: font, HAlign: "Left" }
        TargetRect: { x: xr, y: 72, w: wr, h: 30 } })
end sub

sub set_title(title as string)
    m.title = title
end sub

sub set_text(text as string)
    m.text = text
end sub

sub set_focused_item(index as integer)
    m.focus = index
    if m.visible then m.Show()
end sub

function get_text() as string
    return m.text
end function

function get_content_list() as object
    return m.content
end function

sub add_button(id as integer, text as string)
    m.buttons.Push({ id: id, text: text })
end sub

'------
' Generic Functions

function GetOverhang()
    theme = m.theme
    overhang = []
    overhang.Push({ Color: "#000000FF", CompositionMode: "Source", url: theme.OverhangSliceHD })
    if theme.OverhangLogoHD <> invalid
        overhang.Push({ url: theme.OverhangLogoHD, TargetRect: { x: int(val(theme.OverhangOffsetHD_X)), y: int(val(theme.OverhangOffsetHD_Y)) } })
    end if
    return overhang
end function

function GetScreenMessage(index as integer, event as string)
    this = { index: index, event: event }
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
end function

sub InitCache()
    g = GetGlobalAA()
    if g.files = invalid then g.files = CreateObject("roFileSystem")
    if g.cache = invalid
        g.cache = {}
        g.cacheId = 0
    end if
end sub

function AddToCache(fileName as string, bmp as object, update = false as boolean) as string
    g = GetGlobalAA()
    tmpFile = g.cache[fileName]
    if tmpFile = invalid
        g.cacheId++
        tmpFile = "tmp:/cached" + g.cacheId.toStr() + ".png"
        g.cache.AddReplace(fileName, tmpFile)
    end if
    if update or not g.files.Exists(tmpFile)
        png = bmp.GetPng(0, 0, bmp.GetWidth(), bmp.GetHeight())
        png.WriteFile(tmpFile)
    end if
    return tmpFile
end function

function CachedFile(fileName as string) as string
    g = GetGlobalAA()
    tmpFile = g.cache[fileName]
    if tmpFile = invalid then tmpFile = ""
    return tmpFile
end function

function CenterImage(url, width as integer, height as integer) as string
    if url = invalid or url = "" then return ""
    if not m.files.Exists(url) then return ""
    por = CreateObject("roBitmap", url)
    if por <> invalid and (por.GetWidth() <> width or por.GetHeight() <> height)
        bmp = CreateObject("roBitmap", { width: width, height: height, alphaenable: true })
        pst = ScaleToSize(por, width, height)
        if pst <> invalid
            if pst.GetWidth() < width then offX = (width - pst.GetWidth()) / 2 else offX = 0
            if pst.GetHeight() < height then offY = (height - pst.GetHeight()) / 2 else offY = 0
            bmp.DrawObject(offX, offY, pst)
        else
            print "invalid image:"; url
        end if
        url = AddToCache(url + "300x300", bmp, true)
    end if
    return url
end function