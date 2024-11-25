extends Node

@onready var balls_label = $NinePatchRect/MarginContainer2/ball_label
@onready var level_label = $NinePatchRect/MarginContainer/level_label
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_game_update_balls_available(amount):
	balls_label.text = "x" + str(amount)


func _on_game_update_level(amount):
	level_label.text = str(amount)
