extends Button


func _ready():
	grab_focus()


func _on_BackToMainMenuButton_pressed():
	get_tree().change_scene("res://scenes/MainMenu.tscn")
