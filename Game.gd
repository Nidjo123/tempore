extends Node2D


export (float) var time_cycle = 10
export (int) var tutorial_levels = 5
export (Array, PackedScene) var level_scenes
export (int) var current_level_idx = 0
var levels: Array


func _ready():
	$HUD/Panel.hide()
	var root_levels_node = find_node("Levels")
	for level_scene in level_scenes:
		var level = level_scene.instance()
		level.set_active(false)
		levels.append(level)
		root_levels_node.add_child(level)
	change_level(current_level_idx)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		show_pause_popup("Game paused.")


func get_current_level():
	return levels[current_level_idx]


func next_level_index(index):
	return (index + 1) % levels.size()


func next_unsolved_level_idx():
	var next_level_idx = next_level_index(current_level_idx)
	while next_level_idx != current_level_idx:
		var level = levels[next_level_idx]
		if not level.is_done():
			break
		next_level_idx = next_level_index(next_level_idx)
	return next_level_idx


func restart_timer():
	var sand_clock = $HUD/SandClockControl/SandClock
	sand_clock.frame = 0
	sand_clock.play("All")
	$Timer.start(time_cycle)


func stop_timer():
	var sand_clock = $HUD/SandClockControl/SandClock
	sand_clock.stop()
	sand_clock.frame = 13


var sounds = {
	"death": preload("res://sound/death.wav"),
	"timeout": preload("res://sound/ticktock.wav"),
}


func play_sound(name):
	$AudioStreamPlayer2D.stream = sounds[name]
	$AudioStreamPlayer2D.play()


func reset_level():
	play_sound("death")
	var levels_node = find_node("Levels")
	var curr_level = get_current_level()
	curr_level.set_active(false)
	var level = level_scenes[current_level_idx].instance()
	levels[current_level_idx] = level
	level.set_active(true)
	levels_node.add_child(level)
	levels_node.remove_child(curr_level)
	curr_level.queue_free()


func show_pause_popup(text):
	get_tree().paused = true
	$HUD/Panel/VBoxContainer/Message.text = text
	$HUD/Panel/VBoxContainer/ContinueButton.grab_focus()
	$HUD/Panel.show()


func change_level(next_level_idx):
	get_current_level().set_active(false)
	var next_level = levels[next_level_idx]
	if not next_level.pre_level_message.empty():
		show_pause_popup(next_level.pre_level_message)
		next_level.pre_level_message = ""
	next_level.set_active(true)
	current_level_idx = next_level_idx
	$HUD/SandClockControl/SandClock.visible = next_level_idx >= tutorial_levels
	$HUD/LevelName.text = next_level.level_name


func all_levels_done():
	for level in levels:
		if not level.is_done():
			return false
	return true


func _process(delta):
	if all_levels_done():
		get_tree().change_scene("res://scenes/End.tscn")
	elif get_current_level().is_done():
		go_to_next_level()


func go_to_next_level():
	if current_level_idx == tutorial_levels - 1:
		restart_timer()
	change_level(next_unsolved_level_idx())


func _on_Timer_timeout():
	var old_idx = current_level_idx
	if current_level_idx >= tutorial_levels:
		go_to_next_level()
	if old_idx != current_level_idx:
		play_sound("timeout")
		restart_timer()
	else:
		stop_timer()


func _on_ContinueButton_pressed():
	$HUD/Panel.hide()
	get_tree().paused = false
