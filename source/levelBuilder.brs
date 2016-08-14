' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: February 2016
' **  Updated: August 2016
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function LoadTiles(levelId as integer) as object
    tileSet = {}
    'Settings
    tileSet.spriteMode = m.settings.spriteMode
	'Constants
	tileSet.const = m.const
    tileSet.wallColor = [&hD8A858FF, &hE0A45CFF, &hE0A860FF, &hD8A054FF, &hE0A45CFF, &hD8A458FF, &hE0A858FF, &hD8A860FF]
    'Methods
	tileSet.buildLevel  = build_level
    tileSet.buildCustom = build_custom
    tileSet.buildRooms  = build_rooms
	tileSet.buildTile   = build_tile
	tileSet.getRoomId   = get_room_id
	tileSet.getTileAt   = get_tile_at
    'Read maps
    if m.settings.modId <> invalid and m.mods[m.settings.modId].levels
        tileSet.level = tileset.buildCustom(levelId, m.mods[m.settings.modId])
    else
        tileSet.level = tileSet.buildLevel(levelId)
    end if
    tileSet.buildRooms()
    return tileSet
End Function

Function build_level(levelId as integer) as object
	'Load json
    path = "pkg:/assets/maps/"
    json = ParseJson(ReadAsciiFile(path + "level" + itostr(levelId) + ".json"))
    if json = invalid
       print "invalid level json: "; path + "level" + itostr(levelId) + ".json"
	   return {}
    end if
	'Create new level object
	level = CreateLevel(json.number, json.name, json.type)
	'Build level
	m.type = json.type
	level.width = json.size.width
	level.height = json.size.height
	dim layout[level.height, level.width]
	level.layout = layout
	'Load rooms from json
	for y = 0 to level.height - 1
		level.layout[y] = []
		for x = 0 to level.width - 1
			index = y * level.width + x
			id = json.room[index].id
			level.layout[y][x] = id
			if id >= 0
				level.rooms[id] = {x: x, y: y, links: {}, up: [], left: [], right: []}
                level.rooms[id].links.hideUp = NBool(json.room[index].hideUp)
                level.rooms[id].links.hideLeft = NBool(json.room[index].hideLeft)
                level.rooms[id].links.leftZ = NInt(json.room[index].leftZ, 5)
				level.rooms[id].tiles = json.room[index].tile
                if level.type = m.const.TYPE_PALACE
                    level.rooms[id].wallPattern = GenerateWallPattern(id)
                end if
			end if
		next
	next
    level.guards = json.guards
	level.events = json.events
    level.prince = json.prince
	if level.prince.direction = -1
		level.prince.direction = m.const.FACE_LEFT
	end if
	print "all rooms loaded"
	return level
End Function

Sub build_rooms()
    'Create room with links
    for y = m.level.height - 1 to 0 step -1
        for x = 0 to m.level.width - 1
            id = m.level.layout[y][x]
            if id <> invalid and id > 0
                if  m.level.rooms[id].links.left = invalid then
                    m.level.rooms[id].links.left = m.getRoomId(x - 1, y)
                    m.level.rooms[id].links.right = m.getRoomId(x + 1, y)
                    m.level.rooms[id].links.up = m.getRoomId(x, y - 1)
                    m.level.rooms[id].links.down = m.getRoomId(x, y + 1)
                end if
                'No room on the left (brick wall)
                if m.level.rooms[id].links.left < 0
                    for jj = 2 to 0 step -1
                        tile = CreateTile(m.level.const.TILE_WALL, 0, m.level.type)
                        tile.back = tile.key + "_wall_0"
                        tile.front = invalid
                        tile.room = id
                        m.level.addTile(-1, jj, id, tile)
                    next
                end if
                'Build room with tiles
                print "room id="; id
                for yy = 2 to 0 step -1
                    for xx = 0 to 9
                        tile = m.buildTile( xx, yy, id )
                        m.level.addTile(xx, yy, id, tile)
                    next
                next
                'No room on the right (brick wall)
                if m.level.rooms[id].links.right < 0
                    for jj = 2 to 0 step -1
                        rTile = jj * 10 + 9
                        if m.level.rooms[id].tiles[rTile].element = m.level.const.TILE_WALL
                            tile = CreateTile(m.level.const.TILE_WALL, 0, m.level.type)
                            tile.back = tile.key + "_wall_0"
                            tile.front = invalid
                        else
                            tile = CreateTile(m.level.const.TILE_SPACE, 0, m.level.type)
                        end if
                        tile.room = id
                        m.level.addTile(-2, jj, id, tile)
                    next
                end if
                'No room on the up side (floor)
                if m.level.rooms[id].links.up < 0
                    for ii = 0 to 9
                        tile = CreateTile(m.level.const.TILE_FLOOR, 0, m.level.type)
                        tile.room = id
                        m.level.addTile(ii, -1, id, tile)
                    next
                end if
            else
                m.level.layout[y][x] = -1
            end if
        next
    next
    'Create tiles for disconnected rooms
    for rr = 1 to m.level.rooms.Count() - 1
        if m.level.rooms[rr] <> invalid
            for tt = 0 to 29
                tile = m.level.rooms[rr].tiles[tt]
                if not tile.DoesExist("isSpace")
                    tile = m.buildTile( tt mod 10, int(tt / 10), rr )
                    m.level.addTile(tt mod 10, int(tt / 10), rr, tile)
                end if
            next
        end if
    next
