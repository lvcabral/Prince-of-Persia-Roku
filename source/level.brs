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

Function CreateLevel(number as integer, name as string, levelType as integer) as object
	this = {}
	'Constants
	this.const = m.const

	'Properties
	this.number = number
	this.name = name
	this.type = levelType
	this.exitOpen = 0

	dim rooms[25]
	this.rooms = rooms
    this.trobs = []
    this.mobs = []
    this.masked = []

	'Methods
	this.addTile    = add_tile
	this.getTileAt  = get_tileat
	this.unMaskTiles = unmask_tiles
	this.maskTile   = mask_tile
	this.shakeFloor = shake_floor
	this.floorStartFall = floor_start_fall
	this.floorStopFall  = floor_stop_fall
	this.removeObject = remove_object
	return this
End Function

Function add_tile(x as integer, y as integer, room as integer, tile as object)
    ' -13? => real image height 79 - block height 63 = -16 for overlapping tiles + 3 for top screen offset
    tile.x  = (m.rooms[room].x * m.const.ROOM_WIDTH + x * m.const.BLOCK_WIDTH)
    tile.y  = m.rooms[room].y * m.const.ROOM_HEIGHT + y * m.const.BLOCK_HEIGHT - 13

    if x >= 0 and y >= 0
        m.rooms[room].tiles[y * 10 + x] = tile
        tile.roomX = x
        tile.roomY = y
        tile.room = room
    else if y = -1
        m.rooms[room].up.Push(tile)
    else if x = -1
        m.rooms[room].left.Push(tile)
    else if x = -2
        tile.x  = (m.rooms[room].x * m.const.ROOM_WIDTH + 9 * m.const.BLOCK_WIDTH)
        m.rooms[room].right.Push(tile)
    end if
End Function

Sub unmask_tiles()
	if m.masked <> invalid
		for each tile in m.masked
			tile.setMask(false)
		next
	end if
End Sub

Sub mask_tile(x as integer, y as integer, room as integer)
	tile = m.getTileAt(x,y,room)
	if tile.isMasked
		return
	end if
	m.unMaskTiles()
	if tile.isWalkable() 'and not tile.isTrob()
		tile.setMask(true)
		m.masked.Push(tile)
	end if
End Sub

Function get_tileat(x as integer, y as integer, room as integer) as object
	newRoom = room
	if x < 0
		newRoom = m.rooms[room].links.left
		x = x + 10
	else if x > 9
		newRoom = m.rooms[room].links.right
		x = x - 10
	end if
	if y < 0
		newRoom = m.rooms[room].links.up
		y = y + 3
	else if y > 2
		newRoom = m.rooms[room].links.down
		y = y - 3
	end if
	if newRoom = -1
		return CreateTile(m.const.TILE_WALL, 0, m.type)
	end if
	return m.rooms[newRoom].tiles[x + y * 10]
End Function

Sub shake_floor(y as integer, room as integer)
	for x = 0 to 10
		tile = m.getTileAt(x,y,room)
		if tile.element = m.const.TILE_LOOSE_BOARD
			tile.shake(false)
		end if
	next
End Sub

Function floor_start_fall(tile as object) as object
    'Remove floor from room map and set space tile
    space = CreateTile(m.const.TILE_SPACE, 0, tile.type)
    if (tile.type = m.const.TYPE_PALACE)
        space.back = tile.key + "_0_1"
    end if
    m.addTile(tile.roomX, tile.roomY, tile.room, space)
	'Calculate stop level
    floor = {}
    floor.x = tile.roomX
    floor.y = tile.roomY + 1
    floor.room = tile.room
    floor.fromAbove = false
    if floor.y = 3
        floor.y = 0
        floor.room = m.rooms[floor.room].links.down
    end if
    tile.yTo = m.const.BLOCK_HEIGHT
	while (m.getTileAt(floor.x, floor.y, floor.room).element = m.const.TILE_SPACE)
        tile.yTo = tile.yTo + m.const.BLOCK_HEIGHT
        floor.y = floor.y + 1
        if floor.y = 3
            floor.y = 0
            floor.room = m.rooms[floor.room].links.down
        end if
	end while
	return floor
End Function

Function floor_stop_fall(floor as object) as object
	'Change floor to version with debris
	debris = m.getTileAt(floor.x, floor.y, floor.room)
	if debris.element = m.const.TILE_FLOOR or debris.element = m.const.TILE_SPIKES
		debris.element = m.const.TILE_DEBRIS
	else if debris.element = m.const.TILE_POTION
		debris.back = debris.key + "_" + itostr(m.const.TILE_DEBRIS)
		debris.front = debris.key + "_" + itostr(m.const.TILE_DEBRIS) + "_fg"
		debris.hasObject = false
	    debris.redraw = true
		return invalid
	else if debris.element = m.const.TILE_TORCH
	   debris.element = m.const.TILE_TORCH_WITH_DEBRIS
	else if debris.element = m.const.TILE_LOOSE_BOARD
		debris.shake(true)
		return invalid
	else if debris.element = m.const.TILE_RAISE_BUTTON or debris.element = m.const.TILE_DROP_BUTTON
       debris.push(true, false)
	   debris.element = m.const.TILE_DEBRIS
	else
		return invalid
	end if
	debris.back = debris.key + "_" + itostr(debris.element)
	debris.front = debris.key + "_" + itostr(debris.element) + "_fg"
	return debris
End Function

Sub remove_object(x as integer, y as integer, room as integer)
    tile = m.getTileAt(x,y,room)
	if tile.element <> m.const.TILE_POTION
    	tile.back  = tile.key + "_" + itostr(m.const.TILE_FLOOR)
	end if
    tile.front = tile.key + "_" + itostr(m.const.TILE_FLOOR) + "_fg"
    tile.hasObject = false
    tile.redraw = true
End Sub

Sub fireEvent(event as integer, tileType as integer, stuck = false as boolean)
    g = GetGlobalAA()
    level = g.tileSet.level
    room = level.events[event].room
    x = (level.events[event].location - 1) mod 10
    y = Int((level.events[event].location - 1) / 10)
    print "Fire "; event; " - "; room; " ";  x; ","; y
    tile = level.getTileAt(x, y, room)
    if tile.element = tile.const.TILE_EXIT_LEFT
        tile = level.getTileAt(x + 1, y, room)
    end if
    if tileType = tile.const.TILE_RAISE_BUTTON
		if tile.element = tile.const.TILE_EXIT_RIGHT
			if not tile.isOpen()
				level.exitOpen = 1
				tile.raise()
			end if
		else
			tile.raise(stuck)
		end if
    else
        tile.drop()
    end if
    if level.events[event].next > 0
        fireEvent(event + 1, tileType, stuck)
    end if
End Sub
