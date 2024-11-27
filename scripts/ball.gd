extends RigidBody2D
@onready var sprite_2d = $Sprite2D
var ball_color = "000000"
var ball_power = 1
var ball_speed = 1000
var shoot_direction = Vector2()
var velocity_threshold = 10.0 # Adjust as needed to detect flatness
var bounce_boost = 50.0 # Adjust to add some directionality to flat bounces
# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_2d.modulate = Color(ball_color)
	shoot_direction = get_parent().show_direction()
	apply_central_impulse(shoot_direction)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _integrate_forces(state):
	if state.linear_velocity.length() < ball_speed:
		state.linear_velocity = state.linear_velocity.normalized()*ball_speed
	var velocity = state.get_linear_velocity()
	#if abs(velocity.x) < velocity_threshold:
		#velocity.x += bounce_boost * sign(randf() - 0.5) # Randomly adjust X direction
	if abs(velocity.y) < velocity_threshold:
		velocity.y += bounce_boost * sign(randf() - 0.5) # Randomly adjust Y direction

	# Apply the modified velocity
	state.set_linear_velocity(velocity)
func _on_body_entered(body):
	if body.is_in_group("brick"):
		body.take_life(ball_power)
	if body.is_in_group("bottom"):
		if Globals.bounce_active:
			get_parent().count_bounces()
		else:
			get_parent().change_background_color("000000")
			get_parent().remove_ball(position)
			queue_free()
	
