' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: July 2016
' **  Updated: September 2019
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function build_custom(levelId as integer, modObj as object) as object
    DefaultLevelTypes = [0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0]
    DefaultEnemies = [ "", "guard", "guard", "guard", "guard", "guard", "fatguard", "guard", "guard", "guard", "guard", "guard", "guard", "vizier", "", "" ]
    if levelId = 12
        xmlFile = "level12a.xml"
    else if levelId = 13
        xmlFile = "level12b.xml"
    else if levelId = 14
        xmlFile = "princess.xml"
    else
        xmlFile = "level" + levelId.toStr() + ".xml"
    end if
    modPath = modObj.url + modObj.path
    if Left(modPath, 3) = "pkg" then modPath = modPath + "levels/"
    rsp = ReadAsciiFile(modPath + xmlFile)
    if modObj.levelTypes <> invalid then DefaultLevelTypes = modObj.levelTypes
    if modObj.guards <> invalid then DefaultEnemies = modObj.guards
    xml = CreateObject("roXMLElement")
    if not xml.Parse(rsp)
        print "Invalid xml for level "; levelId; " "; modPath + xmlFile
        return invalid
    end if
    'Create new level object
	this = CreateLevel(levelId, "Custom Level", DefaultLevelTypes[levelId])
    this.guards = []
    this.events = []
	m.level = this
    m.type = DefaultLevelTypes[levelId]
    'Add Prince
    prince = xml.GetNamedElements("prince").Simplify()
    prattr = prince.GetAttributes()
    this.prince = {room: Val(prattr["room"]), location: Val(prattr["location"]), direction: Val(prattr["direction"]) - 1}
	'Build level
    xmlRooms = xml.GetNamedElements("rooms").GetChildElements()
    for each xmlRoom in xmlRooms
        xmlRomAt = xmlRoom.GetAttributes()
        xmlTiles = xmlRoom.GetNamedElements("tile")
        xmlTilAt = xmlTiles.GetAttributes()
        xmlGuard = xmlRoom.GetNamedElements("guard").Simplify()
        xmlGrdAt = xmlGuard.GetAttributes()
        xmlLinks = xmlRoom.GetNamedElements("links").Simplify()
        xmlLnkAt = xmlLinks.GetAttributes()        
        id = Val(xmlRomAt[number])
        rmlnk = {hideUp: false, hideLeft: false, leftZ: 5}
        if xmlLnkAt["left"] > "0"
            rmlnk.left = Val(xmlLnkAt["left"])
        else
            rmlnk.left = -1
        end if
        if xmlLnkAt["right"] > "0"
            rmlnk.right = Val(xmlLnkAt["right"])
        else
            rmlnk.right = -1
        end if
        if xmlLnkAt["up"] > "0"
            rmlnk.up = Val(xmlLnkAt["up"])
        else
            rmlnk.up = -1
        end if
        if xmlLnkAt["down"] > "0"
            rmlnk.down = Val(xmlLnkAt["down"])
        else
            rmlnk.down = -1
        end if
        if rmlnk.left > 0 or rmlnk.right > 0 or rmlnk.up > 0 or rmlnk.down > 0 or this.prince.room = id
            this.rooms[id] = {x: 0, y: 0, links: {}, up: [], left: [], right: [], tiles: [], layout: false}
            this.rooms[id].links = rmlnk
            'Add tiles
            for each xmlTile in xmlTiles
                tl = {element: Val(xmlTilAt["element"]) and &h1F, modifier: Val(xmlTilAt["modifier"])}
                if tl.element = m.const.TILE_WALL
                    if tl.modifier > 1
                        tl.modifier = 0
                    end if
                else if tl.element = m.const.TILE_SPACE
                    if tl.modifier = 255
                        tl.modifier = 0
                    end if
                else if tl.element = m.const.TILE_FLOOR
                    if tl.modifier = 3
                        tl.modifier = 2
                    else if tl.modifier = 255
                        if m.type = m.const.TYPE_DUNGEON
                            tl.modifier = 0
                        else
                            tl.modifier = 2
                        end if
                    end if
                else if tl.element = m.const.TILE_LOOSE_BOARD
                    'Set modifier to 1 for stuck loose tile
                    if Val(xmlTilAt["element"]) = 43
                        tl.modifier = 1
                    else
                        tl.modifier = 0
                    end if
                else if tl.element = m.const.TILE_GATE
                    if tl.modifier = 2
                        tl.modifier = 0
                    end if
                end if
                this.rooms[id].tiles.Push(tl)
            next
            'Add Palace Wall Pattern
            if this.type = m.const.TYPE_PALACE
                this.rooms[id].wallPattern = GenerateWallPattern(id)
            end if
            'Add Guard
            if Val(xmlGrdAt["location"]) > 0 and Val(xmlGrdAt["location"]) < 31
                colors = Val(xmlGrdAt["colors"])
                if colors < 1 or colors > 7
                    colors = 1
                end if
                direction = Val(xmlGrdAt["direction"])
                if direction = 2
                    direction = 0
                end if
                gd = { room: id,
                       location: Val(xmlGrdAt["location"]),
                       skill: Val(xmlGrdAt["skill"]),
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
        evtAttr = event.GetAttributes()
        this.events.Push({ number: Val(evtAttr["number"]),
                           room: Val(evtAttr["room"]), 
                           location: Val(evtAttr["location"]),
                           next: Val(evtAttr["next"])})
    next
    'Create rooms layout
    layoutOffset = {tx: 0, ty: 0, bx: 0, by: 0}
    RoomsLayout(this.rooms, Val(prattr["room"]), layoutOffset)
    this.width = layoutOffset.bx - layoutOffset.tx + 1
	this.height = layoutOffset.by - layoutOffset.ty + 1
    print "layout dimensions: "; this.width; " by "; this.height
	'dim layout[this.height, this.width]
    layout = []
    for r = 1 to 24
        layout.push([0])
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
