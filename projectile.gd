class_name Projectile extends CharacterBody2D

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
	var dimension: float = 7.0
	var points: Array[Vector2] = [
		Vector2(-dimension, -dimension),
		Vector2(dimension, 0.0),
		Vector2(-dimension, dimension)
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
	velocity = direction * initial_speed

