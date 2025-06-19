extends CharacterBody2D

## Climbing acceleration in px/s.
@export var climb_acceleration: float = 3000.0
## Use descent acceleration as function of climb accel minus gravity. Note,
## descent custom descent acceleration is ignore if this is true.
@export var use_auto_descent_acceleration: bool = true
## Descent acceleration in px/s. Ignored if use auto descent acceleration is
## true.
@export var descent_acceleration: float = 0.0

enum FlyingState { IDLE, CLIMBING, DESCENDING }

var screen_size: Vector2
var current_flying_state = FlyingState.IDLE
@onready var collision_body: CollisionShape2D = $CollisionShape2D


func _draw() -> void:
	draw_circle(Vector2.ZERO, 50.0, Color.RED)
	screen_size = get_viewport_rect().size


func get_input() -> void:
	current_flying_state = FlyingState.IDLE
	if Input.is_action_pressed("ui_climb"):
		current_flying_state = FlyingState.CLIMBING
	elif Input.is_action_pressed("ui_descend"):
		current_flying_state = FlyingState.DESCENDING


func _physics_process(delta: float) -> void:
	get_input();

	var gravity = get_gravity();
	var descent_accel = descent_acceleration
	if use_auto_descent_acceleration:
		descent_accel = climb_acceleration - gravity.y

	match current_flying_state:
		FlyingState.CLIMBING:
			velocity.y += -climb_acceleration * delta
		FlyingState.DESCENDING:
			velocity.y += (descent_accel + gravity.y) * delta
		FlyingState.IDLE:
			velocity.y += gravity.y * delta

	velocity.x = 0

	# Bounce off top and bottom of screen
	var viewport_size = get_viewport_rect().size
	if position.y - 50 <= 0:
		velocity.y = 200
	elif position.y + 50 >= viewport_size.y:
		velocity.y = -200

	move_and_collide(velocity * delta)
	
