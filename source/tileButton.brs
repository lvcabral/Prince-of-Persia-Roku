' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: March 2016
' **  Updated: July 2016
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateButton(tile as object) as object
    if tile.element = tile.const.TILE_RAISE_BUTTON
        tile.stageMax = 3
    else
        tile.stageMax = 5
    end if
    tile.pushes = 0
    tile.stage = 0
    tile.active = false
	tile.redraw = false
    tile.stuck = false
    'Methods
    tile.update = update_button
    tile.push = push_button
    return tile
End Function

Function update_button()
    if m.active
        if m.stage = m.stageMax
            if not m.stuck
                m.front = m.key + "_" + itostr(m.element) + "_fg"
                m.back = m.key + "_" + itostr(m.element)
                m.active = false
    			m.redraw = true
            end if
        else
            m.stage = m.stage + 1
        end if
    end if
End Function

Function push_button(stuck = false as boolean, sound = true as boolean)
    if not m.active
        m.active = true
		m.redraw = true
        if not m.isMasked then m.front = invalid
        m.back = m.back + "_down"
        if sound then PlaySound("button-open")
    end if
    if not m.stuck then m.stuck = stuck
    m.onPushed(m.modifier, m.element, m.stuck)
    m.pushes = m.pushes + 1
    m.stage = 0
End Function
