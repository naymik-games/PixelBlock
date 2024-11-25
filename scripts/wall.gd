extends StaticBody2D
@onready var color_rect = $ColorRect

 


func _on_game_change_background(new_color):
	color_rect.color = Color(new_color)
	pass # Replace with function body.
