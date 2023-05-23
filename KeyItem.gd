extends "scenes/items/Item.gd"


export (NodePath) var unlocks_node


func _process(delta):
	position.y += sin(OS.get_ticks_msec() / 200.0) / 10.0


func picked_up():
	.picked_up()
	get_node(unlocks_node).unlock_tile()
