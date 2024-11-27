extends Node2D

var bricks =[
	preload("res://scenes/square.tscn"),
	preload("res://scenes/circle.tscn"),
	preload("res://scenes/triangle.tscn")
]

var color_options = [
"f59fa2",
"ce4757",
"009bbb",
"009b71",
"9b7f43",
"496778",
"a3ce58"
]
var game_ball_color = "ffffff"
var current_ball_power = 1
var available_bonuses = ["five","vbeam","hbeam", "funnel"]

var balls = preload("res://scenes/ball.tscn")
var extra_ball = preload("res://scenes/extra_ball.tscn")
var five_bonus = preload("res://scenes/five_bonus.tscn")
var v_beam = preload("res://scenes/v_beam.tscn")
var h_beam = preload("res://scenes/h_beam.tscn")
var funnel = preload("res://scenes/funnel.tscn")

var game_speed: int = 1
var brick_location = Vector2(27,189)
var cannon_location = Vector2(270,798) #864 - 8
var end_location = Vector2()
var level = 1
var balls_available = 1
var can_shoot = true
var ball_count = 0
var new_shoot_direction = Vector2()
var min_blocks_per_line = 3
var max_blocks_per_line = 7
var line_assignment = []
var grid = []
var valid_aim = false
var bounce_count = 0
signal update_balls_available
signal update_level

var game_over = false
@onready var line = $line_layer/aim_line
@onready var start_ball = $line_layer/start_ball
@onready var wall = $wall

var first_click = Vector2()
var dragging = false

signal change_background

# Called when the node enters the scene tree for the first time.
func _ready():
	var game_area = wall.get_child(0)
	#print(game_area.Node2d.transform.size)
	grid = make_grid()
	#print(grid)
	make_line()
	#create_field()
	set_start_ball()
	#Engine.time_scale = 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("shoot") and can_shoot:
		first_click = get_global_mouse_position()
		print(first_click)
		if first_click.y > 108 and first_click.y < 810:
			dragging = true
			line.add_point(Vector2(0,0), 0)
			line.add_point(Vector2(0,0), 1)
	if Input.is_action_pressed("shoot") and dragging:
		var line_direction = get_global_mouse_position() - cannon_location
		if valid_angle(line_direction):
			valid_aim = true
			line.set_point_position(0, Vector2(cannon_location.x,cannon_location.y))
			#line.set_point_position(1, line_direction.normalized()*100000)
			$line_layer/start_ball/RayCast2D.target_position = line_direction.normalized()*100000
			
			line.set_point_position(1, $line_layer/start_ball/RayCast2D.get_collision_point())
		else:
			valid_aim = false
	if Input.is_action_just_released("shoot") and can_shoot and valid_aim:
		dragging = false
		valid_aim = false
		line.clear_points()
		shoot_balls(get_global_mouse_position())

func valid_angle(line_direction):
	var reasonable_angle
	if line_direction.normalized().x > -0.998 && line_direction.normalized().x < 0.998 && line_direction.normalized().y < 0:
		return true
	return false

func make_grid():
	var temp_grid = []
	for i in range(11):
		temp_grid.append([])
		for x in range(10):#width
			temp_grid[i].append(0)
	return temp_grid

func create_field():
	for i in range(8):
		for x in range(10):#width
			#var select_brick = randi() % bricks.size()
			var select_brick =0
			var new_brick = bricks[select_brick].instantiate()
			new_brick.position = brick_location
			new_brick.modulate = Color(1, 0.894118, 0.768627, 1)
			new_brick.row = i
			new_brick.column = x
			new_brick.set_health(i)
			add_child(new_brick)
			
			
			brick_location.x += 54
		brick_location.x = 27
		brick_location.y +=54
	#print(grid)

func set_start_ball():
	start_ball.position = cannon_location

func shoot_balls(shoot_direction):
	new_shoot_direction = shoot_direction - cannon_location
	can_shoot = false
	for i in range(balls_available):
		var new_ball = balls.instantiate()
		new_ball.ball_color = game_ball_color
		new_ball.position = cannon_location
		new_ball.ball_power = current_ball_power
		add_child(new_ball)
		ball_count += 1
		$shoot_delay.start()
		await($shoot_delay.timeout)

func show_direction():
	return new_shoot_direction

func damage_column(column):
	var active_bricks = get_tree().get_nodes_in_group("brick")
	for i in active_bricks.size():
		if active_bricks[i].column == column:
			active_bricks[i].take_life(current_ball_power)

func damage_row(row):
	var active_bricks = get_tree().get_nodes_in_group("brick")
	for i in active_bricks.size():
		if active_bricks[i].row == row:
			active_bricks[i].take_life(current_ball_power)

func add_extra_ball(amount):
	balls_available += amount

func count_bounces():
	bounce_count += 1
	if bounce_count == ball_count:
		Globals.bounce_active = false
	

func remove_ball(landing_position):
	start_ball.position.x = landing_position.x
	ball_count -= 1
	if ball_count <= 0:
		end_round()
		cannon_location = start_ball.position
		can_shoot = true

