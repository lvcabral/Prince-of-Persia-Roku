' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: March 2016
' **  Updated: March 2016
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateSpikes(tile as object) as object
	'Constants
	tile.STATE_INACTIVE = 0
	tile.STATE_RAISING = 1
	tile.STATE_FULL_OUT = 2
	tile.STATE_DROPPING = 3
    'Properties
    tile.state = tile.STATE_INACTIVE
    tile.stage = 0
	tile.redraw = false
    tile.mortal = (tile.modifier < 5)
    if tile.modifier > 2 and tile.modifier < 6
		tile.modifier = 5
	else if tile.modifier = 6
		tile.modifier = 4
    else if tile.modifier > 6
		tile.modifier = 9 - tile.modifier
	end if
    tile.child.back.frameName = tile.key + "_" + itostr(tile.element) + "_" + itostr(tile.modifier)
	tile.child.front.frameName = tile.key + "_" + itostr(tile.element) + "_" + itostr(tile.modifier) + "_fg"
    'Methods
	tile.update = update_spikes
	tile.raise = raise_spikes
	return tile
End Function

Sub update_spikes()
    if m.modifier <> 0
        return
    end if
	if m.state = m.STATE_RAISING
		m.stage = m.stage + 1
		m.child.back.frameName = m.key + "_" + itostr(m.const.TILE_SPIKES) + "_" + itostr(m.stage)
		m.child.front.frameName = m.key + "_" + itostr(m.const.TILE_SPIKES) + "_" + itostr(m.stage) + "_fg"
		if m.stage = 5
			m.state = m.STATE_FULL_OUT
			m.stage = 0
		end if
		m.redraw = true
	else if m.state = m.STATE_FULL_OUT
		m.stage = m.stage + 1
		if m.stage > 15
			m.state = m.STATE_DROPPING
			m.stage = 5
		end if
		m.redraw = true
	else if m.state = m.STATE_DROPPING
		m.stage = m.stage - 1
		if m.stage = 3
			m.stage = m.stage - 1
		end if
		m.child.back.frameName = m.key + "_" + itostr(m.const.TILE_SPIKES) + "_" + itostr(m.stage)
		m.child.front.frameName = m.key + "_" + itostr(m.const.TILE_SPIKES) + "_" + itostr(m.stage) + "_fg"
		if m.stage = 0
			m.state = m.STATE_INACTIVE
		end if
        m.redraw = true
    end if
End Sub

Sub raise_spikes()
    if m.state = m.STATE_INACTIVE
        m.state = m.STATE_RAISING
        PlaySound("spikes")
    else if m.state = m.STATE_FULL_OUT
		m.stage = 0
    end if
End Sub