End Sub

Function build_tile(x as integer, y as integer, id as integer)
    tileNumber = y * 10 + x
    t = m.level.rooms[id].tiles[ tileNumber ]
    tile = CreateTile(t.element, t.modifier, m.level.type)
    tile.room = id
    if t.element = m.const.TILE_WALL
        tileSeed = tileNumber + id
        wallType = ""
        if m.getTileAt(x - 1, y, id).element = m.const.TILE_WALL
            wallType = "W"
        else
            wallType = "S"
        end if
        wallType = wallType + "W"
        if m.getTileAt(x + 1, y, id).element = m.const.TILE_WALL
            wallType = wallType + "W"
        else
            wallType = wallType + "S"
        end if
        tile.front = wallType + "_" + itostr(tileSeed)
        if wallType.mid(2,1) = "S"
            tile.back = tile.key + "_wall_" + itostr(t.modifier)
        end if
    else if t.element = m.const.TILE_SPACE or t.element = m.const.TILE_FLOOR
        tile.child.back.frameName = tile.key + "_" + itostr(t.element) + "_" + itostr(t.modifier)
    else if t.element = m.const.TILE_GATE
        tile = CreateGate(tile)
    else if t.element = m.const.TILE_STUCK_BUTTON
        tile.back = tile.key + "_1"
        tile.front = tile.back + "_fg"
    else if t.element = m.const.TILE_RAISE_BUTTON or t.element = m.const.TILE_DROP_BUTTON
        tile = CreateButton(tile)
        tile.onPushed = fireEvent
	else if t.element = m.const.TILE_SWORD
		tile = CreateSword(tile)
    else if t.element = m.const.TILE_SPIKES
        tile = CreateSpikes(tile)
    else if t.element = m.const.TILE_SLICER
        tile = CreateSlicer(tile)
	else if t.element = m.const.TILE_LOOSE_BOARD
		tile = CreateLooseBoard(tile)
	else if t.element = m.const.TILE_EXIT_RIGHT
        if m.spriteMode = m.const.SPRITES_MAC
            tile = CreateExitDoor(tile, 8, 10)
        else
            tile = CreateExitDoor(tile)
        end if
	else if t.element = m.const.TILE_TORCH or t.element = m.const.TILE_TORCH_WITH_DEBRIS
		tile.child.back.frames = GenerateFrameNames("fire_", 1, 9, "", true)
        if m.type = m.const.TYPE_PALACE and m.spriteMode = m.const.SPRITES_MAC
    		tile.child.back.x = 41
    		tile.child.back.y = 16
        else
            tile.child.back.x = 40
            tile.child.back.y = 18
        end if
	else if t.element = m.const.TILE_POTION
		colors = ["red", "red", "red", "green", "green", "blue", "blue"]
        potion = tile.front + "_" + itostr(t.modifier)
        if m.type = m.const.TYPE_PALACE
            if m.spriteMode = m.const.SPRITES_MAC
                if t.modifier > 2 then potion = tile.front + "_1"
            else
                if t.modifier = 3 or t.modifier = 4
                    potion = tile.front + "_2"
                else if t.modifier = 5
                    potion = tile.front + "_1"
                end if
            end if
        end if
        tile.front = potion
        if m.spriteMode = m.const.SPRITES_MAC
            if t.modifier <> tile.const.POTION_LIFE
                tile.child.back.frames = GenerateFrameNames("bubble_", 1, 6, "_"+colors[t.modifier], false, 2)
            end if
            px = 20
            py = 52
        else
            tile.child.back.frames = GenerateFrameNames("bubble_", 1, 7, "_"+colors[t.modifier], true)
            px = 25
            py = 53
            if t.modifier > tile.const.POTION_HEALTH and t.modifier < tile.const.POTION_POISON
    			py = py - 4
    		end if
        end if
		tile.child.back.x = px
		tile.child.back.y = py
		tile.hasObject = true
    else if t.element = m.const.TILE_TAPESTRY
        if m.type = m.const.TYPE_PALACE and t.modifier > 0
            tile.back = tile.key + "_" + itostr(t.element) + "_" + itostr(t.modifier)
            tile.front = tile.back + "_fg"
        end if
    else if t.element = m.const.TILE_TAPESTRY_TOP
        if m.type = m.const.TYPE_PALACE and t.modifier > 0
            tile.back = tile.key + "_" + itostr(t.element) + "_" + itostr(t.modifier)
            tile.front = tile.back + "_fg"
            if m.getTileAt(x - 1, y, id).element = m.const.TILE_LATTICE_SUPPORT
                tile.child.back.frameName = tile.key + "_" + itostr(m.const.TILE_SMALL_LATTICE) + "_fg"
            end if
        end if
    else if t.element = m.const.TILE_BALCONY_RIGHT
        tile.child.back.frameName = tile.key + "_balcony"
        tile.child.back.y = -4
    end if
    return tile
