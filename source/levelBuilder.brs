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

Function LoadTiles(defaultLevel as integer) as object
    tileSet = {}
    'Settings
    tileSet.spriteMode = m.settings.spriteMode
	'Constants
	tileSet.const = m.const
    tileSet.wallColor = [&hD8A858FF, &hE0A45CFF, &hE0A860FF, &hD8A054FF, &hE0A45CFF, &hD8A458FF, &hE0A858FF, &hD8A860FF]
	'Methods
	tileSet.buildLevel = build_level
	tileSet.buildTile = build_tile
	tileSet.getRoomId  = get_room_id
	tileSet.getTileAt  = get_tile_at
    'Read maps
    tileSet.level = tileSet.BuildLevel(defaultLevel)
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
	this = CreateLevel(json.number, json.name, json.type)
	m.level = this
	'Build level
	m.type = json.type
	this.width = json.size.width
	this.height = json.size.height
	dim layout[this.height, this.width]
	this.layout = layout
	'Load rooms from json
	for y = 0 to this.height - 1
		this.layout[y] = []
		for x = 0 to this.width - 1
			index = y * this.width + x
			id = json.room[index].id
			this.layout[y][x] = id
			if id >= 0
				this.rooms[id] = {}
				this.rooms[id].x = x
				this.rooms[id].y = y
				this.rooms[id].links = {}
                this.rooms[id].links.hideUp = NBool(json.room[index].hideUp)
                this.rooms[id].links.hideLeft = NBool(json.room[index].hideLeft)
                this.rooms[id].links.leftZ = NInt(json.room[index].leftZ, 5)
			    this.rooms[id].up = []
				this.rooms[id].left = []
				this.rooms[id].right = []
				this.rooms[id].tiles = json.room[index].tile
			end if
		next
	next
	print "all rooms loaded"
	'Create room with links
	for y = this.height - 1 to 0 step -1
		for x = 0 to this.width - 1
			id = this.layout[y][x]
			if id >= 0
				this.rooms[id].links.left = m.getRoomId(x - 1, y)
				this.rooms[id].links.right = m.getRoomId(x + 1, y)
	            this.rooms[id].links.up = m.getRoomId(x, y - 1)
				this.rooms[id].links.down = m.getRoomId(x, y + 1)
				'No room on the left (brick wall)
				if this.rooms[id].links.left < 0
					for jj = 2 to 0 step -1
						tile = CreateTile(this.const.TILE_WALL, 0, this.type)
						tile.back = tile.key + "_wall_0"
						tile.front = invalid
						tile.room = id
						this.addTile(-1, jj, id, tile)
					next
				end if
				'Build room with tiles
                print "room id="; id
				for yy = 2 to 0 step -1
					for xx = 0 to 9
						tile = m.buildTile( xx, yy, id )
						this.addTile(xx, yy, id, tile)
					next
				next
                'No room on the right (brick wall)
                if this.rooms[id].links.right < 0
                    for jj = 2 to 0 step -1
                        rTile = jj * 10 + 9
                        if this.rooms[id].tiles[rTile].element = this.const.TILE_WALL
                            tile = CreateTile(this.const.TILE_WALL, 0, this.type)
                            tile.back = tile.key + "_wall_0"
                            tile.front = invalid
                        else
                            tile = CreateTile(this.const.TILE_SPACE, 0, this.type)
                        end if
                        tile.room = id
                        this.addTile(-2, jj, id, tile)
                    next
                end if
				'No room on the up side (floor)
				if this.rooms[id].links.up < 0
					for ii = 0 to 9
						tile = CreateTile(this.const.TILE_FLOOR, 0, this.type)
						tile.room = id
						this.addTile(ii, -1, id, tile)
					next
				end if
			end if
		next
	next
	this.prince = json.prince
	if this.prince.direction = -1
		this.prince.direction = this.const.FACE_LEFT
	end if
	this.guards = json.guards
	this.events = json.events
	return this
End Function

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
        if m.type = m.const.TYPE_DUNGEON
            if m.spriteMode = m.const.SPRITES_DOS
                tile.front = wallType + "_" + itostr(tileSeed)
            else
                tile.front = wallType
            end if
        else
			tile.front = "pattern"
            if m.spriteMode = m.const.SPRITES_DOS
    			tile.child.front.frameName = "W_" + itostr(tileSeed)
    			tile.child.front.y = 16
            end if
        end if
        if wallType.mid(2,1) = "S"
            tile.back = tile.key + "_wall_" + itostr(t.modifier)
        end if
    else if t.element = m.const.TILE_SPACE or t.element = m.const.TILE_FLOOR
        tile.child.back.frameName = tile.key + "_" + itostr(t.element) + "_" + itostr(t.modifier)
    else if t.element = m.const.TILE_GATE
        tile = CreateGate(tile)
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
        if m.spriteMode = m.const.SPRITES_MAC and m.level.type = m.const.TYPE_DUNGEON
            tile = CreateExitDoor(tile, 5)
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
        tile.front = tile.front + "_" + itostr(t.modifier)
        if m.spriteMode = m.const.SPRITES_DOS
            tile.child.back.frames = GenerateFrameNames("bubble_", 1, 7, "_"+colors[t.modifier], true)
            px = 25
            py = 53
            if t.modifier > tile.const.POTION_HEALTH and t.modifier < tile.const.POTION_POISON
    			py = py - 4
    		end if
        else
            if t.modifier <> tile.const.POTION_LIFE
                tile.child.back.frames = GenerateFrameNames("bubble_", 1, 6, "_"+colors[t.modifier], false, 2)
            end if
            px = 20
            py = 52
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
    return m.level.layout[y][x]
End Function


Function WallMarks(i as integer) as string
    r = rnd(3) - 1
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
