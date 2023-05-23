extends HSlider


func get_bus_id(name: String):
	return AudioServer.get_bus_index(name)


func _ready():
	value = AudioServer.get_bus_volume_db(get_bus_id("Master"))


func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(get_bus_id("Master"), value)
	$AudioStreamPlayer.play()
