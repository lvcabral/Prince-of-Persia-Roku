' ********************************************************************************************************
' ********************************************************************************************************
' **  Prince of Persia for Roku - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: March 2016
' **  Updated: August 2016
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateSword(tile as object) as object
	'Properties
    tile.tick = rnd(128) + 39
    tile.stage = 0
	tile.redraw = false
	tile.hasObject = true
	'Method
	tile.update = update_sword
	return tile
End Function

Sub update_sword()
    if m.hasObject
        if m.stage = -1
            m.back = m.key + "_" + m.element.toStr()
            m.tick = rnd(128) + 39
    		m.redraw = true
        end if
        m.stage++
        if m.stage = m.tick
            m.back = m.back + "_bright"
            m.stage = -1
    		m.redraw = true
        end if
    end if
End Sub
