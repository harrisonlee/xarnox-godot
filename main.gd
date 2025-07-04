extends Node

#-------------------------------------------------------------------------------
# On-ready Nodes
#-------------------------------------------------------------------------------
@onready var hud = $HUD
@onready var player = $Player
@onready var player_camera = $PlayerCamera
@onready var tunnel_generator = $TunnelGenerator


#-------------------------------------------------------------------------------
# Private Variables
#-------------------------------------------------------------------------------
var _current_viewport_rect: Rect2 = Rect2()
var _tunnel_y_origin: float = 0.0


#-------------------------------------------------------------------------------
# Lifecycle Methods
#-------------------------------------------------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_current_viewport_rect = get_viewport().get_visible_rect()

	player.position = $PlayerStartingPosition.position
	player_camera.player_follow_x = $PlayerStartingPosition.position.x
	player_camera.move_to_player()

	_tunnel_y_origin = _current_viewport_rect.get_center().y
	tunnel_generator.init(_current_viewport_rect)
	tunnel_generator.generate_tunnel(_current_viewport_rect, _tunnel_y_origin)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	tunnel_generator.generate_tunnel(
		player_camera.get_visible_rect(),
		_tunnel_y_origin
	)


#-------------------------------------------------------------------------------
# Signal Callbacks
#-------------------------------------------------------------------------------
func _on_player_hit() -> void:
	player_camera.shake()
	hud.adjust_player_health(-10)

	if hud.player_health_bar.value <= 0.0:
		player.hide()
		player.set_physics_process(false)
