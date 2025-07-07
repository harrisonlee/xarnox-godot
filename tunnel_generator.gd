extends Node

#-------------------------------------------------------------------------------
# Exported Variables
#-------------------------------------------------------------------------------
## The tile node to generate
@export var tile_scene: PackedScene = preload("res://tile.tscn")
## The minimum period. Period will be randomly generated from min/max.
@export var period_min: float = 960.0
## The maxium period. Period will be randomly generated from min/max.
@export var period_max: float = 3840.0
## The minimum amplitude. Amplitude will be randomly generated from min/max.
@export var amplitude_min: float = 100.0
## The maximum amplitude. Amplitude will be randomly generated from min/max.
@export var amplitude_max: float = 300.0


#-------------------------------------------------------------------------------
# Public Variables
#-------------------------------------------------------------------------------
var tile_width: float = 50.0
var tunnel_height: float = 600.0


#-------------------------------------------------------------------------------
# Enums
#-------------------------------------------------------------------------------
enum State { NORMAL, TRANSITIONING_OUT, TRANSITIONING_IN }


#-------------------------------------------------------------------------------
# Inner Classes
#-------------------------------------------------------------------------------
class TilePair:
	var position_x: float
	var top_tile: Tile
	var bottom_tile: Tile

	func free_tiles() -> void:
		top_tile.queue_free()
		bottom_tile.queue_free()


#-------------------------------------------------------------------------------
# Private Variables
#-------------------------------------------------------------------------------
var _current_x: float = 0.0
var _last_transition_change_x: float = 0.0
var _transition_period: float = 0.0
var _generator_idx: int = 0
var _current_period: float = 0.0
var _current_amplitude: float = 0.0
var _target_amplitude: float = 0.0
var _state: State = State.TRANSITIONING_IN
var _tile_pairs: Array[TilePair] = []


#-------------------------------------------------------------------------------
# Public Methods
#-------------------------------------------------------------------------------
func init(rect: Rect2) -> void:
	_current_period = rect.size.x
	_transition_period = _current_period
	_target_amplitude = 100.0


func generate_tunnel(rect: Rect2, origin_y: float):
	_cleanup_tiles(rect)
	if rect.end.x + tile_width < _current_x: return

	_current_amplitude = _target_amplitude
	var tile_coverage: int = int(rect.end.x + tile_width - _current_x)
	var tile_count: int = int(tile_coverage / tile_width) + 1

	for i in range(tile_count):
		var generator_offset_y: float = 0.0
		match _state:
			State.NORMAL:
				generator_offset_y = _get_offset_y(_current_x)
			State.TRANSITIONING_OUT:
				var ratio = _last_transition_change_x / _transition_period
				_current_amplitude = lerpf(_current_amplitude, 0.0, ratio)
				generator_offset_y = _get_offset_y(_current_x)
			State.TRANSITIONING_IN:
				var ratio = _last_transition_change_x / _transition_period
				_current_amplitude = lerpf(0.0, _target_amplitude, ratio)
				generator_offset_y = _get_offset_y(_current_x)

		var tunnel_offset_y: float = origin_y + generator_offset_y
		var tile_offset_y: float = (tunnel_height + rect.size.y) * 0.5

		# Bottom tile
		var bottom_tile: Tile = tile_scene.instantiate()
		bottom_tile.size = Vector2(tile_width, rect.size.y)
		bottom_tile.position = Vector2(_current_x, tunnel_offset_y + tile_offset_y)
		owner.add_child.call_deferred(bottom_tile)

		# Top tile
		var top_tile: Tile = tile_scene.instantiate()
		top_tile.size = Vector2(tile_width, rect.size.y)
		top_tile.position = Vector2(_current_x, tunnel_offset_y - tile_offset_y)
		owner.add_child.call_deferred(top_tile)

		# Remember tiles for cleanup
		var tile_pair: TilePair = TilePair.new()
		tile_pair.position_x = _current_x
		tile_pair.top_tile = top_tile
		tile_pair.bottom_tile = bottom_tile
		_tile_pairs.append(tile_pair)

		# Advance x position
		_current_x += tile_width
		_last_transition_change_x += tile_width

		# Don't update state unless we've reached a transition
		if _last_transition_change_x < _transition_period: continue

		# Update State
		match _state:
			State.NORMAL:
				_state = State.TRANSITIONING_OUT
				_last_transition_change_x = 0.0
				_transition_period = _current_period * 0.5

				# debug
				bottom_tile.color = Color.GREEN
				top_tile.color = Color.GREEN


			State.TRANSITIONING_OUT:
				_state = State.TRANSITIONING_IN
				_last_transition_change_x = 0.0

				_generator_idx += 1
				if _generator_idx > 2:
					_generator_idx = 0

				_current_period = range(period_min, period_max).pick_random()
				_target_amplitude = range(amplitude_min, amplitude_max).pick_random()
				_transition_period = _current_period * 0.5

				# debug
				bottom_tile.color = Color.BLUE
				top_tile.color = Color.BLUE

			State.TRANSITIONING_IN:
				_state = State.NORMAL
				_last_transition_change_x = 0.0
				_transition_period = _current_period * [0.5, 1.0, 1.5].pick_random()

				# debug
				bottom_tile.color = Color.RED
				top_tile.color = Color.RED


#-------------------------------------------------------------------------------
# Private Methods
#-------------------------------------------------------------------------------
func _get_offset_y(x: float) -> float:
	var p: float = 2.0 * PI / _current_period
	match _generator_idx:
		0: return _current_amplitude * (sin(x * p) + sin(2 * x * p))
		1: return _current_amplitude * sin(sin(2 * x * p) + sin(4 * x * p))
		_: return _current_amplitude * sin(3 * x * p + sin(x * p))


func _update_transition_period() -> void:
	var multipliers: Array[float] = [0.5, 1.0 , 1.5, 2.0, 2.5, 3.0]
	_transition_period = _current_period * multipliers.pick_random()


func _cleanup_tiles(rect: Rect2) -> void:
	var removed_cnt: int = 0
	for tile_pair in _tile_pairs:
		if tile_pair.position_x + tile_width > rect.position.x: break
		tile_pair.free_tiles()
		removed_cnt += 1

	for i in removed_cnt:
		_tile_pairs.remove_at(i)
