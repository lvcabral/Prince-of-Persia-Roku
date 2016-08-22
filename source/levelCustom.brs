' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: July 2016
' **  Updated: August 2016
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function build_custom(levelId as integer, mod as object) as object
    DefaultLevelTypes = [0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0]
    DefaultEnemies = [ "", "guard", "guard", "guard", "guard", "guard", "fatguard", "guard", "guard", "guard", "guard", "guard", "guard", "vizier", "", "" ]
    if levelId = 12
        xmlFile = "level12a.xml"
    else if levelId = 13
        xmlFile = "level12b.xml"
    else if levelId = 14
        xmlFile = "princess.xml"
    else
        xmlFile = "level" + itostr(levelId) + ".xml"
    end if
    modPath = mod.url + mod.path
    if Left(modPath, 3) = "pkg" then modPath = modPath + "levels/"
    rsp = ReadAsciiFile(modPath + xmlFile)
    if mod.types <> invalid then DefaultLevelTypes = mod.types
    if mod.guards <> invalid then DefaultEnemies = mod.guards
    xml = CreateObject("roXMLElement")
    if not xml.Parse(rsp) then
         print "Invalid xml for level "; levelId; " "; modPath + xmlFile
        return invalid
    endif
    'Create new level object
	this = CreateLevel(levelId, "Custom Level", DefaultLevelTypes[levelId])
    this.guards = []
    this.events = []
	m.level = this
    m.type = DefaultLevelTypes[levelId]
    'Add Prince
    prince = xml.GetNamedElements("prince").Simplify()
    this.prince = {room: Val(prince@room), location: Val(prince@location), direction: Val(prince@direction) - 1}
	'Build level
    xmlRooms = xml.GetNamedElements("rooms").GetChildElements()
    for each xmlRoom in xmlRooms
        xmlTiles = xmlRoom.GetNamedElements("tile")
        xmlGuard = xmlRoom.GetNamedElements("guard").Simplify()
        xmlLinks = xmlRoom.GetNamedElements("links").Simplify()
        id = Val(xmlRoom@number)
        rmlnk = {hideUp: false, hideLeft: false, leftZ: 5}
        if xmlLinks@left > "0" then rmlnk.left = Val(xmlLinks@left) else rmlnk.left = -1
        if xmlLinks@right > "0" then rmlnk.right = Val(xmlLinks@right) else rmlnk.right = -1
        if xmlLinks@up > "0" then rmlnk.up = Val(xmlLinks@up) else rmlnk.up = -1
        if xmlLinks@down > "0" then rmlnk.down = Val(xmlLinks@down) else rmlnk.down = -1
        if rmlnk.left > 0 or rmlnk.right > 0 or rmlnk.up > 0 or rmlnk.down > 0 or this.prince.room = id
            this.rooms[id] = {x: 0, y: 0, links: {}, up: [], left: [], right: [], tiles: [], layout: false}
            this.rooms[id].links = rmlnk
            'Add tiles
            for each xmlTile in xmlTiles
                tl = {element: Val(xmlTile@element) and &h1F, modifier: Val(xmlTile@modifier)}
                if tl.element = m.const.TILE_WALL
                    if tl.modifier > 1 then tl.modifier = 0
                else if tl.element = m.const.TILE_SPACE
                    if tl.modifier = 255 then tl.modifier = 0
                else if tl.element = m.const.TILE_FLOOR
                    if tl.modifier = 3 then
                        tl.modifier = 2
                    else if tl.modifier = 255
                        if m.type = m.const.TYPE_DUNGEON then tl.modifier = 0 else tl.modifier = 2
                    end if
                else if tl.element = m.const.TILE_LOOSE_BOARD
                    'Set modifier to 1 for stuck loose tile
                    if Val(xmlTile@element) = 43 then tl.modifier = 1 else tl.modifier = 0
                else if tl.element = m.const.TILE_GATE
                    if tl.modifier = 2 then tl.modifier = 0
                end if
                this.rooms[id].tiles.Push(tl)
            next
            'Add Palace Wall Pattern
            if this.type = m.const.TYPE_PALACE
                this.rooms[id].wallPattern = GenerateWallPattern(id)
            end if
            'Add Guard
            if Val(xmlGuard@location) > 0 and Val(xmlGuard@location) < 31
                colors = Val(xmlGuard@colors)
                if colors < 1 or colors > 7 then colors = 1
                direction = Val(xmlGuard@direction)
                if direction = 2 then direction = 0
                gd = { room: id,
                       location: Val(xmlGuard@location),
                       skill: Val(xmlGuard@skill),
                       colors: colors,
                       type: DefaultEnemies[levelId],
                       direction: direction }
                this.guards.Push(gd)
            end if
        end if
    next
    'Add Special Guards
    if levelId = 3 and this.rooms[1] <> invalid
        this.guards.Unshift({"room":1, "location":16, "skill":2, "colors":0, "type":"skeleton", "direction":-1, "active": false, "visible": false})
    else if levelId = 4 and this.rooms[4] <> invalid
        this.guards.Unshift({"room":4, "location":12, "skill":3, "colors":0, "type":"shadow", "direction":1, "active": false, "visible": false})
    else if levelId = 5 and this.rooms[11] <> invalid and this.rooms[24] <> invalid
        this.guards.Unshift({"room":11, "location":5, "skill":3, "colors":0, "type":"shadow", "direction":1, "active": false, "visible": false})
    else if levelId = 6 and this.rooms[1] <> invalid
        this.guards.Unshift({"room":1, "location":11, "skill":3, "colors":0, "type":"shadow", "direction":1, "active": false, "visible": false})
    else if levelId = 12 and this.rooms[15] <> invalid
        this.guards.Unshift({"room":15, "location":2, "skill":3, "colors":0, "type":"shadow", "direction":1, "active": false, "visible": false})
    end if
    'Add events
    events = xml.GetNamedElements("events").GetChildElements()
    for each event in events
        this.events.Push({number: Val(event@number), room: Val(event@room), location: Val(event@location), next: Val(event@next)})
    next
    'Create rooms layout
    layoutOffset = {tx: 0, ty: 0, bx: 0, by: 0}
    RoomsLayout(this.rooms, Val(prince@room), layoutOffset)
    this.width = layoutOffset.bx - layoutOffset.tx + 1
	this.height = layoutOffset.by - layoutOffset.ty + 1
    print "layout dimensions: "; this.width; " by "; this.height
	dim layout[this.height, this.width]
    for r = 1 to 24
        room = this.rooms[r]
        if room <> invalid and room.layout
            room.x = room.x + Abs(layoutOffset.tx)
            room.y = room.y + Abs(layoutOffset.ty)
            layout[room.y][room.x] = r
            print "layout: "; r; " coord: "; room.x; ","; room.y
        else
            this.rooms[r] = invalid
        end if
    next
    this.layout = layout
    return this
End Function

Sub RoomsLayout(rooms as object, id as integer, offset as object)
    room = rooms[id]
    if room.x < offset.tx then offset.tx = room.x
    if room.y < offset.ty then offset.ty = room.y
    if room.x > offset.bx then offset.bx = room.x
    if room.y > offset.by then offset.by = room.y
    room.layout = true
    if room.links.left > 0 and not rooms[room.links.left].layout
        rooms[room.links.left].x = room.x - 1
        rooms[room.links.left].y = room.y
        RoomsLayout(rooms, room.links.left, offset)
    end if
    if room.links.right > 0 and not rooms[room.links.right].layout
        rooms[room.links.right].x = room.x + 1
        rooms[room.links.right].y = room.y
        RoomsLayout(rooms, room.links.right, offset)
    end if
    if room.links.up > 0 and not rooms[room.links.up].layout
        rooms[room.links.up].x = room.x
        rooms[room.links.up].y = room.y - 1
        RoomsLayout(rooms, room.links.up, offset)
    end if
    if room.links.down > 0 and not rooms[room.links.down].layout
        rooms[room.links.down].x = room.x
        rooms[room.links.down].y = room.y + 1
        RoomsLayout(rooms, room.links.down, offset)
    end if
End Sub
