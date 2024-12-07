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


func _set_read_perms(newPerms: String):
	readPerms = newPerms


#Returns this directory's read perms
func _get_read_perms() -> String:
	return readPerms


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


#Finds a 'directory' with the same name
func _find_directory_by_path(parentComp: Computer, dirPathParsed: Array, dirPath: String) -> Directory:
	if dirPath == ".." && parentComp.activeDirectory.get_parent()._class == "Directory":
		return parentComp.activeDirectory.get_parent()
	if dirPath == path:
		return self
	var selfParsed = parentComp._parse_path(path)
	for child in children:
		if is_instance_valid(child) && child._class == "Directory" && child._get_name() == dirPathParsed[selfParsed.size()]:
			return child._find_directory_by_path(parentComp, dirPathParsed, dirPath)
	return null
