extends Node

var current_viewport_rect: Rect2 = Rect2()
var tunnel_y_origin: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Player.position = $PlayerStartingPosition.position
	$PlayerCamera.player_follow_x = $PlayerStartingPosition.position.x
	current_viewport_rect = get_viewport().get_visible_rect()
	tunnel_y_origin = current_viewport_rect.get_center().y
	$TunnelGenerator.generate_tunnel(current_viewport_rect, tunnel_y_origin)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var viewport_center = current_viewport_rect.get_center();
	var camera_viewport: Rect2 = Rect2(
		Vector2($PlayerCamera.position.x - viewport_center.x, $PlayerCamera.position.y - viewport_center.y),
		current_viewport_rect.size
	)

	$TunnelGenerator.generate_tunnel(camera_viewport, tunnel_y_origin)
