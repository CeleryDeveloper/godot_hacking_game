extends Node2D
class_name RhythmManager

const rhythemNotePrefab = preload("res://Scenes/rhythm_note.tscn")

@onready var hurtSound: AudioStreamPlayer = $HurtSound
@onready var hitSound: AudioStreamPlayer = $HitSound
@onready var CoreSprite: AnimatedSprite2D = $Core/CoreSprite
@onready var passDisplay: RichTextLabel = $RichTextLabel
@onready var shield: RhythmShield = $RhythmShield

var gameManager: Game
var password: String = "PLEASe HEPL I'm STUck In A COmPUTER!"
var userToDecrypt: User = null
var lastHurtPitch: float = 1.0
var score: int = 0
var startingHp: int = 5
var hp: int = 5
var difficulty: float = 0.3


#I'M SO SORRY
#These are arrays of frame numbers for each starting hp value, I probably could
#have just reordered the frames :(
var spriteArr5: Array[int] = [19, 17, 14, 10, 5, 0]
var spriteArr4: Array[int] = [18, 15, 11, 6, 1]
var spriteArr3: Array[int] = [16, 12, 7, 2]
var spriteArr2: Array[int] = [13, 8, 3]
var spriteArr1: Array[int] = [9, 4]

#This is assigned the value of the sprite array that will be used
var spriteArr: Array[int]


func _ready():
	passDisplay.text = password
	hp = startingHp
	shield.set_difficulty(difficulty)
	
	match startingHp:
		5:
			spriteArr = spriteArr5
		4:
			spriteArr = spriteArr4
		3:
			spriteArr = spriteArr3
		2:
			spriteArr = spriteArr2
		1:
			spriteArr = spriteArr1
	
	CoreSprite.frame = spriteArr[hp]


#Spawns a note above or below the core or to the left or right of it
func spawn_random_note():
	var spawnLocArray: Array = [Vector2(0, 300 * (1 + difficulty)), Vector2(300 * (1 + difficulty), 0), Vector2(0, -300 * (1 + difficulty)), Vector2(-300 * (1 + difficulty), 0)]
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
	CoreSprite.frame = spriteArr[hp]
	print(hp)
	
	if hp == 0:
		failure()
	


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
	print("winner!")
	gameManager.deload_rhythm_scene(self, true, userToDecrypt)


#Runs when hp is zero
func failure():
	print("Dissapointment.")
	gameManager.deload_rhythm_scene(self, false, userToDecrypt)


func get_password() -> String:
	return password


func set_password(newPass: String):
	password = newPass


func get_user() -> User:
	return userToDecrypt


func set_user(newUser: User):
	userToDecrypt = newUser


func set_game_manager(newManager: Game):
	gameManager = newManager


func set_difficulty(newDiff: float):
	difficulty = newDiff
