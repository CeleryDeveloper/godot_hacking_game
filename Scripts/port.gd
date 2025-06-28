extends Node
class_name Port

#Stores the custom 'class_name' 
#as there is no way to access the name declared using the 'class_name' keyword
const _class = "Port"

@export var port_number = 0
@export var port_open = false

func _get_number() -> int:
	return port_number

func _set_number(newNumber: int):
	port_number = newNumber
