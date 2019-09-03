' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
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

Function CreateGate(tile as object) as object
	'constants
	tile.STATE_CLOSED = 0
	tile.STATE_OPEN = 1
	tile.STATE_RAISING = 2
	tile.STATE_DROPPING = 3
	tile.STATE_FAST_DROPPING = 4
	tile.STATE_WAITING = 5
	tile.WAIT_CYCLES = 55
	'properties
    tile.cropY = - tile.modifier * 46

	tile.child.back.frameName = tile.key + "_gate"
    tile.child.back.x = 0
    tile.child.back.y = 0

	tile.child.front.frameName = tile.key + "_gate_fg"
	tile.child.front.x = 32
	tile.child.front.y = 16
	tile.child.front.visible = false

    tile.state = tile.modifier
    tile.stage = 0
    tile.audio = false
	tile.redraw = false
	tile.stuck = false

    'methods
    tile.update = update_gate
	tile.raise = raise_gate
	tile.drop = drop_gate
	tile.getBounds = get_gate_bounds
    tile.canCross = can_cross

	return tile
End Function

Function update_gate()
	if m.state =  m.STATE_RAISING
		if m.cropY = -47
			m.state = m.STATE_WAITING
			m.stage = 0
			if m.audio
				PlaySound("gate-end", true)
			end if
		else
			m.cropY--
			if m.cropY mod 2 = 0
	            if m.audio
					PlaySound("gate-open", true)
				end if
			end if
		end if
		m.redraw = true
	else if m.state =  m.STATE_WAITING and not m.stuck
		m.stage++
		if m.stage = m.WAIT_CYCLES
			m.state = m.STATE_DROPPING
			m.stage = 0
		end if
		m.redraw = true
	else if m.state =  m.STATE_DROPPING
		if m.stage = 0
			m.cropY++
			if m.cropY >= 0
				m.cropY = 0
				m.state = m.STATE_CLOSED
                if m.audio
					PlaySound("gate-end", true)
				end if
			end if
			m.stage++
            if m.audio
				PlaySound("gate-close", true)
			end if
		else
			m.stage = (m.stage + 1) mod 4
		end if
		m.redraw = true
	else if m.state =  m.STATE_FAST_DROPPING
		m.cropY += 10
		if m.cropY >= 0
			m.cropY = 0
			m.state = m.STATE_CLOSED
		end if
		m.redraw = true
    end if
End Function

Sub raise_gate(stuck = false as boolean)
    m.stage = 0
    m.stuck = stuck
    if m.state <> m.STATE_WAITING
        m.state = m.STATE_RAISING
    end if
End Sub

Sub drop_gate()
    if m.state <> m.STATE_CLOSED
        m.state = m.STATE_FAST_DROPPING
        if m.audio
			PlaySound("gate-fast-close")
		end if
    end if
End Sub

Function get_gate_bounds()
    bounds = {}
    bounds.height = 63 + m.cropY
    bounds.width = 4
    bounds.x = m.x + 40
    bounds.y = m.y
    return bounds
End Function

Function can_cross(height as integer) as boolean
    return (Abs(m.cropY)  >  height)
End Function
