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
# Private Variables
#-------------------------------------------------------------------------------
var _current_x: float = 0.0


#-------------------------------------------------------------------------------
# Public Methods
#-------------------------------------------------------------------------------
func generate_tunnel(rect: Rect2, y_origin: float):
	if rect.end.x + tile_width < _current_x: return 

	var tile_coverage: int = int(rect.end.x + tile_width - _current_x)
	var tile_count: int = int(tile_coverage / tile_width) + 1

	for i in range(tile_count):
		var tunnel_y_offset: float = y_origin + _get_y_offset(_current_x)
		var tile_y_offset = (tunnel_height + rect.size.y) * 0.5

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


#-------------------------------------------------------------------------------
# Private Methods
#-------------------------------------------------------------------------------
func _get_y_offset(x: float) -> float:
	return amplitude * (sin(2 * PI * x / period) + sin(2 * PI * 2 * x / period))
