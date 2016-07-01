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

Function CreateTile(element as integer, modifier as integer, levelType as integer) as object
    tile = {}
	'constants
    tile.const = m.const
	'properties
    tile.element = element
    tile.modifier = modifier
    tile.type = levelType
    if tile.type = m.const.TYPE_DUNGEON
        tile.key = "dungeon"
    else
        tile.key = "palace"
    end if
    tile.x = 0
	tile.y = 0
	tile.width = tile.const.BLOCK_WIDTH
	tile.height = tile.const.BLOCK_HEIGHT
    tile.cropY = 0
    tile.back  = tile.key + "_" + itostr(element)
    tile.front = tile.key + "_" + itostr(element) + "_fg"
    tile.child = {back: {x:0, y:0, visible: true}, front:{x:0, y:0, visible: true}}
    tile.isMasked = false
    tile.redraw = false
    tile.hasObject = false
    'methods
    tile.isWalkable = is_walkable
    tile.isSpace = is_space
    tile.isBarrier = is_barrier
    tile.isExitDoor = is_exit_door
    tile.isTrob = is_trob
    tile.isMob = is_mob
    tile.setMask = set_mask
    tile.getBounds = get_tile_bounds
	tile.intersects = intersects_tile
	tile.update = update_tile

    return tile
End Function

Sub set_mask(masked as boolean)
    m.isMasked = masked
    m.redraw = true
End Sub

Function is_walkable() as boolean
    return (m.element <> m.const.TILE_WALL) and (m.element <> m.const.TILE_SPACE) and (m.element <> m.const.TILE_TOP_BIG_PILLAR) and (m.element <> m.const.TILE_TAPESTRY_TOP) and (m.element <> m.const.TILE_LATTICE_SUPPORT) and (m.element <> m.const.TILE_SMALL_LATTICE) and (m.element <> m.const.TILE_LATTICE_LEFT) and (m.element <> m.const.TILE_LATTICE_RIGHT)
End Function

Function is_space() as boolean
    return (m.element = m.const.TILE_SPACE) or (m.element = m.const.TILE_TOP_BIG_PILLAR) or (m.element = m.const.TILE_TAPESTRY_TOP) or (m.element = m.const.TILE_LATTICE_SUPPORT) or (m.element = m.const.TILE_SMALL_LATTICE) or (m.element = m.const.TILE_LATTICE_LEFT) or (m.element = m.const.TILE_LATTICE_RIGHT)
End Function

Function is_barrier() as boolean
    return m.element = m.const.TILE_WALL or m.element = m.const.TILE_GATE or m.element = m.const.TILE_TAPESTRY or m.element = m.const.TILE_TAPESTRY_TOP or m.element = m.const.TILE_MIRROR
End Function

Function is_trob() as boolean
    return (m.element = m.const.TILE_GATE or m.element = m.const.TILE_RAISE_BUTTON or m.element = m.const.TILE_DROP_BUTTON or m.element = m.const.TILE_SPIKES or m.element = m.const.TILE_SWORD or m.element = m.const.TILE_SLICER or m.element = m.const.TILE_EXIT_RIGHT or m.element = m.const.TILE_POTION or m.element = m.const.TILE_TORCH)
End Function

Function is_mob() as boolean
    return (m.element = m.const.TILE_LOOSE_BOARD)
End Function

Function is_exit_door() as boolean
    return (m.element = m.const.TILE_EXIT_LEFT or m.element = m.const.TILE_EXIT_RIGHT)
End Function

Function get_tile_bounds()
    bounds = {}
    bounds.height = 63
    bounds.width = 4
    bounds.x = m.x + 40
    bounds.y = m.y
    return bounds
End Function

Function intersects_tile(bounds as object)
    b = m.getBounds()
    return (b.x + b.width) > bounds.x and b.x < (bounds.x + bounds.width) and (b.y + b.height) > bounds.y and b.y < (bounds.y + bounds.height)
End Function

Sub update_tile()
    'to be implemented on animated tiles (gate, slicer, spikes etc.)
    return
End Sub
