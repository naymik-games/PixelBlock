extends Area2D

var row = 0
var column = 0
var type = "vbeam"

func _on_body_entered(body):
	if body.is_in_group("ball"):
		get_parent().damage_column(column)
		
