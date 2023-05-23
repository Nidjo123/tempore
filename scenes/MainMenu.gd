extends Control

func _ready():
	$VBoxContainer/StartButton.grab_focus()

func _on_StartButton_pressed():
	get_tree().change_scene("res://scenes/Game.tscn")


func _on_OptionsButton_pressed():
	get_tree().change_scene("res://scenes/Options.tscn")


func _on_ExitButton_pressed():
	get_tree().quit()
