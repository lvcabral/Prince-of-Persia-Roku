' ********************************************************************************************************
' ********************************************************************************************************
' **  Prince of Persia for Roku - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: March 2016
' **  Updated: August 2016
' **
' **  Ported to BrightScript by Marcelo Lv Cabral from the Git projects:
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
                m.front = m.key + "_" + m.element.toStr() + "_fg"
                m.back = m.key + "_" + m.element.toStr()
                m.active = false
    			m.redraw = true
            end if
        else
            m.stage++
        end if
    end if
End Function

Function push_button(stuck = false as boolean, sound = true as boolean)
    if not m.active
        m.active = true
		m.redraw = true
        if not m.isMasked
            m.front = invalid
        end if
        m.back = m.back + "_down"
        if sound
            PlaySound("button-open")
        end if
    end if
    if not m.stuck
        m.stuck = stuck
    end if
    m.onPushed(m.modifier, m.element, m.stuck)
    m.pushes++
    m.stage = 0
End Function
