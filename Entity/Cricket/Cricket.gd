extends Actor

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var is_flip = false

onready var _critket = $Critket

onready var _ani_tree = $AnimationTree
onready var _ani_playback = $AnimationTree.get("parameters/playback")
onready var _idle_blend_pos = $AnimationTree.get("parameters/Idle/blend_position")
onready var _run_blend_pos = $AnimationTree.get("parameters/Idle/blend_position")
onready var _melee_blend_pos = $AnimationTree.get("parameters/Melee/blend_position")


func _physics_process(delta):
	var is_attacking = false
	var is_jump_interrupted: = Input.is_action_just_released("jump") and _velocity.y < 0.0
	var direction: = get_direction()
	if Input.is_action_just_pressed("melee"):
		direction = Vector2.ZERO
		is_attacking = true
	if direction == Vector2.ZERO:
		if !is_attacking:
			_ani_playback.travel("Idle")
		else:
			print("attack")
			_ani_playback.travel("Melee")
	else:
		_idle_blend_pos = direction
		_run_blend_pos = direction
		_melee_blend_pos = direction
		_ani_playback.travel("Running")
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	var snap: Vector2 = transform.y * 10 if direction.y == 0.0 else Vector2.ZERO
	#if is_on_floor():
	#	rotation = get_floor_normal().angle() + PI/2
	#_velocity.x *= delta*80
	_velocity = move_and_slide_with_snap(
		_velocity#.rotated(rotation)
		, snap, -transform.y, true
	)
	#_velocity = _velocity.rotated(-rotation)

func _input(event):
	var direction: = get_direction()
	var current_flip = direction.x > 0
	if current_flip != is_flip && direction.x != 0:
		is_flip = current_flip
	_critket.set_flip_h( is_flip )
	if is_flip:
		_critket.offset = Vector2(56,0)
	else:
		_critket.offset = Vector2(0,0)
	

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
	if direction.y != 0.0:
		velocity.y = speed.y * direction.y
	if is_jump_interrupted:
		velocity.y = 0.0
	return velocity
