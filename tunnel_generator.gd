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
	var _did_free: bool = false

	func free_tiles() -> void:
		if _did_free: return
		_did_free = true
		top_tile.queue_free()
		bottom_tile.queue_free()


#-------------------------------------------------------------------------------
# Private Variables
#-------------------------------------------------------------------------------
var _current_x: float = 0.0
var _last_state_change_x: float = 0.0
var _last_tunnel_height: float = 0.0
var _transition_period: float = 0.0
var _generator_idx: int = 0
var _state: State = State.TRANSITIONING_IN
var _tile_pairs: Array[TilePair] = []
var _offset_history: Array[Vector2] = []
var _current_offset_y_generator: OffsetYGenerator = null
var _offset_y_generators: Array[OffsetYGenerator] = []


#-------------------------------------------------------------------------------
# Lifecycle Methods
#-------------------------------------------------------------------------------
func _ready() -> void:
	for offset_y_generator in find_children("*", "OffsetYGenerator"):
		_offset_y_generators.append(offset_y_generator)


#-------------------------------------------------------------------------------
# Public Methods
#-------------------------------------------------------------------------------
func init(rect: Rect2) -> void:
	_current_offset_y_generator = _offset_y_generators[_generator_idx]
	_current_offset_y_generator.randomize_metrics()
	_current_offset_y_generator.period = rect.size.x
	_last_tunnel_height = rect.size.y
	_transition_period = _current_offset_y_generator.period


func generate_tunnel(rect: Rect2, origin_y: float):
	_cleanup_tiles(rect)
	if rect.end.x + tile_width < _current_x: return

	var tile_coverage: int = int(rect.end.x + tile_width - _current_x)
	var tile_count: int = int(tile_coverage / tile_width) + 1
	var tile_size: Vector2 = Vector2(tile_width, rect.size.y * 2.0)

	for i in range(tile_count):
		var generator_offset_y: float = 0.0
		var tunnel_height: float = _current_offset_y_generator.tunnel_height
		var transition_ratio: float = _last_state_change_x / _transition_period

		match _state:
			State.NORMAL:
				_current_offset_y_generator.transition_ratio = 1.0
				generator_offset_y = _get_offset_y(_current_x)
			State.TRANSITIONING_OUT:
				_current_offset_y_generator.transition_ratio = 1.0 - transition_ratio
				generator_offset_y = _get_offset_y(_current_x)
			State.TRANSITIONING_IN:
				_current_offset_y_generator.transition_ratio = transition_ratio
				tunnel_height = lerpf(_last_tunnel_height, tunnel_height, transition_ratio)
				generator_offset_y = _get_offset_y(_current_x)

		var tunnel_offset_y: float = origin_y + generator_offset_y
		var tile_offset_y: float = (tunnel_height + tile_size.y) * 0.5

		# Bottom tile
		var bottom_tile: Tile = tile_scene.instantiate()
		bottom_tile.size = tile_size
		bottom_tile.position = Vector2(_current_x, tunnel_offset_y + tile_offset_y)
		owner.add_child.call_deferred(bottom_tile)

		# Top tile
		var top_tile: Tile = tile_scene.instantiate()
		top_tile.size = tile_size
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
		_last_state_change_x += tile_width

		# Store x and y offset in history
		_offset_history.append(Vector2(_current_x, tunnel_offset_y))

		# Don't update state unless we've reached a transition
		if _last_state_change_x < _transition_period: continue

		# Update State
		match _state:
			State.NORMAL:
				_update_state(State.TRANSITIONING_OUT)
				_transition_period = _current_offset_y_generator.period * 0.5

				# debug
				bottom_tile.color = Color.GREEN
				top_tile.color = Color.GREEN

			State.TRANSITIONING_OUT:
				_update_state(State.TRANSITIONING_IN)
				_last_tunnel_height = _current_offset_y_generator.tunnel_height
				_set_new_offset_y_generator()
				_current_offset_y_generator.randomize_metrics()
				_transition_period = _current_offset_y_generator.period * 0.5

				# debug
				bottom_tile.color = Color.BLUE
				top_tile.color = Color.BLUE

			State.TRANSITIONING_IN:
				_update_state(State.NORMAL)
				_transition_period = _current_offset_y_generator.period 

				# debug
				bottom_tile.color = Color.RED
				top_tile.color = Color.RED


func get_stored_offset_y(x: float) -> float:
	if _offset_history.is_empty():
		return 0.0
	
	# Find the closest x value <= given x
	var closest_idx: int = -1
	for i in range(_offset_history.size()):
		if _offset_history[i].x <= x:
			closest_idx = i
		else:
			break
	
	# If no point found or only one point, return what we have
	if closest_idx == -1:
		return 0.0
	if closest_idx == _offset_history.size() - 1:
		return _offset_history[closest_idx].y
	
	# Interpolate between closest point and next point
	var p1 = _offset_history[closest_idx]
	var p2 = _offset_history[closest_idx + 1]
	var t = (x - p1.x) / (p2.x - p1.x)
	return lerpf(p1.y, p2.y, t)


#-------------------------------------------------------------------------------
# Private Methods
#-------------------------------------------------------------------------------
func _set_new_offset_y_generator() -> void:
	if _offset_y_generators.size() == 1: return

	var new_generator_idx = _generator_idx
	while new_generator_idx == _generator_idx:
		new_generator_idx = range(_offset_y_generators.size()).pick_random()

	_generator_idx = new_generator_idx
	_current_offset_y_generator = _offset_y_generators[_generator_idx]


func _get_offset_y(x: float) -> float:
	return _current_offset_y_generator.get_offset_y(x)


func _update_state(state: State) -> void:
	_state = state
	_last_state_change_x = 0.0


func _cleanup_tiles(rect: Rect2) -> void:
	var removed_cnt: int = 0
	for tile_pair in _tile_pairs:
		if tile_pair.position_x + tile_width > rect.position.x: break
		tile_pair.free_tiles()
		removed_cnt += 1

	for i in removed_cnt:
		_tile_pairs.remove_at(i)
