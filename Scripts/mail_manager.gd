extends Node
class_name MailManager

@onready var contactsFolder: Node = $"../Contacts"

var contacts: Array[Contact] = []

func _ready() -> void:
	update_contacts()
	print(contacts)

#Adds new contacts to contacts array
func update_contacts():
	var children: Array = contactsFolder.get_children()
	var newId: int = randi_range(100000, 999999)
	
	for contact: Contact in children:
		if contacts.has(contact):
			continue
		
		var i: int = 0
		#gives contact unique id
		while i < children.size():
			if children[i].get_contact_id() == newId:
				newId = randi_range(100000, 999999)
				i = 0
			i += 1
			#error to prevent crashes
			if i > 10000:
				printerr("while loop limit broken")
				get_tree().quit(1)
		contact.set_contact_id(newId)
		contacts.append(contact)


func get_contacts() -> Array[Contact]:
	return contacts
