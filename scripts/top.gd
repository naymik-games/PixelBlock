extends Node

signal set_game_speed
signal set_pause_game
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_texture_button_pressed():
	emit_signal("set_game_speed")


func _on_menu_button_pressed() -> void:
	emit_signal("set_pause_game")
