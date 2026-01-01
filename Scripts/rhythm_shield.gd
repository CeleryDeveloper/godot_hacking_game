extends Node2D
class_name RhythmShield

var speed: float = 5
var difficulty: float = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("RhythmLeft"):
		rotation += (-speed * delta) * difficulty
	if Input.is_action_pressed("RhythmRight"):
		rotation += (speed * delta) * difficulty


func set_difficulty(newDiff: float):
	difficulty += newDiff
