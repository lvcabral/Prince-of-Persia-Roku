' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  libCanvas.brs - Library to implement generic Canvas object
' **  Created: June 2018
' **  Updated: September 2019
' **
' **  Copyright (C) Marcelo Lv Cabral < https://lvcabral.com >
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateCanvas() as object
    ' Objects
    this = {screen: m.mainScreen, layers:{}, colors: m.colors}
    this.scale = m.mainScreen.GetHeight() / 720
    this.timer = CreateObject("roTimespan")
    ' Methods
    this.SetMessagePort = set_msg_port
    this.GetCanvasRect = get_canvas_rect
    this.SetLayer = set_layer
    this.ClearLayer = clear_layer
    this.Show = show_canvas
    this.Close = close_canvas
    this.Paint = paint_component
    if m.fonts = invalid
        m.fonts = {reg:CreateObject("roFontRegistry")}
    end if
    this.fonts = m.fonts
    ' Canvas Stack 
    if m.stack = invalid
        m.stack = []
        m.fonts.AddReplace("mini", m.fonts.reg.GetDefaultFont(20 * this.scale, false, false))
        m.fonts.AddReplace("small", m.fonts.reg.GetDefaultFont(23 * this.scale, false, false))
        m.fonts.AddReplace("medium", m.fonts.reg.GetDefaultFont(27 * this.scale, false, false))
        m.fonts.AddReplace("large", m.fonts.reg.GetDefaultFont(32 * this.scale, false, false))
        m.fonts.AddReplace("big", m.fonts.reg.GetDefaultFont(40 * this.scale, false, false))
        m.fonts.AddReplace("huge", m.fonts.reg.GetDefaultFont(46 * this.scale, false, false))       
    end if
    this.stackId = m.stack.Count()
    m.stack.Push(this)
    return this
End Function

Function GetTopCanvas() as object
    g = GetGlobalAA()
    return g.stack.Peek()
End Function

Sub set_msg_port(port as object)
    m.screen.SetMessagePort(port)
End Sub

Function get_canvas_rect() as object
    return {x:0, y:0, w:m.screen.GetWidth(), h: m.screen.GetHeight()}
End Function

Sub set_layer(zOrder as integer, layer as object)
    m.layers.AddReplace(zOrder.toStr(), layer)
End Sub

Sub clear_layer(zOrder as integer)
    if m.layers.DoesExist(zOrder.toStr())
        m.layers.Delete(zOrder.toStr())
    end if
End Sub

Sub show_canvas(scope = invalid)
    if scope = invalid
        m.screen.Clear(255)
        scope = m.layers.keys()
    end if
    for each id in scope
        'print "Layer "; id
        m.timer.Mark()
        layer = m.layers[id]
        if type(layer) = "roArray"
            for each component in layer
                m.Paint(component)
            next
        else
            m.Paint(layer)
        end if
        'print "Layer took: "; m.timer.TotalMilliseconds()
    next
    m.screen.SwapBuffers()
End Sub

Sub close_canvas()
    g = GetGlobalAA()
    g.stack.Delete(m.stackId)
    m.layers.Clear()
End Sub

Sub paint_component(component as object)
    rect = component.TargetRect
    if rect = invalid
        rect = m.GetCanvasRect()
    end if
    if component.DoesExist("Text")
        if type(component.TextAttrs.font) = "roString" or type(component.TextAttrs.font) = "String"
            font = m.fonts.Lookup(component.TextAttrs.font)
            if font = invalid 
                font = m.fonts.medium
            end if
        else if type(component.TextAttrs.font) = "roFont"
            font = component.TextAttrs.font
        else
            font = m.fonts.reg.GetDefaultFont()
        end if
        x = rect.x * m.scale
        y = rect.y * m.scale
        if component.text <> invalid
            th = font.GetOneLineHeight()
            lines = component.text.split(chr(10))
            for each line in lines
                tw = font.GetOneLineWidth(line, rect.w * m.scale)
                if component.TextAttrs.DoesExist("HAlign")
                    if LCase(component.TextAttrs.HAlign) = "center"
                        x += CInt((rect.w * m.scale - tw)/2)
                    else if LCase(component.TextAttrs.HAlign) = "right"
                        x += CInt(rect.w * m.scale - tw)
                    end if
                end if
                if component.TextAttrs.color <> invalid
                    color = HexToInt(component.TextAttrs.color)
                else
                    color = m.colors.white
                end if
                m.screen.DrawText(line, x, y, color, font)
                ' Restore X and increment Y
                x = rect.x * m.scale
                y += th
            next
        end if
    else if component.DoesExist("url")
        x = rect.x * m.scale
        y = rect.y * m.scale
        bitmap = CreateObject("roBitmap",component.url)
        if m.scale < 1 and bitmap <> invalid
            bitmap = ScaleBitmap(bitmap, m.scale, false)
        else if bitmap = invalid
            print "invalid bitmap:"; component.url
        end if
        m.screen.DrawObject(x, y, bitmap)
    else if component.DoesExist("TargetRect")
        x = rect.x * m.scale
        y = rect.y * m.scale
        w = rect.w * m.scale
        h = rect.h * m.scale
        if component.Color <> invalid
            color = HexToInt(component.Color)
        else
            color = m.colors.white
        end if
        m.screen.DrawRect(x, y, w, h, color)
    end if
End Sub

Function HexToInt(hex_in)
    bArr = createobject("roByteArray")
    if len(hex_in) mod 2 > 0
        hex_in = "0" + hex_in
    end if
    bArr.fromHexString(hex_in)    
    out = 0
    for i = 0 to bArr.count()-1
        out = 256 * out + bArr[i]
    end for
    return out
End Function