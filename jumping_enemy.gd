extends Enemy

## An enemy that jumps on the terrain.

#-------------------------------------------------------------------------------
# Exported Variables
#-------------------------------------------------------------------------------
## The speed this node travels horizontally. Use zero to have no movement.
@export var speed: float = 100.0
## The height to jump. Larger numbers yield greater distance.
@export var jump_height: float = 200.0
## The speed of the jump.
@export var jump_speed: float = 900.0
## The direction to fly horizontally.
@export var direction: Direction = Direction.LEFT
## The behavior of the direction changes.
@export var direction_change: DirectionChange = DirectionChange.NONE
## The amount of time to spend idle after landing.
@export var idle_time: float = 0.5
## Whether or not to switch to TOP or BOTTOM install location when contacting
## opposite walls.
@export var should_switch_install_location: bool = false


#-------------------------------------------------------------------------------
# Enums
#-------------------------------------------------------------------------------
enum Direction { LEFT = -1, RIGHT = 1 }
enum DirectionChange { NONE, ALTERNATE, RANDOM }
enum State { JUMPING, DESCENDING, STUCK, FALLING, IDLE }


#-------------------------------------------------------------------------------
# Private Variables
#-------------------------------------------------------------------------------
var _state: State = State.IDLE
var _current_direction: Direction = Direction.LEFT
var _elapsed_idle_time: float = 0.0
var _elapsed_stuck_time: float = 0.0
var _jump_position_y: float = 0.0


#-------------------------------------------------------------------------------
# Lifecycle Methods
#-------------------------------------------------------------------------------
func _draw() -> void:
	draw_circle(Vector2.ZERO, 30.0, Color.ORANGE_RED)


func _ready() -> void:
	_current_direction = direction


func _physics_process(delta: float) -> void:
	var direction_modifier: float = \
		1.0 if _resolved_install_location_y == InstallLocationY.TOP else -1.0

	match _state:
		State.JUMPING:
			var jump_distance: float = abs(position.y - _jump_position_y)
			var jump_speed_modifier = 1.0 - ease(jump_distance / jump_height, 3.0)

			velocity = Vector2(
				speed * float(_current_direction),
				jump_speed * jump_speed_modifier * direction_modifier 
			)

			if jump_speed_modifier <= 0.1:
				_state = State.DESCENDING

		State.DESCENDING:
			velocity.y += jump_speed * delta * direction_modifier * -1.0

		State.STUCK:
			velocity = Vector2(
				velocity.x + speed * delta * float(_current_direction),
				velocity.y + jump_speed * delta * direction_modifier
			)

			_elapsed_stuck_time += delta
			if _elapsed_stuck_time > 0.1:
				_state = State.JUMPING

		State.FALLING:
			velocity = Vector2(
				velocity.x + 100.0 * float(_current_direction) * delta,
				velocity.y + jump_speed * delta * direction_modifier * -1.0
			)

		State.IDLE:
			_elapsed_idle_time += delta
			velocity = Vector2.ZERO
			if _elapsed_idle_time > idle_time:
				_jump_position_y = position.y
				_update_direction_if_necessary()
				_state = State.JUMPING

	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.get_collider().is_in_group("walls"):
			if _is_on_opposite_wall_with(collision) and should_switch_install_location:
				_switch_resolved_install_location_y()
				return

			if _is_on_opposite_wall_with(collision):
				if _state != State.FALLING: 
					velocity = collision.get_normal() * 50.0
				_state = State.FALLING
				return

			if _state == State.JUMPING and _is_stuck_with(collision):
				if _state != State.STUCK:
					velocity = Vector2(
						speed * -float(_current_direction),
						jump_speed * direction_modifier
					) * 0.5
					_elapsed_stuck_time = 0.0
				_state = State.STUCK
				return

			if _state != State.IDLE:
				_elapsed_idle_time = 0.0
				_state = State.IDLE


#-------------------------------------------------------------------------------
# Private Methods
#-------------------------------------------------------------------------------
func _is_stuck_with(collision: KinematicCollision2D) -> bool:
	var collision_angle = rad_to_deg(collision.get_normal().angle())
	match _current_direction:
		Direction.LEFT:
			return collision_angle >= -45.0 and collision_angle <= 45.0
		Direction.RIGHT:
			return collision_angle >= 135.0 and collision_angle <= 225.0
		_: return false


func _is_on_opposite_wall_with(collision: KinematicCollision2D) -> bool:
	var collider: PhysicsBody2D = collision.get_collider()
	match _resolved_install_location_y:
		InstallLocationY.TOP:
			return collider.position.y > position.y
		InstallLocationY.BOTTOM:
			return collider.position.y < position.y
		_: return false


func _switch_resolved_install_location_y() -> void:
	if _resolved_install_location_y == InstallLocationY.TOP:
		_resolved_install_location_y = InstallLocationY.BOTTOM
	else:
		_resolved_install_location_y = InstallLocationY.TOP
	
func _update_direction_if_necessary() -> void:
	match direction_change:
		DirectionChange.NONE:
			_current_direction = direction
		DirectionChange.ALTERNATE:
			_current_direction = (
				Direction.LEFT if _current_direction == Direction.RIGHT 
				else Direction.RIGHT
			)
		DirectionChange.RANDOM:
			_current_direction = (
				Direction.LEFT if range(2).pick_random() == 0
				else Direction.RIGHT
			)
