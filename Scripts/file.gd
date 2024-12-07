extends Node
class_name File


#Stores the custom 'class_name'
var _class = "File"


@export var fileName: String = "System31"
@export var perms: String = "root"


#Returns this file's name
func _get_name() -> String:
	return fileName


#Returns the 'perms' of this 'file'
func _get_perms() -> String:
	return perms
