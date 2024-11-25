extends StaticBody2D

var row = 0
var column = 0
var brick_health = 15
var brick_life
# Called when the node enters the scene tree for the first time.
func _ready():
	#brick_life = randi() % brick_health +1
	#$brick_life_label.text = str(brick_life)
	#$brick_life_label.text = str(column)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func set_health(value):
	brick_life = value
	$brick_life_label.text = str(value)
func take_life(power):
	brick_life -= power
	$brick_life_label.text = str(brick_life)
	if brick_life < 1:
		queue_free()
	else:
		#var tween = get_tree().create_tween()
		var tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector2(.8,.8), 0.05)
		tween.tween_property(self, "scale", Vector2(1,1), 0.05)
		#tween.tween_property(self,"scale",.9, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
func move(target):
	var tween = get_tree().create_tween()
	tween.tween_property(self,"position",target, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	#$brick_life_label.text = str(row)
