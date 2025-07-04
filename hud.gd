extends CanvasLayer

#-------------------------------------------------------------------------------
# On-ready Nodes
#-------------------------------------------------------------------------------
@onready var player_health_bar = $PlayerHealthBar
@onready var distance_label = $DistanceLabel


#-------------------------------------------------------------------------------
# Lifecyle Methods
#-------------------------------------------------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_health_bar.init_health(100.0)


#-------------------------------------------------------------------------------
# Public Methods
#-------------------------------------------------------------------------------
func set_player_health(health: float) -> void:
	player_health_bar.health = health


func adjust_player_health(amount: float) -> void:
	var current_health = player_health_bar.health
	player_health_bar.health = current_health + amount


func set_player_distance(distance: float) -> void:
	distance_label.text = "DISTANCE: " + str(int(distance)) + "M"

