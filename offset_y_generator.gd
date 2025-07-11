@tool class_name OffsetYGenerator extends Node

#-------------------------------------------------------------------------------
# Exported Variables
#-------------------------------------------------------------------------------
## The minimum tunnel height allowed
@export var min_tunnel_height: float = 500.0
## The maximum tunnel height allowed
@export var max_tunnel_height: float = 800.0
## The minimum period allowed
@export var min_period: float = 960.0
## The maximum period allowed
@export var max_period: float = 1920.0
## The minimum amplitude allowed
@export var min_amplitude: float = 100.0
## The maximum amplitude allowed
@export var max_amplitude: float = 600.0
## Should automatically change ampltitude to lower value for lower periods
@export var auto_scale_amplitude: bool = true


#-------------------------------------------------------------------------------
# Public Variables
#-------------------------------------------------------------------------------
var tunnel_height: float = 0.0
var period: float = 0.0
var amplitude: float = 0.0
var transition_ratio: float = 1.0


#-------------------------------------------------------------------------------
# Public Methods
#-------------------------------------------------------------------------------
func randomize_metrics() -> void:
	tunnel_height = randf_range(min_tunnel_height, max_tunnel_height)
	period = randf_range(min_period, max_period)
	amplitude = randf_range(min_amplitude, max_amplitude)
	if auto_scale_amplitude: _auto_scale_amplitude()


func use_minimum_metrics() -> void:
	tunnel_height = min_tunnel_height
	period = min_period
	amplitude = min_amplitude


func use_maximum_metrics() -> void:
	tunnel_height = max_tunnel_height
	period = max_period
	amplitude = max_amplitude


func get_offset_y(x: float) -> float:
	var p = 2.0 * PI / period
	var a = amplitude * transition_ratio
	return _get_offset_y(x, p, a)


func get_screen_period() -> float:
	return 2.0 * PI / period


#-------------------------------------------------------------------------------
# Private Methods
#-------------------------------------------------------------------------------
func _get_offset_y(x: float, p: float, a: float) -> float:
	return a * sin(x * p)


func _auto_scale_amplitude() -> void:
	var period_ratio = (period - min_period) / (max_period - min_period)
	var scaled_max_amplitude: float = lerpf(min_amplitude, max_amplitude, period_ratio)
	amplitude = randf_range(min_amplitude, scaled_max_amplitude)
