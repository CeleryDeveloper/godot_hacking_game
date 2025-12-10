extends Node2D
class_name RhythemNote

const characters: String = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890!@#$%^&*()`~-_=+{}[];':,./<>?|"

@onready var startPos: Vector2 = Vector2(0, 0)
@onready var time: float = 0
@onready var textLabel: RichTextLabel = $RichTextLabel

var difficulty: float
var charLen: int

signal core_collision_signal
signal shield_collision_signal

func _ready() -> void:
	charLen = len(characters)
	startPos = self.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	time += delta * difficulty
 
	self.position = startPos.lerp(Vector2(0, 0), time)


func on_collision(area: Area2D) -> void:
	if area.name == "Core":
		core_collision_signal.emit()
	if area.name == "RhythmShieldArea":
		shield_collision_signal.emit()
	self.queue_free()


func random_text():
	textLabel.text = characters[randi_range(0, charLen - 1)]


func set_difficulty(newDif: float):
	difficulty = newDif
