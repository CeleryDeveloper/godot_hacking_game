extends Node
class_name Directory


#Stores the custom 'class_name'
var _class = "Directory"

@export var directoryName: String = "/"
@export var readPerms: String = "root"
@export var writePerms: String = "root"

var path: String = "/"
var children: Array


func _ready() -> void:
	_refresh_connected_children()
	_update_path()


#Changes this directory's name
func _set_name(newName: String):
	directoryName = newName


#Returns this directory's name
func _get_name() -> String:
	return directoryName


#Updates the content of 'path'
func _update_path():
	if get_parent()._class == "Directory":
		path = get_parent()._get_path() + directoryName + "/"
	elif directoryName == "/":
		path = "/"
	else:
		path = directoryName + "/"


#Returns this directory's path
func _get_path() -> String:
	return path


#Sets this directory's read perms
func _set_read_perms(newPerms: String):
	readPerms = newPerms


#Returns this directory's read perms
func _get_read_perms() -> String:
	return readPerms


#Sets this directory's write perms
func _set_write_perms(newPerms: String):
	writePerms = newPerms


#Returns this directory's write perms
func _get_write_perms() -> String:
	return writePerms


#Return this directory's children
func _get_children() -> Array:
	return children


#Adds all children of type 'File' or 'Directory' on this 'directory' to 'children'
func _refresh_connected_children():
	for child in get_children():
		if child.is_class("Timer"):
			pass
		elif children.find(child) == -1 && child._class == "File":
			children.append(child)
		elif children.find(child) == -1 && child._class == "Directory":
			children.append(child)


#Finds a 'directory' or 'file' with the provided 'path'
func _find_item_by_path(parentComp: Computer, pathParsed: Array, pathIn: String):
	if pathIn == ".." && parentComp.activeDirectory.get_parent()._class == "Directory":
		return parentComp.activeDirectory.get_parent()
	if pathIn == path:
		return self
	var selfParsed = parentComp._parse_path(path)
	for child in children:
		if is_instance_valid(child) && child._class == "Directory" && child._get_name() == pathParsed[selfParsed.size()]:
			return child._find_item_by_path(parentComp, pathParsed, pathIn)
		elif is_instance_valid(child) && child._class == "File" && child._get_name() + child._get_extension() == pathParsed[selfParsed.size()]:
			return child
	return null


#Removes this 'directory' from the scene
func _remove_self():
	for child in children:
		child._remove_self()
	queue_free()
