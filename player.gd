extends CharacterBody2D

const CLIMB_VELOCITY = -3000.0
const DESCEND_VELOCITY = 2200.0

enum FlyingState { IDLE, CLIMBING, DESCENDING }
var currentFlyingState = FlyingState.IDLE

@onready var collision_body: CollisionShape2D = $CollisionShape2D
var screen_size: Vector2

func _draw() -> void:
	draw_circle(Vector2.ZERO, 50.0, Color.RED)
	screen_size = get_viewport_rect().size



func get_input() -> void:
	currentFlyingState = FlyingState.IDLE
	if Input.is_action_pressed("ui_climb"):
		currentFlyingState = FlyingState.CLIMBING
	elif Input.is_action_pressed("ui_descend"):
		currentFlyingState = FlyingState.DESCENDING

	print(currentFlyingState)


func _physics_process(delta: float) -> void:
	get_input();
	var gravity = get_gravity();

	if currentFlyingState == FlyingState.CLIMBING:
		velocity.y += CLIMB_VELOCITY * delta
	elif currentFlyingState == FlyingState.DESCENDING:
		velocity.y += (DESCEND_VELOCITY + gravity.y) * delta
	else:
		velocity.y += gravity.y * delta

	velocity.x = 0

	# Bounce off top and bottom of screen
	var viewport_size = get_viewport_rect().size
	if position.y - 50 <= 0:
		velocity.y = 200
	elif position.y + 50 >= viewport_size.y:
		velocity.y = -200

	move_and_collide(velocity * delta)
	
