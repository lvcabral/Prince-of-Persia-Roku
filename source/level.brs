' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: March 2016
' **  Updated: January 2024
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

function CreateLevel(number as integer, name as string, levelType as integer) as object
	this = {}
	'Constants
	this.const = m.const

	'Properties
	this.number = number
	this.name = name
	this.type = levelType
	this.exitOpen = 0

	' dim rooms[25]
	' this.rooms = rooms
	this.rooms = []
	for i = 1 to 25
		this.rooms.push(invalid)
	next
	this.trobs = []
	this.mobs = []
	this.masked = []

	'Methods
	this.addTile = add_tile
	this.getTileAt = get_tileat
	this.unMaskTiles = unmask_tiles
	this.maskTile = mask_tile
	this.shakeFloor = shake_floor
	this.floorStartFall = floor_start_fall
	this.floorStopFall = floor_stop_fall
	this.removeObject = remove_object
	return this
end function

function add_tile(x as integer, y as integer, room as integer, tile as object)
	' -13? => real image height 79 - block height 63 = -16 for overlapping tiles + 3 for top screen offset
	tile.x = (m.rooms[room].x * m.const.ROOM_WIDTH + x * m.const.BLOCK_WIDTH)
	tile.y = m.rooms[room].y * m.const.ROOM_HEIGHT + y * m.const.BLOCK_HEIGHT - 13

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
		tile.x = (m.rooms[room].x * m.const.ROOM_WIDTH + 9 * m.const.BLOCK_WIDTH)
		m.rooms[room].right.Push(tile)
	end if
end function

sub unmask_tiles()
	if m.masked <> invalid
		for each tile in m.masked
			tile.setMask(false)
		next
	end if
end sub

sub mask_tile(x as integer, y as integer, room as integer)
	tile = m.getTileAt(x, y, room)
	if tile.isMasked
		return
	end if
	m.unMaskTiles()
	if tile.isWalkable() 'and not tile.isTrob()
		tile.setMask(true)
		m.masked.Push(tile)
	end if
end sub

function get_tileat(x as integer, y as integer, room as integer) as object
	newRoom = room
	if x < 0
		newRoom = m.rooms[room].links.left
		x += 10
	else if x > 9
		newRoom = m.rooms[room].links.right
		x -= 10
	end if
	if y < 0
		newRoom = m.rooms[room].links.up
		y += 3
	else if y > 2
		newRoom = m.rooms[room].links.down
		y -= 3
	end if
	if newRoom = -1 or m.rooms[newRoom] = invalid
		return CreateTile(m.const.TILE_WALL, 0, m.type)
	end if
	return m.rooms[newRoom].tiles[x + y * 10]
end function

sub shake_floor(y as integer, room as integer)
	for x = 0 to 10
		tile = m.getTileAt(x, y, room)
		if tile.element = m.const.TILE_LOOSE_BOARD then tile.shake(false)
	next
end sub

function floor_start_fall(tile as object) as object
	'Remove floor from room map and set space tile
	space = CreateTile(m.const.TILE_SPACE, 0, tile.type)
	if (tile.type = m.const.TYPE_PALACE) then space.back = tile.key + "_0_1"
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
		floor.y++
		if floor.y = 3
			floor.y = 0
			floor.room = m.rooms[floor.room].links.down
		end if
	end while
	return floor
end function

function floor_stop_fall(floor as object) as object
	'Change floor to version with debris
	debris = m.getTileAt(floor.x, floor.y, floor.room)
	if debris.element = m.const.TILE_FLOOR or debris.element = m.const.TILE_SPIKES
		debris.element = m.const.TILE_DEBRIS
	else if debris.element = m.const.TILE_POTION
		debris.back = debris.key + "_" + m.const.TILE_DEBRIS.toStr()
		debris.front = debris.key + "_" + m.const.TILE_DEBRIS.toStr() + "_fg"
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
	debris.back = debris.key + "_" + debris.element.toStr()
	debris.front = debris.key + "_" + debris.element.toStr() + "_fg"
	return debris
end function

sub remove_object(x as integer, y as integer, room as integer)
	tile = m.getTileAt(x, y, room)
	if tile.element <> m.const.TILE_POTION
		tile.back = tile.key + "_" + m.const.TILE_FLOOR.toStr()
	end if
	tile.front = tile.key + "_" + m.const.TILE_FLOOR.toStr() + "_fg"
	tile.hasObject = false
	tile.redraw = true
end sub

sub fireEvent(event as integer, tileType as integer, stuck = false as boolean)
	g = GetGlobalAA()
	level = g.tileSet.level
	room = level.events[event].room
	x = (level.events[event].location - 1) mod 10
	y = Int((level.events[event].location - 1) / 10)
	'print "Fire "; event; " - "; room; " ";  x; ","; y
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
end sub
