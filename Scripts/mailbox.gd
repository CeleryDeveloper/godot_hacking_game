extends Control
class_name Mailbox

const conversationTabPrefab = preload("res://Scenes/conversation_tab.tscn")
const convoHeight: float = 76

@onready var conversationsPanel: Panel = $BaseContainer/Conversations

var gameManager: Game = null
var convoNumber: int = 0


func _ready() -> void:
	print("ready!")
	add_new_conversation()
	add_new_conversation("test", "two")

func add_new_conversation(contactName: String = "jim", firstMessage: String = "hello"):
	var newConvo: ConversationTab = conversationTabPrefab.instantiate()
	
	newConvo.set_contact_name(contactName)
	newConvo.set_preview_text(firstMessage)
	newConvo.set_position(Vector2(0, convoNumber * convoHeight))
	convoNumber += 1
	print(convoNumber)
	print(convoNumber * convoHeight)
	
	conversationsPanel.add_child(newConvo)


func exit_scene():
	gameManager.deload_mail_scene(self)


func set_game_manager(newManager: Game):
	gameManager = newManager
