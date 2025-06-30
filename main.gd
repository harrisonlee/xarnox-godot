extends Node

var current_viewport_rect: Rect2 = Rect2()
var tunnel_y_origin: float = 0.0

@onready var hud = $HUD
@onready var player = $Player
@onready var player_camera = $PlayerCamera
@onready var tunnel_generator = $TunnelGenerator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.position = $PlayerStartingPosition.position
	player_camera.player_follow_x = $PlayerStartingPosition.position.x
	current_viewport_rect = get_viewport().get_visible_rect()
	tunnel_y_origin = current_viewport_rect.get_center().y
	tunnel_generator.generate_tunnel(current_viewport_rect, tunnel_y_origin)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	tunnel_generator.generate_tunnel(player_camera.get_visible_rect(), tunnel_y_origin)


func _on_player_hit() -> void:
	player_camera.shake()
	hud.adjust_player_health(-10)

	if hud.player_health_bar.value <= 0.0:
		player.hide()
		player.set_physics_process(false)
