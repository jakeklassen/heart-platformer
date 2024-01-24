extends CharacterBody2D

@export var movement_data: PlayerMovementData

var air_jump: bool = false
var just_wall_jumped: bool = false
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_wall_normal = Vector2.ZERO

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
@onready var wall_jump_timer: Timer = $WallJumpTimer
@onready var starting_position = global_position

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_wall_jump()
	handle_jump()

	var direction := Input.get_axis("left", "right")
	handle_acceleration(direction, delta)
	apply_friction(direction, delta)
	apply_air_resistance(direction, delta)

	# Track if we're on the floor BEFORE we move
	var was_on_floor = is_on_floor()
	var was_on_wall = is_on_wall_only()

	if was_on_floor:
		last_wall_normal = get_wall_normal()

	move_and_slide()

	# We were on the floor, after moving we are not, but we're also "falling"
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()

	just_wall_jumped = false

	var just_left_wall = was_on_wall and not is_on_wall_only()
	if just_left_wall:
		wall_jump_timer.start()

	# Update animations last, after all input has been processed
	update_animations(direction)

func apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta

func handle_wall_jump():
	if not is_on_wall_only() and wall_jump_timer.time_left <= 0: return

	var wall_normal = get_wall_normal()
	if wall_jump_timer.time_left > 0.0:
		wall_normal = last_wall_normal

	if Input.is_action_just_pressed("jump"):
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity
		just_wall_jumped = true

func handle_jump():
	if is_on_floor():
		air_jump = true

	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.jump_velocity
			coyote_jump_timer.stop()
	elif not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2

		if Input.is_action_just_pressed("jump") and air_jump and not just_wall_jumped:
			velocity.y = movement_data.jump_velocity * 0.8
			air_jump = false

func handle_acceleration(input_axis: float, delta: float):
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)

func apply_friction(input_axis: float, delta: float):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_air_resistance(input_axis: float, delta: float):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)

func update_animations(input_axis: float):
	if input_axis != 0:
		animated_sprite_2d.flip_h = input_axis < 0
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

	if not is_on_floor():
		animated_sprite_2d.play("jump")


func _on_hazard_detector_area_entered(area: Area2D) -> void:
	global_position = starting_position
