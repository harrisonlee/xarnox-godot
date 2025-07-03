extends Node

#-------------------------------------------------------------------------------
# Exported Variables
#-------------------------------------------------------------------------------
@export var tile_scene: PackedScene = preload("res://tile.tscn")


#-------------------------------------------------------------------------------
# Public Variables
#-------------------------------------------------------------------------------
var tile_width: float = 50.0
var tunnel_height: float = 600.0
var amplitude: float = 100.0
var period: float = 1920.0


#-------------------------------------------------------------------------------
# Enums
#-------------------------------------------------------------------------------
enum State { NORMAL, TRANSITIONING_OUT, TRANSITIONING_IN }


#-------------------------------------------------------------------------------
# Private Variables
#-------------------------------------------------------------------------------
var _current_x: float = 0.0
var _last_transition_change_x: float = 0.0
var _transition_period: float = 0.0
var _generator_idx: int = 0
var _current_amplitude: float = 0.0
var _state: State = State.NORMAL:
	set(value):
		_state = value
		_update_transition_period()


#-------------------------------------------------------------------------------
# Lifecycle Methods
#-------------------------------------------------------------------------------
func _ready() -> void:
	_transition_period = period


#-------------------------------------------------------------------------------
# Public Methods
#-------------------------------------------------------------------------------
func generate_tunnel(rect: Rect2, y_origin: float):
	if rect.end.x + tile_width < _current_x: return 

	_current_amplitude = amplitude
	var tile_coverage: int = int(rect.end.x + tile_width - _current_x)
	var tile_count: int = int(tile_coverage / tile_width) + 1

	for i in range(tile_count):
		var generator_y_offset: float = 0.0
		match _state:
			State.NORMAL:
				generator_y_offset = _get_y_offset(_current_x)
			State.TRANSITIONING_OUT:
				var ratio = _last_transition_change_x / _transition_period
				_current_amplitude = lerpf(_current_amplitude, 0.0, ratio)
				generator_y_offset = _get_y_offset(_current_x)
			State.TRANSITIONING_IN:
				var ratio = _last_transition_change_x / _transition_period
				_current_amplitude = lerpf(0.0, amplitude, ratio)
				generator_y_offset = _get_y_offset(_current_x)
				
		var tunnel_y_offset: float = y_origin + generator_y_offset
		var tile_y_offset: float = (tunnel_height + rect.size.y) * 0.5

		# Bottom tile
		var bottom_tile: Tile = tile_scene.instantiate()
		bottom_tile.size = Vector2(tile_width, rect.size.y)
		bottom_tile.position = Vector2(_current_x, tunnel_y_offset + tile_y_offset)
		owner.add_child.call_deferred(bottom_tile)

		# Top tile
		var top_tile: Tile = tile_scene.instantiate()
		top_tile.size = Vector2(tile_width, rect.size.y)
		top_tile.position = Vector2(_current_x, tunnel_y_offset - tile_y_offset)
		owner.add_child.call_deferred(top_tile)

		_current_x += tile_width
		_last_transition_change_x += tile_width

		# Don't update state unless we've reached a transition
		if _last_transition_change_x < _transition_period: continue

		# Update State
		match _state:
			State.NORMAL:
				_state = State.TRANSITIONING_OUT
				_last_transition_change_x = 0.0

				# debug
				bottom_tile.color = Color.GREEN
				top_tile.color = Color.GREEN

			State.TRANSITIONING_OUT:
				_state = State.TRANSITIONING_IN
				_last_transition_change_x = 0.0

				_generator_idx += 1
				if _generator_idx > 2:
					_generator_idx = 0

				# debug
				bottom_tile.color = Color.BLUE
				top_tile.color = Color.BLUE

			State.TRANSITIONING_IN:
				_state = State.NORMAL
				_last_transition_change_x = 0.0

				# debug
				bottom_tile.color = Color.RED
				top_tile.color = Color.RED


#-------------------------------------------------------------------------------
# Private Methods
#-------------------------------------------------------------------------------
func _get_y_offset(x: float) -> float:
	var p: float = 2.0 * PI / period
	match _generator_idx:
		0: return _current_amplitude * (sin(x * p) + sin(2 * x * p))
		1: return _current_amplitude * sin(sin(2 * x * p) + sin(4 * x * p))
		_: return _current_amplitude * sin(3 * x * p + sin(x * p))


func _update_transition_period() -> void:
	var multipliers: Array[float] = [0.5, 1.0 , 1.5, 2.0, 2.5, 3.0]
	_transition_period = period * multipliers.pick_random()
