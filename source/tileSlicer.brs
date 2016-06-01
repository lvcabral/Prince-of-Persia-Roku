' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: February 2016
' **  Updated: May 2016
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateSlicer(tile as object) as object
    'Constants
    tile.STATE_WAITING = 0
    tile.STATE_MOVING = 1
    tile.STATE_SLICE = 2
    'Properties
    tile.child.back.frameName = tile.key + "_slicer_5"
    tile.child.front.frameName = tile.key + "_slicer_5_fg"
    tile.stage = 13
    tile.state = tile.STATE_WAITING
    tile.audio = false
    tile.active = false
    tile.redraw = false
    tile.blood = {visible: false, frameName: "slicer_blood_5"}
    'Methods
    tile.update = update_slicer
    tile.getBounds = get_slicer_bounds
    tile.start = start_slicer
    return tile
End Function

Sub update_slicer()
    if m.active
        if m.stage = 0 and m.audio
            PlaySound("jaws-clash", 50, true)
        end if
        m.stage = m.stage + 1
        if m.stage >= 15
            m.stage = 0
            m.active = false
        else if m.stage <= 5
            m.child.back.frameName = m.key + "_slicer_" + itostr(m.stage)
            m.child.front.frameName = m.key + "_slicer_" + itostr(m.stage) + "_fg"
            if m.blood.visible
                m.blood.frameName = "slicer_blood_" + itostr(m.stage)
            end if
            if m.stage = 3
                m.state = m.STATE_SLICE
            else
                m.state = m.STATE_MOVING
            end if
            m.redraw = true
        else
            m.state = m.STATE_WAITING
        end if
    end if
End Sub

Function get_slicer_bounds()
    bounds = {}
    bounds.height = 63
    bounds.width = 5
    bounds.x = m.x + 15
    bounds.y = m.y + 10
    return bounds
End Function

Sub start_slicer()
    m.active = true
End Sub
