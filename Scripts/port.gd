extends Node
class_name Port

#Stores the custom 'class_name'
var _class = "Port"

@export var port_number = 0
@export var port_open = false

func _get_number() -> int:
	return port_number

func _set_number(newNumber: int):
	port_number = newNumber
