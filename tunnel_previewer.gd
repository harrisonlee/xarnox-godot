@tool
extends Node2D

#-------------------------------------------------------------------------------
# Exported Variables
#-------------------------------------------------------------------------------
@export_tool_button("Next Generator") var next_generator_button = _goto_next_generator

@export var mode: Mode = Mode.MIN:
	set(new_value):
		mode = new_value
		queue_redraw()


#-------------------------------------------------------------------------------
# Public Enums
#-------------------------------------------------------------------------------
enum Mode { MIN, MAX, RANDOM, MAX_WITH_MIN_P, MIN_WITH_MAX_P }


#-------------------------------------------------------------------------------
# Private Variables
#-------------------------------------------------------------------------------
var _offset_y_generators: Array[OffsetYGenerator] = []
var _current_offset_y_generator: OffsetYGenerator = null
var _generator_idx: int = 0


#-------------------------------------------------------------------------------
# Lifecycle Methods
#-------------------------------------------------------------------------------
func _draw() -> void:
	match mode:
		Mode.MIN:		_current_offset_y_generator.use_minimum_metrics()
		Mode.MAX:		_current_offset_y_generator.use_maximum_metrics()
		Mode.RANDOM:	_current_offset_y_generator.randomize_metrics()
		Mode.MAX_WITH_MIN_P:
			_current_offset_y_generator.use_maximum_metrics()
			_current_offset_y_generator.period = _current_offset_y_generator.min_period
			_current_offset_y_generator._auto_scale_amplitude()
		Mode.MIN_WITH_MAX_P:
			_current_offset_y_generator.use_minimum_metrics()
			_current_offset_y_generator.period = _current_offset_y_generator.max_period

	const step_x: float = 10.0
	var distance_x: float = _current_offset_y_generator.period
	var current_x: float = 0.0
	var tunnel_height = _current_offset_y_generator.tunnel_height
	var last_point: Vector2 = Vector2.ZERO

	while current_x < distance_x:
		var offset_y: float = _current_offset_y_generator.get_offset_y(current_x)
		var new_point: Vector2 = Vector2(current_x, offset_y)

		# top line
		var translation: Vector2 = Vector2(0.0, offset_y - tunnel_height * 0.5)
		draw_line(last_point + translation, new_point + translation, Color.GREEN, 10.0)

		# bottom line
		translation.y += tunnel_height
		draw_line(last_point + translation, new_point + translation, Color.GREEN, 10.0)

		last_point = new_point
		current_x += step_x

	# draw player
	draw_circle(Vector2.ZERO, 50.0, Color.RED)


func _ready() -> void:
	for offset_y_generator in find_children("*", "OffsetYGenerator"):
		_offset_y_generators.append(offset_y_generator)
	
	assert(!_offset_y_generators.is_empty(), "No offset generators found in tunnel previewer")
	_current_offset_y_generator = _offset_y_generators[_generator_idx]


#-------------------------------------------------------------------------------
# Private Methods
#-------------------------------------------------------------------------------
func _goto_next_generator() -> void:
	_generator_idx += 1
	if _generator_idx >= _offset_y_generators.size():
		_generator_idx = 0
	_current_offset_y_generator = _offset_y_generators[_generator_idx]
	print("current gen: ", _current_offset_y_generator)
	queue_redraw()
