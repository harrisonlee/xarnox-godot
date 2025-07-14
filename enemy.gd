class_name Enemy extends CharacterBody2D

## The base enemy class. Provides convenience methods and data related to all
## enemies and their instantiation.

#-------------------------------------------------------------------------------
# Exported Variables
#-------------------------------------------------------------------------------
## Where to place the enemy on insertion.
@export var install_location_y: InstallLocationY = InstallLocationY.RANDOM
## The minimum amount of space to insert between enemy and terrain.
@export var install_padding_y: float = 0.0


#-------------------------------------------------------------------------------
# Enums
#-------------------------------------------------------------------------------
enum InstallLocationY { TOP, BOTTOM, CENTER, TOP_OR_BOTTOM, RANDOM }


#-------------------------------------------------------------------------------
# Private Variables
#-------------------------------------------------------------------------------
var _resolved_install_location_y: InstallLocationY = InstallLocationY.RANDOM


#-------------------------------------------------------------------------------
# Public Methods
#-------------------------------------------------------------------------------
func install_in(parent_node: Node, rect: Rect2) -> void:
	var adjusted_rect: Rect2 = rect.grow_individual(
		0.0, -install_padding_y,
		0.0, -install_padding_y
	)
	var install_position: Vector2 = Vector2(adjusted_rect.get_center().x, 0.0)

	_update_resloved_install_location_y()
	match _resolved_install_location_y:
		InstallLocationY.TOP:
			install_position.y = adjusted_rect.position.y
		InstallLocationY.BOTTOM:
			install_position.y = adjusted_rect.end.y
		InstallLocationY.CENTER:
			install_position.y = adjusted_rect.get_center().y
		InstallLocationY.RANDOM:
			install_position.y = randf_range(
				adjusted_rect.position.y,
				adjusted_rect.end.y
			)
	
	position = install_position
	parent_node.add_child(self)


#-------------------------------------------------------------------------------
# Private Methods
#-------------------------------------------------------------------------------
func _update_resloved_install_location_y() -> void:
	if install_location_y != InstallLocationY.TOP_OR_BOTTOM:
		_resolved_install_location_y = install_location_y
		return

	_resolved_install_location_y = (
		InstallLocationY.TOP if range(2).pick_random() == 0 
		else InstallLocationY.BOTTOM
	)

