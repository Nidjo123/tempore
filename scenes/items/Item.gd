extends Node2D


func _ready():
	pass


func picked_up():
	if visible:
		$AudioStreamPlayer2D.play()
		visible = false