End Function

Function get_tile_at(x as integer, y as integer, id as integer) as object
    room = m.level.rooms[id]
    if room <> invalid
        if x < 0
            id = m.getRoomId(room.x - 1, room.y)
            x = x + 10
        end if
        if x > 9
            id = m.getRoomId(room.x + 1, room.y)
            x = x - 10
        end if
        if y < 0
            room = m.getRoomId(room.x, room.y - 1)
            y = y + 3
        end if
        if y > 2
            room = m.getRoomId(room.x, room.y + 1)
            y = y - 3
        end if
    end if
    if id < 0
        return CreateTile(m.const.TILE_WALL, 0, m.level.type)
    end if
    return m.level.rooms[id].tiles[x + y * 10]
End Function

Function get_room_id(x as integer, y as integer) as integer
    if (x < 0) or (x >= m.level.width) or (y < 0) or (y >= m.level.height)
		return -1
	end if
    id = m.level.layout[y][x]
    if id = invalid then return - 1
    return id
End Function

Function WallMarks(seed as integer, i as integer) as string
    r = m.prandom.seq(seed, i, 1, 2)
    if i = 0
        f = "W_" + itostr(r)
    else if i = 1
        f = "W_" + itostr(r + 3)
    else if i = 2
        f = "W_" + itostr(r + 6)
    else if i = 3
        f = "W_" + itostr(r + 9)
    else if i = 4
        f = "W_" + itostr(r + 12)
    end if
    return f
End Function

Function GenerateWallPattern(room as integer) as object
    Dim wallPattern[3, 4, 11]
    m.prandom.seed = room
    m.prandom.get(1)
    for row = 0 to 2
        for subrow = 0 to 3
            if subrow mod 2 = 0 then colorBase = 4 else colorBase = 0
            prevColor = -1
            for col = 0 to 10
                while true
                    color = colorBase + m.prandom.get(3)
                    if color <> prevColor then exit while
                end while
                wallPattern[row][subrow][col] = color
                prevColor = color
            next
        next
    next
    return wallPattern
 End Function
