extends Node
class_name DifficultyManager


var globalDifficulty: float = 0.3
var difficultyIncrement: float = 0.1


func increment_difficulty():
	globalDifficulty += difficultyIncrement


func get_difficulty() -> float:
	return globalDifficulty
