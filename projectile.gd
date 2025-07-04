class_name Projectile
extends CharacterBody2D

#-------------------------------------------------------------------------------
# Exported Variables
#-------------------------------------------------------------------------------
@export var initial_speed: float = 1200
@export var acceleration: float = 0.0


#-------------------------------------------------------------------------------
# Public Variables
#-------------------------------------------------------------------------------
var direction: Vector2 = Vector2.ZERO

	
#-------------------------------------------------------------------------------
# Lifecyle Methods
#-------------------------------------------------------------------------------
func _draw() -> void:
	var points: Array[Vector2] = [
		Vector2(-7.0, -7.0),
		Vector2(7.0, 0.0),
		Vector2(-7.0, 7.0)
	]

	draw_polygon(points, [Color.GREEN])


func _physics_process(delta: float) -> void:
	if acceleration > 0.0:
		velocity += direction * acceleration * delta
	move_and_collide(velocity * delta)


#-------------------------------------------------------------------------------
# Public Methods
#-------------------------------------------------------------------------------
func fire(_position: Vector2, _direction: Vector2):
	position = _position
	direction = _direction
	rotation = direction.angle()
	velocity = Vector2(direction * initial_speed)

