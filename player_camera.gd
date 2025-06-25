extends Camera2D

@export var player: Node2D
@export var player_follow_x: float = 0.0

var current_viewport_rect: Rect2 = Rect2()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_viewport_rect = get_viewport_rect()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position = player.position;
	position.x += current_viewport_rect.size.x * 0.5 - player_follow_x


func get_visible_rect() -> Rect2:
	var center: Vector2 = current_viewport_rect.get_center()
	return Rect2(
		Vector2(position.x - center.x, position.y - center.y),
		current_viewport_rect.size
	)
