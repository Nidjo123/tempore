extends Node2D


func _input(event):
	if event.is_action_pressed("ui_right"):
		$AnimationPlayer.play("WalkRight")
	if event.is_action_pressed("ui_up"):
		$AnimationPlayer.play("WalkUp")
	if event.is_action_pressed("ui_left"):
		$AnimationPlayer.play("WalkLeft")
	if event.is_action_pressed("ui_down"):
		$AnimationPlayer.play("WalkDown")


func moved():
	$AudioStreamPlayer2D.play()
