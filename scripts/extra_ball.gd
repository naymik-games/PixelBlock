extends Area2D
var row = 0
var column = 0
var value = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func move(target):
	var tween = get_tree().create_tween()
	tween.tween_property(self,"position",target, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_body_entered(body):
	if body.is_in_group("ball"):
		get_parent().add_extra_ball(value)
		queue_free()
