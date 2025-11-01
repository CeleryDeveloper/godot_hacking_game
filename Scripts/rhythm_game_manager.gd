extends Node2D
class_name RhythmManager

const rhythemNotePrefab = preload("res://Scenes/rhythm_note.tscn")

@onready var hurtSound: AudioStreamPlayer = $HurtSound
@onready var hitSound: AudioStreamPlayer = $HitSound
@onready var hpCounter: RichTextLabel = $Core/HPCounter
@onready var passDisplay: RichTextLabel = $RichTextLabel

var gameManager: Game
var password: String = "abcdefg"
var lastHurtPitch: float = 1.0
var score: int = 0
var hp: int = 5
var difficulty: float = 0.3


func _ready():
	passDisplay.text = password


#Spawns a note above or below the core or to the left or right of it
func spawn_random_note():
	var spawnLocArray: Array = [Vector2(0, 300), Vector2(300, 0), Vector2(0, -300), Vector2(-300, 0)]
	var spawnLocation = spawnLocArray.pick_random()
	var newNote: RhythemNote = rhythemNotePrefab.instantiate()
	newNote.set_difficulty(difficulty)
	newNote.position = spawnLocation
	newNote.core_collision_signal.connect(core_collision)
	newNote.shield_collision_signal.connect(shield_collision)
	add_child(newNote)


#Plays the 'hurt' sound effect
func play_hurt_sound(minPitch: float, maxPitch: float):
	while abs(hurtSound.pitch_scale - lastHurtPitch) < 0.1:
		hurtSound.pitch_scale = randf_range(minPitch, maxPitch)
	lastHurtPitch = hurtSound.pitch_scale
	hurtSound.play()


#Plays the 'hit' sound effect (for when a note is blocked)
func play_hit_sound(minPitch: float,  maxPitch: float):
	while abs(hitSound.pitch_scale - lastHurtPitch) < 0.1:
			hitSound.pitch_scale = randf_range(minPitch, maxPitch)
	lastHurtPitch = hitSound.pitch_scale
	hitSound.play()


#Changes the hp display in game to match the hp value
func update_hp_counter():
	hpCounter.text = str(hp)


#Runs when a note hits the core
func core_collision():
	hp -= 1
	play_hurt_sound(0.8, 1.2)
	update_hp_counter()


#Runs when a note hits the shield
func shield_collision():
	score += 1
	passDisplay.visible_characters += 1
	if score >= len(password):
		success()
	play_hit_sound(0.9, 1.2)


#Runs when the password is fully uncovered
func success():
	gameManager.deload_rhythm_scene(self)
	print("winner!")


#Runs when hp is zero
func failure():
	pass


func set_password(newPass: String):
	password = newPass


func set_game_manager(newManager: Game):
	gameManager = newManager
