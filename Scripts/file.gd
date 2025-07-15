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
@export var crypto: float = 0
@export var parentComputer: Computer = null

var path: String = "/"


func _ready() -> void:
	update_path()
	


func set_file_name(newName: String):
	fileName = newName


func get_file_name() -> String:
	return fileName


func set_extension(newExe: String):
	fileExtension = newExe


func get_extension() -> String:
	return fileExtension


func set_content(newContent: String):
	fileContent = newContent


func get_content() -> String:
	return fileContent


func set_printable(newBool: bool):
	printable = newBool


func get_printable() -> bool:
	return printable


func set_read_perms(newPerms: String):
	readPerms = newPerms


func get_read_perms() -> String:
	return readPerms


func set_write_perms(newPerms: String):
	writePerms = newPerms


func get_write_perms() -> String:
	return writePerms


func get_file_path() -> String:
	return path


func get_crypto() -> float:
	return crypto


func set_crypto(newBalance):
	crypto = newBalance


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
