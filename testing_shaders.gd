extends Node

@onready var cam = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cam.position = get_viewport().get_visible_rect().get_center()


# Called every frame. 'delta' is the elapsed time since the previous frame.
var time: float = 0.0
func _process(delta: float) -> void:
	cam.position.y += sin(time * 2.0)
	time += delta
	pass
