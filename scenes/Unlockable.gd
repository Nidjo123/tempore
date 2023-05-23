extends Node2D


export (String) var unlocked_tile_name = "Exit2"
var unlocked = false


func unlock_tile():
	var level: TileMap = get_parent()
	var map_pos = level.world_to_map(position)
	var tile_id = level.tile_set.find_tile_by_name(unlocked_tile_name)
	level.set_cellv(map_pos, tile_id)
	unlocked = true
	

func is_unlocked():
	return unlocked
