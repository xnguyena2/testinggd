extends Actor


var is_flip = true

var is_attacking = false

var is_jump_interrupted = false
var is_jumping = false

onready var _critket = $Critket

onready var _ani_tree = $AnimationTree
onready var _ani_playback = $AnimationTree.get("parameters/playback")


func _physics_process(delta):
	var direction: = get_direction()
	
	if is_attacking:
		if is_on_floor():
			direction = Vector2.ZERO
		_ani_playback.travel("Melee")
	elif is_jumping:
		_ani_playback.travel("Jumping")
		print("Jumping")
	elif direction.x != 0:
		_ani_playback.travel("Running")
		print("Running")
	else:
		_ani_playback.travel("Idle")
		print("Idle")
		
	
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	var snap: Vector2 = transform.y * 10 if direction.y == 0.0 else Vector2.ZERO
	#if is_on_floor():
	#	rotation = get_floor_normal().angle() + PI/2
	#_velocity.x *= delta*80
	#rotation+=delta
	_velocity = move_and_slide_with_snap(
		_velocity#.rotated(rotation)
		, snap, -transform.y, true
	)
	#_velocity = _velocity.rotated(-rotation)
	
	is_jump_interrupted = false

func _unhandled_key_input(event):
	is_jump_interrupted = event.is_action_released("jump") and _velocity.y < 0.0
	
	var direction_X = event.get_action_strength("move_right") - event.get_action_strength("move_left")
	var current_flip = direction_X > 0
	if current_flip != is_flip && direction_X != 0:
		is_flip = current_flip
	_critket.set_flip_h( is_flip )
	if !is_jumping:
		if is_flip:
			_critket.offset = Vector2(56,0)
		else:
			_critket.offset = Vector2(0,0)
		
	print(direction_X)
	if direction_X != 0:
		_ani_tree.set("parameters/Jumping/blend_position", Vector2(direction_X, 0))
		_ani_tree.set("parameters/RESET/blend_position", Vector2(direction_X, 0))

	if Input.is_action_just_pressed("melee"):
		is_attacking = true

func _ani_melee_finished():
	is_attacking = false

func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-Input.get_action_strength("jump") if is_on_floor() and Input.is_action_just_pressed("jump") else 0.0
	)
	
	
func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		speed: Vector2,
		is_jump_interrupted: bool
	) -> Vector2:
	var velocity: = linear_velocity
	velocity.x = speed.x * direction.x
	
	if is_jump_interrupted:
		velocity.y = 0.0
	elif direction.y != 0.0:
		velocity.y = speed.y * direction.y
		
	return velocity


func _on_GroundDetector_body_exited(body):
	if body.get_name() == "TileMap":
		print("Jump up")
		is_jumping = true


func _on_GroundDetector_body_entered(body):
	if body.get_name() == "TileMap":
		print("Landing")
		is_jumping = false
