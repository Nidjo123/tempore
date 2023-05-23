extends Polygon2D

export (float) var update_timer_poly = 0.02
export (float) var radius = 50.0
var passed: float = 0
var percentage_left: float = 1


func make_arc_poly(percentage: float, nb_points: int):
	var poly = PoolVector2Array()
	poly.push_back(Vector2(0, 0))
	for i in range(nb_points):
		var angle = i * percentage * 2 * PI / nb_points
		var point = Vector2(cos(angle), sin(angle)) * radius
		poly.push_back(point)
	return poly


func _draw():
	var points = make_arc_poly(percentage_left, max(32.0 * percentage_left, 6.0))
	var color = Color(0.8, 0.1, 0.1)
	draw_colored_polygon(points, color)


func _process(delta):
	passed += delta
	if passed >= update_timer_poly:
		passed -= update_timer_poly
		var timer = get_node("../../Timer")
		percentage_left = timer.time_left / timer.wait_time
		
