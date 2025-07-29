extends Node2D
class_name RhythmShield

var speed: float = 5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("RhythmLeft"):
		rotation += -speed * delta
	if Input.is_action_pressed("RhythmRight"):
		rotation += speed * delta
