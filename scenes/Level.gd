extends TileMap

export (String) var level_name
export (String, MULTILINE) var pre_level_message
export (bool) var lights_on = true

var done = false
var active = false

var astar: AStar2D

var sounds = {
	"enter_hole": preload("res://sound/enter_hole.wav"),
	"death": preload("res://sound/death.wav")
}

var action_pressed := {
	"ui_right": false,
	"ui_up": false,
	"ui_left": false,
	"ui_down": false,
}
var time_since_last_move: float = 0.0
export (float) var move_cycle = 0.2


func _ready():
	for child in get_children():
		move_object_to(child, world_to_map(child.position))
	build_astar()
	update_lights()


func update_lights():
	$CanvasModulate.visible = not lights_on
	$Player/Light.enabled = not lights_on


func get_tile_id(tile_pos):
	var bounds: Rect2 = get_used_rect()
	var offset = tile_pos - bounds.position
	return offset.y * bounds.size.x + offset.x


func build_astar():
	var rect := get_used_rect()
	astar = AStar2D.new()
	var used_cells = get_used_cells()
	# first add all points
	for cell_pos in used_cells:
		var cell_id = get_tile_id(cell_pos)
		assert(cell_id >= 0 and cell_id < rect.size.x * rect.size.y)
		if cell_id >= 0 and can_move_to(cell_pos):
			astar.add_point(cell_id, cell_pos)
	
	# then connect them
	var neighbor_offsets = [Vector2.RIGHT, Vector2.DOWN]
	for cell_pos in used_cells:
		if not can_move_to(cell_pos):
			continue
		var cell_id = get_tile_id(cell_pos)
		for offset in neighbor_offsets:
			var neighbor_pos = cell_pos + offset
			if not rect.has_point(neighbor_pos):
				continue
			if can_move_to(neighbor_pos):
				var neighbor_id = get_tile_id(neighbor_pos)
				astar.connect_points(cell_id, neighbor_id)


func move_player(action_name):
	var player_pos = world_to_map($Player.position)
	if action_name == "ui_right":
		player_pos += Vector2.RIGHT
	elif action_name == "ui_up":
		player_pos += Vector2.UP
	elif action_name == "ui_left":
		player_pos += Vector2.LEFT
	elif action_name == "ui_down":
		player_pos += Vector2.DOWN
	
	if try_move_object_to($Player, player_pos):
		$Player.moved()
		move_mobs_towards(player_pos)


func _input(event):
	return
	if not active:
		return
	for action_name in action_pressed.keys():
		if event.is_action_pressed(action_name):
			time_since_last_move = 0.0
			if not action_pressed[action_name]:
				move_player(action_name)
			action_pressed[action_name] = true
			for other_action_name in action_pressed.keys():
				if other_action_name != action_name:
					action_pressed[other_action_name] = false
			break
		elif event.is_action_released(action_name):
			action_pressed[action_name] = false


func move_mobs_towards(goal_pos):
	for child in get_children():
		if child.is_in_group("Mobs"):
			move_object_towards(child, goal_pos)


func move_object_towards(object, goal_pos):
	var obj_pos = world_to_map(object.position)
	var start_id = get_tile_id(obj_pos)
	var end_id = get_tile_id(goal_pos)
	var path = astar.get_point_path(start_id, end_id)
	if path.size() > 1:
		move_object_to(object, path[1])
		object.mob_moved(path[1] - obj_pos)


func get_tile_name_at(pos) -> String:
	var cell_id := get_cellv(pos)
	if cell_id != INVALID_CELL:
		return tile_set.tile_get_name(cell_id)
	return ""


func items_at_player_tile():
	var player_pos = world_to_map($Player.position)
	var items := []
	for child in get_children():
		if not child.is_in_group("Items"):
			continue
		var item_pos = world_to_map(child.position)
		if item_pos == player_pos:
			items.append(child)
	return items


func can_move_to(pos):
	var name = get_tile_name_at(pos)
	return name != "" and not name.begins_with("Wall")


func move_object_to(object, map_pos):
	object.position = map_to_world(map_pos) + cell_size / 2


func get_mobs_at_pos(map_pos):
	var mobs = []
	for child in get_children():
		if child.is_in_group("Mobs") and world_to_map(child.position) == map_pos:
			mobs.append(child)
	return mobs
	

func try_move_object_to(object, map_pos) -> bool:
	var obj_map_pos = world_to_map(object.position)
	var mobs = get_mobs_at_pos(map_pos)
	if obj_map_pos != map_pos and can_move_to(map_pos) and (mobs.size() == 0 or object == $Player):
		move_object_to(object, map_pos)
		return true
	return false


func is_done():
	return done


func set_active(is_active):
	if is_done():
		is_active = false
	active = is_active
	active_changed()


func active_changed():
	visible = active
	set_process_input(active)
	set_process_internal(active)
	set_process_unhandled_input(active)
	set_process_unhandled_key_input(active)
	if active:
		$Player/Camera.make_current()
	time_since_last_move = 0.0
	for action_name in action_pressed.keys():
		action_pressed[action_name] = false


func play_sound(sound_name):
	$AudioStreamPlayer2D.stream = sounds[sound_name]
	$AudioStreamPlayer2D.play()


func _process(delta):
	if not active:
		return
	
	for action_name in action_pressed.keys():
		if Input.is_action_pressed(action_name):
			if not action_pressed[action_name]:
				time_since_last_move = 0.0
				move_player(action_name)
			action_pressed[action_name] = true
			for other_action_name in action_pressed.keys():
				if other_action_name != action_name:
					action_pressed[other_action_name] = false
			break
		elif Input.is_action_just_released(action_name):
			action_pressed[action_name] = false
		
	if action_pressed.values().has(true):
		time_since_last_move += delta
		while time_since_last_move >= move_cycle:
			time_since_last_move -= move_cycle
			for action_name in action_pressed.keys():
				if action_pressed[action_name]:
					move_player(action_name)
	var player_pos = world_to_map($Player.position)
	var player_tile_name = get_tile_name_at(player_pos)
	if get_mobs_at_pos(player_pos).size() != 0:
		get_node('/root/Game').reset_level()
	if player_tile_name.begins_with("Exit"):
		play_sound("enter_hole")
		done = true
	for item in items_at_player_tile():
		item.picked_up()
