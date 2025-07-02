class_name Tile
extends StaticBody2D

#-------------------------------------------------------------------------------
# Exported Variables
#-------------------------------------------------------------------------------
@export var size: Vector2 = Vector2.ZERO
@export var color: Color = Color.DIM_GRAY


#-------------------------------------------------------------------------------
# Lifecycle Methods
#-------------------------------------------------------------------------------
func _draw() -> void:
	draw_rect(Rect2(Vector2(size.x * -0.5, size.y * -0.5), size), color)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var collision_shape: RectangleShape2D = RectangleShape2D.new()
	collision_shape.size = size
	$CollisionShape2D.shape = collision_shape
