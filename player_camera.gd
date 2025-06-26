extends Camera2D

@export var player: Node2D
@export var player_follow_x: float = 0.0
@export var shake_strength: float = 50.0
@export var shake_decay: float = 10.0

var current_viewport_rect: Rect2 = Rect2()
var current_shake_strength: float = 0.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_viewport_rect = get_viewport_rect()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = player.position;
	position.x += current_viewport_rect.size.x * 0.5 - player_follow_x

	if current_shake_strength > 0.2:
		current_shake_strength = lerpf(current_shake_strength, 0.0, shake_decay * delta)
		offset = random_shake_offset()
	else:
		offset = Vector2.ZERO


func get_visible_rect() -> Rect2:
	var center: Vector2 = current_viewport_rect.get_center()
	return Rect2(
		Vector2(position.x - center.x, position.y - center.y),
		current_viewport_rect.size
	)


func shake() -> void:
	current_shake_strength = shake_strength


func random_shake_offset() -> Vector2:
	return Vector2(
		rng.randf_range(-current_shake_strength, current_shake_strength),
		rng.randf_range(-current_shake_strength, current_shake_strength)
	)
	
