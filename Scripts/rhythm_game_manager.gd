extends Node2D
class_name RhythmManager

const rhythemNotePrefab = preload("res://Scenes/rhythm_note.tscn")

@onready var hurtSound: AudioStreamPlayer = $HurtSound
@onready var hpCounter: RichTextLabel = $Core/HPCounter

var lastHurtPitch: float = 1.0
var score: int = 0
var hp: int = 5


func spawn_random_note():
	var spawnLocArray: Array = [Vector2(0, 300), Vector2(300, 0), Vector2(0, -300), Vector2(-300, 0)]
	var spawnLocation = spawnLocArray.pick_random()
	var newNote = rhythemNotePrefab.instantiate()
	newNote.position = spawnLocation
	newNote.core_collision_signal.connect(core_collision)
	newNote.shield_collision_signal.connect(shield_collision)
	add_child(newNote)


func play_hurt_sound(minPitch: float, maxPitch: float):
	while abs(hurtSound.pitch_scale - lastHurtPitch) < 0.1:
		hurtSound.pitch_scale = randf_range(minPitch, maxPitch)
	lastHurtPitch = hurtSound.pitch_scale
	hurtSound.play()



func update_hp_counter():
	hpCounter.text = str(hp)


func core_collision():
	hp -= 1
	play_hurt_sound(0.8, 1.2)
	update_hp_counter()
	print("Core Signal Worked")


func shield_collision():
	score += 1
	print("shield signal worked")
