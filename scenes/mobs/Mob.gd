extends Node2D


func _ready():
	$AnimationPlayer.play("MobDown")


func mob_moved(offset):
	var animation = {
		Vector2.RIGHT: "MobRight",
		Vector2.UP: "MobUp",
		Vector2.LEFT: "MobLeft",
		Vector2.DOWN: "MobDown"}[offset]
	$AnimationPlayer.play(animation)
		
