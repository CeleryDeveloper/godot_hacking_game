extends Node
class_name File


#Stores the custom 'class_name'
var _class = "File"


@export var fileName: String = "system31"
@export var fileExtension: String = ".sys"
@export var fileContent: String = "Debug"
@export var readPerms: String = "root"
@export var writePerms: String = "root"
@export var integralFile: bool = false
@export var printable: bool = false
@export var parentComputer: Computer = null

var path: String = "/"


func _ready() -> void:
	update_path()


#Sets this file's name
func set_file_name(newName: String):
	fileName = newName


#Returns this file's name
func get_file_name() -> String:
	return fileName


#Sets this file's extension
func set_extension(newExe: String):
	fileExtension = newExe


#Returns this file's extension
func get_extension() -> String:
	return fileExtension


#Sets this file's content
func set_content(newContent: String):
	fileContent = newContent


#Returns this file's content
func get_content() -> String:
	return fileContent


#Set's this file's printable attribute
func set_printable(newBool: bool):
	printable = newBool


#Returns this file's printable attribute
func get_printable() -> bool:
	return printable


#Sets this file's read perms
func set_read_perms(newPerms: String):
	readPerms = newPerms


#Returns this file's read perms
func get_read_perms() -> String:
	return readPerms


#Sets this file's write perms
func set_write_perms(newPerms: String):
	writePerms = newPerms


#Returns this file's write perms
func get_write_perms() -> String:
	return writePerms


#Returns the 'path' of this 'file'
func get_file_path() -> String:
	return path


#Updates the content of 'path'
func update_path():
	if get_parent()._class == "Directory":
		path = get_parent().get_directory_path() + fileName + fileExtension + "/"
	else:
		path = fileName + "/"


#Removes this 'file' from the scene
func remove_self():
	if integralFile:
		parentComputer.crash()
	queue_free()
