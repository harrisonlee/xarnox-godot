extends ProgressBar

#-------------------------------------------------------------------------------
# Constants
#-------------------------------------------------------------------------------
const TRANSITION_SPEED: float = 100.0
const COLOR_HEALTHY: Color = Color.GREEN
const COLOR_SLIGHTLY_DAMAGED: Color = Color.YELLOW
const COLOR_HEAVILY_DAMAGED: Color = Color.ORANGE
const COLOR_NEAR_DEATH: Color = Color.RED


#-------------------------------------------------------------------------------
# On-ready Nodes
#-------------------------------------------------------------------------------
@onready var damage_bar = $DamageBar
@onready var timer = $Timer


#-------------------------------------------------------------------------------
# Public Variables
#-------------------------------------------------------------------------------
var health: float = 0.0 : set = _set_health


#-------------------------------------------------------------------------------
# Private Variables
#-------------------------------------------------------------------------------
var _is_transitioning: bool = false


#-------------------------------------------------------------------------------
# Constants
#-------------------------------------------------------------------------------
func init_health(_health: float):
	health = _health
	value = health
	max_value = health
	damage_bar.value = health
	damage_bar.max_value = health
	_update_bar_color()


#-------------------------------------------------------------------------------
# Private Methods
#-------------------------------------------------------------------------------
func _set_health(new_health) -> void:
	var previous_health = health
	health = minf(max_value, new_health)
	value = health
	_is_transitioning = false
	_update_bar_color()

	if health < previous_health:
		timer.start()
	else:
		damage_bar.value = health


func _update_bar_color() -> void:
	var color: Color = Color.WHITE

	if ratio > 0.75:	color = COLOR_HEALTHY
	elif ratio > 0.5:	color = COLOR_SLIGHTLY_DAMAGED
	elif ratio  > 0.25:	color = COLOR_HEAVILY_DAMAGED
	else:				color = COLOR_NEAR_DEATH

	get("theme_override_styles/fill").bg_color = color


#-------------------------------------------------------------------------------
# Lifecyle Methods
#-------------------------------------------------------------------------------
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !_is_transitioning: return
	damage_bar.value = maxf(damage_bar.value - TRANSITION_SPEED * delta, health)

	if damage_bar.value == health:
		_is_transitioning = false


#-------------------------------------------------------------------------------
# Signal Callbacks
#-------------------------------------------------------------------------------
func _on_timer_timeout() -> void:
	_is_transitioning = true
