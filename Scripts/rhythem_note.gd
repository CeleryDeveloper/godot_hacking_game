extends Node2D
class_name RhythemNote

@onready var startPos: Vector2 = Vector2(0, 0)
@onready var time: float = 0

func _ready() -> void:
	startPos = self.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	time += delta * 0.4

	self.position = startPos.lerp(Vector2(0, 0), time)


func on_collision(area: Area2D) -> void:
	print("collided")
	self.queue_free()
