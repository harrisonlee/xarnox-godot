class_name FlyingEnemy extends Enemy

## An enemy that flies across the screen horizontally while avoiding terrain.
## It oscillates vertically to simulate flying.

#-------------------------------------------------------------------------------
# Exported Variables
#-------------------------------------------------------------------------------
## The speed this node horizontally in px/s.
@export var speed: float = 300.0
## Acceleration in px/s. A value of 0.0 uses no acceleration.
@export var acceleration: float = 0.0
## The time it takes to complete a direction change. Smaller values are faster.
@export var oscillation_time: float = 0.5
## The intensity of the oscillation. Larger numbers yield greater distance.
@export var oscillation_amplitude: float = 400.0
## The direction to fly horizontally.
@export var direction: Direction = Direction.LEFT


#-------------------------------------------------------------------------------
# On-ready Variables
#-------------------------------------------------------------------------------
@onready var avoid_area: Area2D = $AvoidArea2D
@onready var avoid_timer: Timer = $AvoidTimer


#-------------------------------------------------------------------------------
# Enums
#-------------------------------------------------------------------------------
enum Direction { LEFT = -1, RIGHT = 1 }
enum State { FLYING, AVOIDING }


#-------------------------------------------------------------------------------
# Private Variables
#-------------------------------------------------------------------------------
var _oscillation_time: float = 0.0
var _state: State = State.FLYING
var _avoid_direction: float = 0.0


#-------------------------------------------------------------------------------
# Lifecycle Methods
#-------------------------------------------------------------------------------
func _draw() -> void:
	draw_circle(Vector2.ZERO, 25.0, Color.TEAL)


func _physics_process(delta: float) -> void:
	velocity = _get_next_velocity(delta)
	move_and_collide(velocity * delta)


#-------------------------------------------------------------------------------
# Signals
#-------------------------------------------------------------------------------
func _on_avoid_area_2d_body_entered(body: Node2D) -> void:
	if !body.is_in_group("walls"): return
	_avoid_direction = -1.0 if position.y < body.position.y else 1.0
	_state = State.AVOIDING
	avoid_timer.start()


func _on_avoid_timer_timeout() -> void:
	_state = State.FLYING


#-------------------------------------------------------------------------------
# Private Methods
#-------------------------------------------------------------------------------
func _get_next_velocity(delta: float) -> Vector2:
	var vel: Vector2 = Vector2.ZERO
	var speed_x: float = (
		speed if acceleration == 0.0 
		else clampf(abs(velocity.x) + acceleration * delta, 0.0, speed)
	)
	speed_x *= float(direction)

	match _state:
		State.FLYING:
			_oscillation_time += delta
			var oscillation_frequency = (2.0 * PI * _oscillation_time) / oscillation_time
			vel = Vector2(
				speed_x,
				sin(oscillation_frequency) * oscillation_amplitude
			)
		State.AVOIDING:
			vel = Vector2(speed_x, abs(speed_x) * _avoid_direction)

	return vel
