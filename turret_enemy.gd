extends Enemy

## An enemy that is stationary and fires projectiles at a target node.

#-------------------------------------------------------------------------------
# Exported Variables
#-------------------------------------------------------------------------------
## The firing interval. Enemy will fire at player at this interval in seconds.
@export var firing_interval: float = 1.0
## Whether or not to keep firing once target leaves detection area.
@export var cease_fire_outside_detection_area: bool = true
## The packed scene for the projectile.
@export var projectile_scene: PackedScene = preload("res://projectile.tscn")
## The target node to fire at.
@export var target_node: Node2D = null


#-------------------------------------------------------------------------------
# Private Variables 
#-------------------------------------------------------------------------------
var _elapsed_time_since_last_fire: float = 0.0
var _target_detected: bool = false


#-------------------------------------------------------------------------------
# Lifecycle Methods
#-------------------------------------------------------------------------------
func _draw() -> void:
	const dimension: float = 25.0
	var points: Array[Vector2] = [
		Vector2(-dimension, -dimension),
		Vector2(dimension, 0.0),
		Vector2(-dimension, dimension)
	]

	draw_polygon(points, [Color.WHITE_SMOKE])


func _ready() -> void:
	_elapsed_time_since_last_fire = firing_interval


func _physics_process(delta: float) -> void:
	_elapsed_time_since_last_fire += delta
	_fire_if_possible()


func install_in(parent_node: Node, rect: Rect2) -> void:
	super.install_in(parent_node, rect)
	var install_angle: float = (
		90.0 if _resolved_install_location_y == InstallLocationY.TOP 
		else 270.0
	)

	rotation = deg_to_rad(install_angle)


#-------------------------------------------------------------------------------
# Signal Callbacks 
#-------------------------------------------------------------------------------
func _on_detection_area_2d_body_entered(body: Node2D) -> void:
	if body == target_node:
		_target_detected = true


func _on_detection_area_2d_body_exited(body: Node2D) -> void:
	if cease_fire_outside_detection_area and body == target_node:
		_target_detected = false


#-------------------------------------------------------------------------------
# Private Methods
#-------------------------------------------------------------------------------
func _fire_if_possible() -> void:
	if _elapsed_time_since_last_fire >= firing_interval and _target_detected:
		_elapsed_time_since_last_fire = 0.0
		var projectile: Projectile = projectile_scene.instantiate()
		projectile.fire(
			global_position,  
			(target_node.global_position - global_position).normalized()
		)
		get_tree().root.add_child(projectile)
		
