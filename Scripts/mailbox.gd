extends Control
class_name Mailbox

const conversationTabPrefab = preload("res://Scenes/conversation_tab.tscn")
const convoHeight: float = 76

@onready var conversationsPanel: Panel = $BaseContainer/Conversations

var mailManager: MailManager = null
var gameManager: Game = null

var convoNumber: int = 0


func _ready() -> void:
	print("ready!")
	for contact in mailManager.get_contacts():
		add_new_conversation(contact.get_contact_name(), contact.get_last_message(), contact.get_contact_id())

func add_new_conversation(contactName: String = "Broken", firstMessage: String = "help", contactId: int = 0):
	var newConvo: ConversationTab = conversationTabPrefab.instantiate()
	print("adding convo...")
	
	newConvo.set_contact_name(contactName)
	newConvo.set_preview_text(firstMessage)
	newConvo.set_contact_id(contactId)
	newConvo.set_mailbox(self)
	newConvo.set_position(Vector2(0, convoNumber * convoHeight))
	convoNumber += 1
	print(convoNumber)
	print(convoNumber * convoHeight)
	
	conversationsPanel.add_child(newConvo)


func exit_scene():
	gameManager.deload_mail_scene(self)


func set_game_manager(newManager: Game):
	gameManager = newManager


func set_mail_manager(newManger: MailManager):
	mailManager = newManger
