extends CharacterBody2D

signal hit

## Climbing acceleration in px/s.
@export var climb_acceleration: float = 3000.0
## Use descent acceleration as function of climb accel minus gravity. Note,
## descent custom descent acceleration is ignore if this is true.
@export var use_auto_descent_acceleration: bool = true
## Descent acceleration in px/s. Ignored if use auto descent acceleration is
## true.
@export var descent_acceleration: float = 0.0
## Speed for map traversal in px/s.
@export var speed: float = 200.0
## Acceleration to reach speed in px/s.
@export var acceleration: float = 10.0
## Velocity to bounce off walls.
@export var bounce_velocity: float = 400.0
## A scene that represents the current projectile
@export var projectile_scene: PackedScene = preload("res://projectile.tscn")

enum FlyingState { IDLE, CLIMBING, DESCENDING }
enum ShootingDirection { UP, UP_RIGHT, RIGHT, DOWN_RIGHT, DOWN }

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

	if Input.is_action_just_pressed("ui_shoot_up"):
		shoot(ShootingDirection.UP)
	elif Input.is_action_just_pressed("ui_shoot_up_right"):
		shoot(ShootingDirection.UP_RIGHT)
	elif Input.is_action_just_pressed("ui_shoot_right"):
		shoot(ShootingDirection.RIGHT)
	elif Input.is_action_just_pressed("ui_shoot_down_right"):
		shoot(ShootingDirection.DOWN_RIGHT)
	elif Input.is_action_just_pressed("ui_shoot_down"):
		shoot(ShootingDirection.DOWN)


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

	velocity.x = clampf(velocity.x + acceleration, -speed, speed)

	# Bounce off top and bottom of screen
	var viewport_size = get_viewport_rect().size
	if position.y - 50 <= 0:
		velocity.y = 200
	elif position.y + 50 >= viewport_size.y:
		velocity.y = -200

	# Bounce off walls
	var collision = move_and_collide(velocity * delta)
	if collision:
		hit.emit()
		if collision.get_collider().is_in_group("walls"):
			velocity = collision.get_normal() * 400.0
			
	
func shoot(shooting_direction: ShootingDirection) -> void:
	var projectile: Projectile = projectile_scene.instantiate()
	var projectile_position: Vector2 = Vector2.ZERO
	var projectile_direction: Vector2 = Vector2.ZERO

	match shooting_direction:
		ShootingDirection.UP:
			projectile_position = $MuzzleUp.global_position
			projectile_direction = Vector2.UP
		ShootingDirection.UP_RIGHT:
			projectile_position = $MuzzleUpRight.global_position
			projectile_direction = (Vector2.UP + Vector2.RIGHT).normalized()
		ShootingDirection.RIGHT:
			projectile_position = $MuzzleRight.global_position
			projectile_direction = Vector2.RIGHT
		ShootingDirection.DOWN_RIGHT:
			projectile_position = $MuzzleDownRight.global_position
			projectile_direction = (Vector2.DOWN + Vector2.RIGHT).normalized()
		ShootingDirection.DOWN:
			projectile_position = $MuzzleDown.global_position
			projectile_direction = Vector2.DOWN

	projectile.fire(projectile_position, projectile_direction)
	owner.add_child(projectile)
