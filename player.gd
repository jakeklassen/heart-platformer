extends CharacterBody2D

@export var movement_data: PlayerMovementData

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer

func _process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()

	var direction := Input.get_axis("left", "right")
	handle_acceleration(direction, delta)
	apply_friction(direction, delta)
	apply_air_resistance(direction, delta)
	update_animations(direction)

	# Track if we're on the floor BEFORE we move
	var was_on_floor = is_on_floor()

	move_and_slide()

	# We were on the floor, after moving we are not, but we're also "falling"
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()

func apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta

func handle_jump():
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.jump_velocity

	if not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2

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
