extends Node
class_name MailManager

@onready var contactsFolder: Node = $"../Contacts"

var contacts: Array[Contact] = []

func _ready() -> void:
	update_contacts()

#Adds new contacts to contacts array
func update_contacts():
	for contact in contactsFolder.get_children():
		if !contacts.has(contact):
			contacts.append(contact)


func get_contacts() -> Array[Contact]:
	return contacts
