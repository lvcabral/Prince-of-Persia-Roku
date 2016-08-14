' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: March 2016
' **  Updated: May 2016
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateExitDoor(tile as object, openHeight = 9 as integer, doorX = 8 as integer) as object
	'Constants
	tile.STATE_OPEN = 0
	tile.STATE_RAISING = 1
	tile.STATE_DROPPING = 2
	tile.STATE_CLOSED = 3

	'Properties
    tile.child.back.frameName = tile.key + "_door"
    tile.child.front.frameName = tile.key + "_door_fg"
    tile.child.front.visible = false
    if tile.type = tile.const.TYPE_PALACE
		tile.child.back.x = 7
	else
		tile.child.back.x = doorX
	end if
	tile.child.back.y = tile.const.TILE_HEIGHT - 67
	tile.child.back.height = tile.const.BLOCK_HEIGHT - 12
	tile.cropY = 0
	tile.state = tile.STATE_CLOSED
    tile.redraw = false
    tile.dropped = false
	tile.openHeight = openHeight
	'Methods
	tile.update = update_door
	tile.drop = drop_door
	tile.raise = raise_door
	tile.mask = mask_door
	tile.isOpen = is_open_door
	return tile
End Function

Sub update_door()
    door = m.child.back
    if m.state = m.STATE_RAISING
		if door.height = (m.openHeight + m.type)
			m.state = m.STATE_OPEN
		else
			print "door raising"
			door.height = door.height - 1
			m.cropY = m.cropY - 1
		end if
		m.redraw = true
    else if m.state = m.STATE_DROPPING
        if door.height >= (m.const.BLOCK_HEIGHT - 12)
            m.state = m.STATE_CLOSED
            print "door closed"
        else
            door.height = door.height + 10
			m.cropY = m.cropY + 10
            print "door dropping"
        end if
        m.redraw = true
	else if m.state = m.STATE_OPEN
		m.redraw = true
    end if
End Sub

Sub drop_door()
    if m.state = m.STATE_OPEN
        m.state = m.STATE_DROPPING
        m.child.back.visible = true
        m.dropped = true
    end if
End Sub

Sub raise_door(stuck = false as boolean)
    if m.state = m.STATE_CLOSED
        m.state = m.STATE_RAISING
        PlaySound("exit-door-open")
    end if
End Sub

Sub mask_door()
    m.child.front.visible = true
	m.redraw = true
End Sub

Function is_open_door() as boolean
	return (m.state = m.STATE_OPEN)
End Function
