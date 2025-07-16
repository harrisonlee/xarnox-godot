extends Node

#-------------------------------------------------------------------------------
# Exported Variables
#-------------------------------------------------------------------------------
@export var enemy_scene: PackedScene = null
@export_range(0.0, 1.0, 0.1) var enemy_position_x_ratio: float = 1.0
@export var use_random_enemy_position_x_ratio: bool = false
@export var show_player: bool = true
@export var start_player_on_autopilot: bool = true
@export var keep_player_on_screen: bool = true


#-------------------------------------------------------------------------------
# On-ready Variables
#-------------------------------------------------------------------------------
@onready var tunnel_generator = $TunnelGenerator
@onready var period_slider = $CanvasLayer/PeriodSlider
@onready var amplitude_slider = $CanvasLayer/AmplitudeSlider
@onready var tunnel_height_slider = $CanvasLayer/TunnelHeightSlider
@onready var offset_y_generator = $TunnelGenerator/CompoundSineOffsetYGeneratorC
@onready var player = $Player


#-------------------------------------------------------------------------------
# Constants
#-------------------------------------------------------------------------------
const MIN_PERIOD: float = 1920.0
const MAX_PERIOD: float = 1920.0 * 3.0
const MIN_AMPLITUDE: float = 0.0
const MAX_AMPLITUDE: float = 400.0
const MIN_TUNNEL_HEIGHT: float = 100.0
const MAX_TUNNEL_HEIGHT: float = 1080.0


#-------------------------------------------------------------------------------
# Private Variables
#-------------------------------------------------------------------------------
var _viewport_rect: Rect2 = Rect2()
var _tunnel_openings: Array[Rect2] = []


#-------------------------------------------------------------------------------
# Lifecycle Methods
#-------------------------------------------------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_viewport_rect = get_viewport().get_visible_rect()
	tunnel_generator.init(_viewport_rect)
	_update_tunnel()

	if !show_player:
		player.queue_free()
	elif start_player_on_autopilot:
		player.set_autopilot_enabled(true)


func _process(_delta: float) -> void:
	var auto_pilot_lookahead: float = player.collision_body.shape.get_rect().size.x * 0.5
	player.auto_pilot_position_y = tunnel_generator.get_stored_offset_y(
		player.position.x + auto_pilot_lookahead
	)

	var adjusted_rect = _viewport_rect.grow(-50.0)
	if keep_player_on_screen:
		match player.direction:
			Player.Direction.LEFT when player.position.x <= adjusted_rect.position.x:
				player.direction = Player.Direction.RIGHT
			Player.Direction.RIGHT when player.position.x >= adjusted_rect.end.x:
				player.direction = Player.Direction.LEFT


#-------------------------------------------------------------------------------
# Private Methods
#-------------------------------------------------------------------------------
func _generate_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	add_child(enemy)


func _update_tunnel() -> void:
	offset_y_generator.period = lerpf(
		MIN_PERIOD,
		MAX_PERIOD,
		period_slider.value
	) 
	offset_y_generator.amplitude = lerpf(
		MIN_AMPLITUDE,
		MAX_AMPLITUDE,
		amplitude_slider.value
	) 
	offset_y_generator.tunnel_height = lerpf(
		MIN_TUNNEL_HEIGHT,
		MAX_TUNNEL_HEIGHT,
		tunnel_height_slider.value
	) 

	_tunnel_openings = []
	tunnel_generator.reset()
	tunnel_generator.update_state(TunnelGenerator.State.NORMAL)
	tunnel_generator.generate_tunnel(
		_viewport_rect,
		_viewport_rect.get_center().y
	)


#-------------------------------------------------------------------------------
# Signal Callbacks
#-------------------------------------------------------------------------------
func _on_tunnel_generator_created_tile(opening: Rect2) -> void:
	_tunnel_openings.append(opening)


func _on_button_pressed() -> void:
	var ratio = \
			randf_range(0.0, 1.0) if use_random_enemy_position_x_ratio \
			else enemy_position_x_ratio 

	var idx: int = int(lerpf(
		0.0,
		float(_tunnel_openings.size() - 1),
		ratio
	))

	var enemy = enemy_scene.instantiate()
	enemy.install_in(self, _tunnel_openings[idx])


func _on_slider_value_changed(_value: float) -> void:
	_update_tunnel()
