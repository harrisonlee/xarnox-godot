@tool class_name TestMesh extends MeshInstance2D

#-------------------------------------------------------------------------------
# Exporated Tool Variables
#-------------------------------------------------------------------------------
@export_tool_button("Regen") var regen_button = func regen():
	_generate_polygon()
	_update_mesh()


#-------------------------------------------------------------------------------
# Exporated Variables
#-------------------------------------------------------------------------------
@export var slope: float = 0.0
@export var light_range: float = 255.0
@export var segment_size: float = 50.0
@export var width: float = 50.0
@export var height: float = 1080.0


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
var _polygon: PackedVector2Array = []


#-------------------------------------------------------------------------------
# Lifecycle Methods
#-------------------------------------------------------------------------------
func _update_mesh() -> void:
	var triangles: PackedInt32Array = Geometry2D.triangulate_delaunay(_polygon)
	var surface_tool: SurfaceTool = SurfaceTool.new()
	var did_add_vertices: bool = false

	for idx in range(0.0, triangles.size(), 3):
		var points: PackedVector2Array = [
			_polygon[triangles[idx]],
			_polygon[triangles[idx + 1]],
			_polygon[triangles[idx + 2]],
		]

		var midpoint_ab: Vector2 = (points[0] + points[1]) * 0.5
		var midpoint_bc: Vector2 = (points[1] + points[2]) * 0.5
		var midpoint_ca: Vector2 = (points[2] + points[0]) * 0.5
		var midpoint_tri = (midpoint_ab + midpoint_bc + midpoint_ca) / 3.0

		if Geometry2D.is_point_in_polygon(midpoint_tri, _polygon):
			var k: float = light_range - (midpoint_tri - light_marker.position).length()
			k = clampf(k, 0.0, 255.0)
			k = k / 255.0
			
			if !did_add_vertices:
				surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
				did_add_vertices = true

			for p in points:
				surface_tool.set_uv(p + position)
				surface_tool.set_color(Color.BLACK.lerp(Color.WHITE, k))
				surface_tool.add_vertex(Vector3(p.x, p.y, 0.0))

	if did_add_vertices:
		mesh = surface_tool.commit()


func _ready() -> void:
	if !_did_generate_polygon:
		_generate_polygon()
	_update_mesh()


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

	_polygon = points
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
