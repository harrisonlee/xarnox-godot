extends Node

var mesh_scene = preload("res://test_mesh.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var current_x: float = 0.0
	var current_y: float = 700.0
	var p: float = 2.0 * PI / 1200.0

	while current_x <= 1920.0:
		var sin_y = sin(sin(2.0 * p * current_x) + sin(p * current_x)) * 40.0
		sin_y += randf_range(-20.0, 20.0)

		var mesh: TestMesh = mesh_scene.instantiate()
		mesh.init_with_slope(sin_y)
		mesh.position = Vector2(current_x, current_y)
		add_child(mesh)

		var mesh_2: TestMesh = mesh_scene.instantiate()
		mesh_2.init_with_slope(sin_y)
		mesh_2.move_light_to(Vector2(25.0, 1080.0))
		mesh_2.position = Vector2(current_x, current_y - 1580.0)
		add_child(mesh_2)

		current_x += mesh.width
		current_y += mesh.slope
