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

Function CreateLooseBoard(tile as object) as object
	'Constants
	tile.STATE_INACTIVE = 0
	tile.STATE_SHAKING = 1
	tile.STATE_FALLING = 2
	tile.STATE_CRASHED = 3
	tile.FALL_VELOCITY = 3
    'Properties
	tile.frames = GenerateFrameNames("_loose_", 1, 8, "", false)
    tile.stage = 0
    tile.state = tile.STATE_INACTIVE
    tile.vacc = 0
    tile.yTo = 0
	tile.fall = false
	tile.redraw = false
	'Methods
	tile.update = update_loose
	tile.shake = shake_loose
    return tile
End Function

Sub update_loose()
	if m.state = m.STATE_SHAKING
	    print "shaking"
        if m.stage = m.frames.count() + 3
            print "start fall"
            m.state = m.STATE_FALLING
            m.stage = 0
            m.back = m.key + "_falling"
        else if m.stage >= m.frames.count()
            m.stage = m.stage + 1
		else if m.stage = 3 and not m.fall
            print "inactive"
			m.back = m.key + "_" + itostr(m.const.TILE_LOOSE_BOARD)
			m.state = m.STATE_INACTIVE
		else
			m.back = m.key + m.frames[m.stage]
			m.stage = m.stage + 1
			if m.stage = 1 or m.stage = 3 or m.stage = 7
			    PlaySound("loose-floor-"+itostr(rnd(3)))
			end if
		end if
		m.redraw = true
	else if m.state = m.STATE_FALLING
        print "falling";  m.y; m.yTo
		v = m.FALL_VELOCITY * m.stage
		m.y = m.y + v
		m.stage = m.stage + 1
		m.vacc = m.vacc + v
		if m.vacc > m.yTo
		    print "crashed"
			m.state = m.STATE_CRASHED
            m.vacc = 0
			m.yTo = 0
			PlaySound("loose-crash", 75, true)
		end if
		m.redraw = true
    end if
End Sub

Sub shake_loose(fall as boolean)
    if m.state = m.STATE_INACTIVE
        m.state = m.STATE_SHAKING
        m.stage = 0
        'm.front.visible = false
    end if
    m.fall = fall
	print "shake fall=";fall
End Sub
