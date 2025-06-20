extends Node

@export var tile_scene: PackedScene = preload("res://tile.tscn")

var visible_rect: Rect2 = Rect2()
var tile_width: float = 50.0
var tunnel_height: float = 600.0
var amplitude: float = 100.0
var period: float = 1920.0


func _ready() -> void:
	visible_rect = get_viewport().get_visible_rect()
	generate_tunnel()


func generate_tunnel():
	var center: Vector2 = visible_rect.get_center()
	var tile_count: int = int(visible_rect.size.x / tile_width) + 1
	var x: float = 0.0
	for i in range(tile_count):
		# Bottom tile
		var bottom_tile: Tile = tile_scene.instantiate()
		bottom_tile.size = Vector2(tile_width, visible_rect.size.y)
		bottom_tile.position = Vector2(x, center.y + get_y_offset(x) + (tunnel_height + bottom_tile.size.y) * 0.5);
		owner.add_child.call_deferred(bottom_tile)

		# Top tile
		var top_tile: Tile = tile_scene.instantiate()
		top_tile.size = Vector2(tile_width, visible_rect.size.y)
		top_tile.position = Vector2(x, center.y + get_y_offset(x) - (tunnel_height + top_tile.size.y) * 0.5)
		owner.add_child.call_deferred(top_tile)

		x += tile_width


func get_y_offset(x: float) -> float:
	return amplitude * (sin(2 * PI * x / period) + sin(2 * PI * 2 * x / period))
