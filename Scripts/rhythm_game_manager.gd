extends Node2D
class_name RhythmManager

const rhythemNotePrefab = preload("res://Scenes/rhythem_note.tscn")


func spawn_random_note():
	var spawnLocArray: Array = [Vector2(0, 300), Vector2(300, 0), Vector2(0, -300), Vector2(-300, 0)]
	var spawnLocation = spawnLocArray.pick_random()
	var newNote = rhythemNotePrefab.instantiate()
	newNote.position = spawnLocation
	add_child(newNote)
	
