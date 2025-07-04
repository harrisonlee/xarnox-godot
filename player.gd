extends CharacterBody2D

#-------------------------------------------------------------------------------
# Signals
#-------------------------------------------------------------------------------
signal hit


#-------------------------------------------------------------------------------
# Exported Variables
#-------------------------------------------------------------------------------
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


#-------------------------------------------------------------------------------
# Enums
#-------------------------------------------------------------------------------
enum FlyingState { IDLE, CLIMBING, DESCENDING }
enum ShootingDirection { UP, UP_RIGHT, RIGHT, DOWN_RIGHT, DOWN }


#-------------------------------------------------------------------------------
# Exported Variables
#-------------------------------------------------------------------------------
@onready var collision_body: CollisionShape2D = $CollisionShape2D
@onready var muzzle_up: Marker2D = $MuzzleUp
@onready var muzzle_up_right: Marker2D = $MuzzleUpRight
@onready var muzzle_right: Marker2D = $MuzzleRight
@onready var muzzle_down_right: Marker2D = $MuzzleDownRight
@onready var muzzle_down: Marker2D = $MuzzleDown


#-------------------------------------------------------------------------------
# Exported Variables
#-------------------------------------------------------------------------------
var _current_flying_state = FlyingState.IDLE


#-------------------------------------------------------------------------------
# Lifecycle Methods
#-------------------------------------------------------------------------------
func _draw() -> void:
	draw_circle(Vector2.ZERO, 50.0, Color.RED)


func _physics_process(delta: float) -> void:
	get_input()

	var gravity = get_gravity()
	var descent_accel = descent_acceleration
	if use_auto_descent_acceleration:
		descent_accel = climb_acceleration - gravity.y

	match _current_flying_state:
		FlyingState.CLIMBING:
			velocity.y += -climb_acceleration * delta
		FlyingState.DESCENDING:
			velocity.y += (descent_accel + gravity.y) * delta
		FlyingState.IDLE:
			velocity.y += gravity.y * delta

	velocity.x = clampf(velocity.x + acceleration, -speed, speed)

	# Bounce off walls
	var collision = move_and_collide(velocity * delta)
	if collision:
		hit.emit()
		if collision.get_collider().is_in_group("walls"):
			velocity = collision.get_normal() * 400.0
			

func get_input() -> void:
	_current_flying_state = FlyingState.IDLE
	if Input.is_action_pressed("ui_climb"):
		_current_flying_state = FlyingState.CLIMBING
	elif Input.is_action_pressed("ui_descend"):
		_current_flying_state = FlyingState.DESCENDING

	if Input.is_action_just_pressed("ui_shoot_up"):
		_shoot(ShootingDirection.UP)
	elif Input.is_action_just_pressed("ui_shoot_up_right"):
		_shoot(ShootingDirection.UP_RIGHT)
	elif Input.is_action_just_pressed("ui_shoot_right"):
		_shoot(ShootingDirection.RIGHT)
	elif Input.is_action_just_pressed("ui_shoot_down_right"):
		_shoot(ShootingDirection.DOWN_RIGHT)
	elif Input.is_action_just_pressed("ui_shoot_down"):
		_shoot(ShootingDirection.DOWN)
	

#-------------------------------------------------------------------------------
# Private Methods
#-------------------------------------------------------------------------------
func _shoot(shooting_direction: ShootingDirection) -> void:
	var projectile: Projectile = projectile_scene.instantiate()
	var projectile_position: Vector2 = Vector2.ZERO
	var projectile_direction: Vector2 = Vector2.ZERO

	match shooting_direction:
		ShootingDirection.UP:
			projectile_position = muzzle_up.global_position
			projectile_direction = Vector2.UP
		ShootingDirection.UP_RIGHT:
			projectile_position = muzzle_up_right.global_position
			projectile_direction = (Vector2.UP + Vector2.RIGHT).normalized()
		ShootingDirection.RIGHT:
			projectile_position = muzzle_right.global_position
			projectile_direction = Vector2.RIGHT
		ShootingDirection.DOWN_RIGHT:
			projectile_position = muzzle_down_right.global_position
			projectile_direction = (Vector2.DOWN + Vector2.RIGHT).normalized()
		ShootingDirection.DOWN:
			projectile_position = muzzle_down.global_position
			projectile_direction = Vector2.DOWN

	projectile.fire(projectile_position, projectile_direction)
	owner.add_child(projectile)
