extends PanelContainer
class_name ConversationTab

@onready var nameLabel: Label = $Name
@onready var previewLabel: Label = $Preview

var contactName: String = "defaultName"
var previewText: String = "defaultPreview"
var contactId: int = TYPE_NIL
var mailbox: Mailbox = null

func _ready() -> void:
	print("ready Tab")
	nameLabel.text = contactName
	previewLabel.text = previewText


func set_mailbox(newMailbox: Mailbox):
	mailbox = newMailbox


func set_contact_id(newId: int):
	contactId = newId


func set_contact_name(newName: String):
	contactName = newName
	if is_instance_valid(nameLabel):
		nameLabel.text = contactName


func set_preview_text(newPreview: String):
	previewText = newPreview
	if is_instance_valid(previewLabel):
		previewLabel.text = previewText


func get_contact_id() -> int:
	return contactId


func get_contact_name() -> String:
	return contactName


func get_preview_text() -> String:
	return previewText


#runs when the button on this tab is pressed, use to open conversation in mailbox
func open_convo():
	print("button: " + str(contactId))
