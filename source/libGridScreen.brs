' ********************************************************************************************************
' ********************************************************************************************************
' **  Prince of Persia for Roku - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  libGridScreen.brs - Library to implement generic Grid Screen
' **  Created: June 2018
' **  Updated: January 2024
' **
' **  Copyright (C) Marcelo Lv Cabral < https://lvcabral.com >
' ********************************************************************************************************
' ********************************************************************************************************

function CreateGridScreen(ignoreBackKey = false as boolean) as object
    ' Objects
    this = { content: [], canvas: CreateCanvas() }
    this.screen = this.canvas.screen
    this.codes = m.code
    this.sounds = m.sounds
    this.theme = m.theme

    ' Properties
    this.breadCrumb = []
    this.listName = ""
    this.listCount = ""
    this.message = ""
    this.focus = 0
    this.visible = false
    this.columns = 4
    if IsHD()
        this.rows = 3
    else
        this.rows = 4
    end if
    this.x = 100
    this.y = 180
    this.xOff = 20
    this.yOff = 12
    this.focusOffset = 10
    this.ignoreBackKey = ignoreBackKey

    ' Methods
    this.SetMessagePort = set_msg_port
    this.SetBreadcrumbText = set_breadcrumb_text
    this.SetListName = set_list_name
    this.SetListCount = set_list_count
    this.SetContentList = set_grid_content
    this.SetContentItem = set_grid_item
    this.GetContentList = get_content_list
    this.SetFocusedListItem = set_focused_item
    this.ShowMessage = show_message
    this.Show = show_grid_screen
    this.Wait = wait_grid_screen
    this.Close = close_screen

    ' Initialize Canvas
    this.canvas.SetLayer(0, GetOverhang())

    return this
end function

sub show_grid_screen()
    thumbs = { w: 256, h: 160 }
    txtArray = []
    imgArray = []
    txtArray.Append(m.breadCrumb)
    if m.content.Count() > 0
        menuPos = { x: m.x, y: m.y }
        txtArray.Push({
            Text: m.listName
            TextAttrs: { color: m.theme.ListScreenDescriptionText, font: "Mini", HAlign: "Left" }
            TargetRect: { x: menuPos.x, y: menuPos.y - 36, w: (thumbs.w * m.columns) + (m.xOff * (m.columns - 1)), h: 60 } })
        txtArray.Push({
            Text: m.listCount
            TextAttrs: { color: m.theme.ListScreenDescriptionText, font: "Mini", HAlign: "Right" }
            TargetRect: { x: menuPos.x, y: menuPos.y - 36, w: (thumbs.w * m.columns) + (m.xOff * (m.columns - 1)), h: 60 } })
        items = Min(m.first + (m.columns * (m.rows + 1) - 1), m.content.Count() - 1)
        rows = 0
        for i = m.first to items
            if menuPos.x = m.x
                rows++
            end if
            if m.content[i] <> invalid
                imgArray.Push({
                    url: m.content[i].HDPosterUrl
                    TargetRect: { x: menuPos.x, y: menuPos.y } })
            end if
            if m.focus = i
                imgArray.Push({
                    url: "pkg:/images/grid-focus.png"
                    TargetRect: { x: menuPos.x - m.focusOffset, y: menuPos.y - m.focusOffset } })
            end if
            menuPos.x += thumbs.w + m.xOff
            if i > 0 and (i + 1) mod m.columns = 0
                menuPos.x = m.x
                menuPos.y += thumbs.h + m.yOff
            end if
        next
    else if m.message <> ""
        txtArray.Push({
            Text: m.message
            TextAttrs: { color: m.theme.ListScreenDescriptionText, font: "Medium", HAlign: "Center" }
            TargetRect: { x: m.x, y: (m.canvas.screen.getHeight() - m.y) / 2 + m.y, w: m.canvas.screen.getWidth() - m.x * 2, h: 60 } })
    end if
    m.canvas.SetLayer(1, imgArray)
    m.canvas.SetLayer(2, txtArray)
    m.canvas.Show()
    m.visible = true
end sub

sub set_grid_content(list as object)
    m.content = list
    m.first = 0
    if m.visible then m.Show()
end sub

sub set_grid_item(index as integer, item as object)
    m.content[index] = item
    if m.visible and index >= m.first and index < m.first + m.columns * m.rows
        m.Show()
    end if
end sub

function wait_grid_screen(timeout = 0, port = invalid) as object
    if port = invalid then port = m.canvas.screen.getMessagePort()
    msg = invalid
    event = wait(timeout, port)
    if type(event) = "roUniversalControlEvent"
        index = event.GetInt()
        if index = m.codes.BUTTON_LEFT_PRESSED
            if m.content.Count() > 0
                if m.focus mod m.columns = 0
                    m.focus = Min(m.focus + (m.columns - 1), m.content.Count() - 1)
                    m.sounds.roll.Trigger(50)
                else
                    m.focus--
                    m.sounds.navSingle.Trigger(50)
                end if
                if m.visible then m.Show()
                msg = GetScreenMessage(m.focus, "focused")
            end if
        else if index = m.codes.BUTTON_RIGHT_PRESSED
            if m.content.Count() > 0
                m.focus++
                if m.focus mod m.columns = 0
                    m.focus -= m.columns
                    m.sounds.roll.Trigger(50)
                else if m.focus = m.content.Count()
                    m.focus--
                    m.sounds.deadend.Trigger(50)
                else
                    m.sounds.navSingle.Trigger(50)
                end if
                if m.visible then m.Show()
                msg = GetScreenMessage(m.focus, "focused")
            end if
        else if index = m.codes.BUTTON_UP_PRESSED
            if m.content.Count() > 0
                m.focus -= m.columns
                if m.focus < 0
                    m.focus += m.columns
                    m.sounds.deadend.Trigger(50)
                else
                    if m.focus < m.first
                        m.first -= m.columns
                    end if
                    m.sounds.navSingle.Trigger(50)
                end if
                if m.visible then m.Show()
                msg = GetScreenMessage(m.focus, "focused")
            end if
        else if index = m.codes.BUTTON_DOWN_PRESSED
            if m.content.Count() > 0
                m.focus += m.columns
                if m.focus > m.content.Count() - 1
                    m.focus -= m.columns
                    m.sounds.deadend.Trigger(50)
                else
                    if m.focus > m.first + (m.columns * m.rows - 1)
                        m.first += m.columns
                    end if
                    m.sounds.navSingle.Trigger(50)
                end if
                if m.visible then m.Show()
                msg = GetScreenMessage(m.focus, "focused")
            end if
        else if index = m.codes.BUTTON_BACK_PRESSED and not m.ignoreBackKey
            m.sounds.navSingle.Trigger(50)
            msg = GetScreenMessage(m.focus, "closed")
            m.Close()
        else if index = m.codes.BUTTON_SELECT_PRESSED
            m.sounds.select.Trigger(50)
            msg = GetScreenMessage(m.focus, "selected")
        else if index = m.codes.BUTTON_UP_PRESSED or index = m.codes.BUTTON_DOWN_PRESSED
            m.sounds.dead.Trigger(50)
        end if
    end if
    return msg
end function

sub set_list_name(name as string)
    m.listName = name
    if m.visible then m.Show()
end sub

sub set_list_count(value as string)
    m.listCount = value
    if m.visible then m.Show()
end sub

sub show_message(message as string)
    m.message = message
    if m.visible then m.Show()
end sub

function Min(a, b)
    if a < b then return a else return b
end function
