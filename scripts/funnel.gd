extends Area2D

var row = 0
var column = 0
var type = "funnel"
var left = true

func _on_body_entered(body):
	if body.is_in_group("ball"):
		body.set_linear_velocity(Vector2(0,0))
		left = !left
		if left:
			body.apply_central_impulse(Vector2(-1,-1))
		else:
			body.apply_central_impulse(Vector2(1,-1))
			