func end_round():
	if Engine.time_scale != 1:
		game_speed = 1
		Engine.time_scale = game_speed
	#reset ball variables
	game_ball_color = "ffffff" 
	current_ball_power = 1
	remove_unused_bonus()
	var active_bricks = get_tree().get_nodes_in_group("brick")
	for i in active_bricks.size():
		active_bricks[i].row += 1
		if active_bricks[i].row == 11:
			game_over = true
			
		else:
			active_bricks[i].move(Vector2(active_bricks[i].position.x,active_bricks[i].position.y+54))
	
	var active_extra = get_tree().get_nodes_in_group("extra")
	for j in active_extra.size():
		active_extra[j].row += 1
		if active_extra[j].row < 11:
			active_extra[j].move(Vector2(active_extra[j].position.x,active_extra[j].position.y+54))
	level += 1
	if game_over:
		$end_game.start()
		game_end()
	else:
		make_line()
		rebuild_grid()
		if randf() > .75:
			add_bonus(available_bonuses[randi() % available_bonuses.size()])
		#level += 1
		emit_signal("update_balls_available", balls_available)
		emit_signal("update_level", level)
		can_shoot = true

func make_line():
	brick_location = Vector2(27,189)
	#create temp array with all blocks
	var temp_array = [1,1,1,1,1,1,1,1,1,1]
	#get number of blocks to create base on min/max values
	var rand_block_count = randi_range(min_blocks_per_line, max_blocks_per_line-1)
	#for the number of blocks to create, randomly assign index 
	#ie: [1,1,0,0,1,0,0,1,0,1] create line with 5 blocks, radomly distrubed
	for i in rand_block_count:
		temp_array[random_block_index(temp_array)] = 0
	
	if randf() > 0.5:
		temp_array[random_empty_index(temp_array)] = 2
	#print(temp_array)
	#then iterate temp array and create blocks at the 1 spaces. 0 is empty spot
	var color_index = randi() % color_options.size()
	for x in range(10):#width
		#var select_brick = randi() % bricks.size()
		if temp_array[x] == 1:
			#var select_brick =
			var select_brick = randi() % bricks.size()
			var new_brick = bricks[select_brick].instantiate()
			brick_location.x += x*54
			new_brick.position = brick_location
			new_brick.modulate = Color(color_options[color_index])
			new_brick.set_health(level)
			new_brick.row = 0
			new_brick.column = x
			add_child(new_brick)
			brick_location.x = 27
			
		if temp_array[x] == 2:
			var new_extra_ball = extra_ball.instantiate()
			brick_location.x += x*54
			new_extra_ball.position = brick_location
			new_extra_ball.row = 0
			new_extra_ball.column = x
			add_child(new_extra_ball)
			brick_location.x = 27
			
	#print(grid)

func random_block_index(array):
	var found = false
	while !found:
		var ran_index = randi_range(0, array.size()-1)
		if array[ran_index] == 1:
			return ran_index

func random_empty_index(array):
	var found = false
	while !found:
		var ran_index = randi_range(0, array.size()-1)
		if array[ran_index] == 0:
			return ran_index	
func rebuild_grid():
	grid = []
	grid = make_grid()
	var active_bricks_g = get_tree().get_nodes_in_group("brick")
	for i in active_bricks_g.size():
		grid[active_bricks_g[i].row][active_bricks_g[i].column] = 1
	var active_extra_g = get_tree().get_nodes_in_group("extra")
	for i in active_extra_g.size():
		grid[active_extra_g[i].row][active_extra_g[i].column] = 2
		
	#print(grid)

func add_bonus(type):
	var new_bonus
	brick_location = Vector2(27,189)
	var slot = find_empty_grid()
	brick_location.x += slot.x*54
	brick_location.y += slot.y*54
	if type == "five":	
		new_bonus = five_bonus.instantiate()
	elif type == "vbeam":
		new_bonus = v_beam.instantiate()
	elif type == "hbeam":
		new_bonus = h_beam.instantiate()
	elif type == "funnel":
		new_bonus = funnel.instantiate()
	
	new_bonus.row = slot.y
	new_bonus.column = slot.x
	new_bonus.position = brick_location
	add_child(new_bonus)
	
	brick_location = Vector2(27,189)
	#new_brick.position = brick_location
	

func remove_unused_bonus():
	for bonus in get_tree().get_nodes_in_group("bonus"):
		bonus.queue_free()

func find_empty_grid():
	var found = false
	while !found:
		var rand_r = randi_range(0, grid.size()-1)
		var rand_c = randi_range(0, grid[0].size()-1)
		if grid[rand_r][rand_c] == 0:
			return Vector2(rand_c,rand_r)
func change_background_color(new_color):
	emit_signal("change_background", new_color)
	 
func game_end():
	await($end_game.timeout)
	get_tree().reload_current_scene()

func _on_texture_button_pressed():
	game_speed = 2
	Engine.time_scale = game_speed


func _on_bounce_button_pressed(): 
	
	if can_shoot:
		change_background_color("ffffff") 
		Globals.bounce_active = true


func _on_double_button_pressed():
	if can_shoot:
		current_ball_power = 2
		game_ball_color = "ff0000"
		Globals.double_active = true


func _on_menu_button_pressed() -> void:
	print("pause game")
