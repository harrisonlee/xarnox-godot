@tool class_name TestMesh extends Node2D

#-------------------------------------------------------------------------------
# Exporated Tool Variables
#-------------------------------------------------------------------------------
@export_tool_button("Regen") var regen_button = func regen():
	for child in poly_children:
		child.queue_free()
	
	poly_children = []
	_generate_polygon()
	_create_polygons()


#-------------------------------------------------------------------------------
# Exporated Variables
#-------------------------------------------------------------------------------
@export var slope: float = 0.0
@export var light_range: float = 255.0
@export var rock_color = Color(0.547, 0.588, 0.559)
@export var segment_size: float = 50.0
@export var width: float = 50.0
@export var height: float = 1080.0
@export var draw_debug: bool = false


#-------------------------------------------------------------------------------
# On-ready Nodes
#-------------------------------------------------------------------------------
@onready var light_marker = $LightMarker


#-------------------------------------------------------------------------------
# Private Variables
#-------------------------------------------------------------------------------
var _leading_points: PackedVector2Array = []
var _trailing_points: PackedVector2Array = []
var _did_generate_polygon: bool = false
var _corner_points: PackedVector2Array = []

var polygon_scene: PackedScene = preload("res://test_shader.tscn")
var polygon: PackedVector2Array = []
var poly_children: Array[Node2D] = []


#-------------------------------------------------------------------------------
# Lifecycle Methods
#-------------------------------------------------------------------------------
func _create_polygons() -> void:
	var triangles: PackedInt32Array = Geometry2D.triangulate_delaunay(polygon)

	for idx in range(0.0, triangles.size(), 3):
		var points: PackedVector2Array = [
			polygon[triangles[idx]],
			polygon[triangles[idx + 1]],
			polygon[triangles[idx + 2]],
		]

		var midpoint_ab: Vector2 = (points[0] + points[1]) * 0.5
		var midpoint_bc: Vector2 = (points[1] + points[2]) * 0.5
		var midpoint_ca: Vector2 = (points[2] + points[0]) * 0.5
		var midpoint_tri = (midpoint_ab + midpoint_bc + midpoint_ca) / 3.0

		if Geometry2D.is_point_in_polygon(midpoint_tri, polygon):
			var k: float = light_range - (midpoint_tri - light_marker.position).length()
			k = clampf(k, 0.0, 255.0)
			k = k / 255.0
			var _color = Color(rock_color.r * k, rock_color.g * k, rock_color.b * k)

			var poly = polygon_scene.instantiate()
			poly.polygon = points
			poly.set_instance_shader_parameter("brightness", k)

			poly.uv = [
				Vector2(points[0] + position),
				Vector2(points[1] + position),
				Vector2(points[2] + position),
			]

			add_child(poly)
			poly_children.append(poly)

			if draw_debug:
				draw_line(points[0], points[1], Color.WHITE)
				draw_line(points[1], points[2], Color.WHITE)
				draw_line(points[2], points[0], Color.WHITE)

				for cp in _corner_points:
					draw_circle(cp, 5.0, Color.RED)


func _ready() -> void:
	if !_did_generate_polygon:
		_generate_polygon()

	_create_polygons()


#-------------------------------------------------------------------------------
# Public Methods
#-------------------------------------------------------------------------------
func init_with_slope(_slope: float, leading_points: PackedVector2Array = []) -> void:
	slope = _slope
	_leading_points = leading_points
	_generate_polygon()


func get_trailing_points() -> PackedVector2Array:
	var points: PackedVector2Array = []
	for point in _trailing_points:
		points.append(Vector2(point.x - width, point.y - slope))
	return points


func move_light_to(light_position: Vector2) -> void:
	$LightMarker.position = light_position


#-------------------------------------------------------------------------------
# Private Methods
#-------------------------------------------------------------------------------
func _generate_polygon() -> void:
	var points: PackedVector2Array = [
		Vector2.ZERO,			# Upper left corner
		Vector2(width, slope)	# Upper right corner
	]
	_corner_points.append_array(points)

	# Trailing side
	_trailing_points = []
	var current_y: float = slope + segment_size
	while current_y < height + slope:
		var point = Vector2(width, current_y)
		points.append(point)
		_trailing_points.append(point)
		current_y += segment_size + randf_range(0.0, 35.0)

	var lower_right_corner: Vector2 = Vector2(width, height + slope)
	var lower_left_corner: Vector2 = Vector2(0.0, height)
	points.append(lower_right_corner)
	points.append(lower_left_corner)
	_corner_points.append(lower_right_corner)
	_corner_points.append(lower_left_corner)

	# Leading side
	if !_leading_points.is_empty():
		points.append_array(_leading_points)
	else:
		current_y = height - segment_size
		while current_y > 0.0:
			points.append(Vector2(0.0 - randf_range(0.0, 50.0), current_y))
			current_y -= segment_size + randf_range(0.0, 35.0)

	polygon = points
	_did_generate_polygon = true


func _get_polygon_bounding_rect(points: PackedVector2Array) -> Rect2:
	if points.is_empty(): return Rect2()

	var min_x: float = points[0].x
	var max_x: float = points[0].x
	var min_y: float = points[0].y
	var max_y: float = points[0].y

	for p in points:
		min_x = min(min_x, p.x)
		max_x = max(max_x, p.x)
		min_y = min(min_y, p.y)
		max_y = max(max_y, p.y)
	
	var pos: Vector2 = Vector2(min_x, min_y)
	var size: Vector2 = Vector2(max_x - min_x, max_y - min_y)

	return Rect2(pos, size)
