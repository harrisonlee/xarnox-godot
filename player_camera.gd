extends Camera2D

#-------------------------------------------------------------------------------
# Exported Variables
#-------------------------------------------------------------------------------
@export var player: Node2D
@export var player_follow_x: float = 0.0
@export var shake_strength: float = 50.0
@export var shake_decay: float = 10.0
@export var follow_speed: float = 2.5


#-------------------------------------------------------------------------------
# Private Variables
#-------------------------------------------------------------------------------
var _current_viewport_rect: Rect2 = Rect2()
var _current_shake_strength: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


#-------------------------------------------------------------------------------
# Lifecyle Methods
#-------------------------------------------------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_current_viewport_rect = get_viewport_rect()

# Called every frame. 'delta' is the elapsed time since the previous frame.
var is_first = true
func _process(delta: float) -> void:
	move_to_player(follow_speed * delta)

	if _current_shake_strength > 0.2:
		_current_shake_strength = lerpf(
			_current_shake_strength,
			0.0, shake_decay * delta
		)
		offset = _random_shake_offset()
	else:
		offset = Vector2.ZERO


#-------------------------------------------------------------------------------
# Public Methods
#-------------------------------------------------------------------------------
func get_visible_rect() -> Rect2:
	var center: Vector2 = _current_viewport_rect.get_center()
	return Rect2(
		Vector2(position.x - center.x, position.y - center.y),
		_current_viewport_rect.size
	)


func shake() -> void:
	_current_shake_strength = shake_strength


func move_to_player(lerp_speed: float = 0.0) -> void:
	if lerp_speed > 0.0:
		position = position.lerp(_target_position(), lerp_speed)
	else:
		position = _target_position()


#-------------------------------------------------------------------------------
# Private Methods
#-------------------------------------------------------------------------------
func _target_position() -> Vector2:
	var target_position  = player.position 
	target_position.x += _current_viewport_rect.size.x * 0.5 - player_follow_x
	return target_position


func _random_shake_offset() -> Vector2:
	return Vector2(
		_rng.randf_range(-_current_shake_strength, _current_shake_strength),
		_rng.randf_range(-_current_shake_strength, _current_shake_strength)
	)
	
