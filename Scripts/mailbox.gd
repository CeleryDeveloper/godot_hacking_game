extends Control
class_name Mailbox

var gameManager: Game = null

func exit_scene():
	gameManager.deload_mail_scene(self)


func set_game_manager(newManager: Game):
	gameManager = newManager
