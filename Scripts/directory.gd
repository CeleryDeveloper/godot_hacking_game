extends Node
class_name Directory


#Stores the custom 'class_name'
var _class = "Directory"

@export var directoryName: String = "/"
@export var readPerms: String = "root"
@export var writePerms: String = "root"
@export var ownedBy: User = null


var parentComp: Computer = null
var path: String = "/"
var children: Array = []
var uid: int = randi_range(1, 99999)
var realOnStart: bool = true


func _ready() -> void:
	_refresh_connected_children()
	_update_path()


#Changes this directory's name
func set_directory_name(newName: String):
	directoryName = newName


#Returns this directory's name
func get_directory_name() -> String:
	return directoryName


#Updates the content of 'path'
func _update_path():
	if get_parent()._class == "Directory":
		path = get_parent().get_directory_path() + directoryName + "/"
	elif directoryName == "/":
		path = "/"
	else:
		path = directoryName + "/"


#Updates the crypto file in this directory if owned by user with crypto
func _update_crypto():
	if ownedBy != null:
		print("Updating Crypto: " + " Owner: " + str(ownedBy) + " owner crypto:" + str(ownedBy.get_crypto()) + " Parent comp: " + str(parentComp) + "UID: " + str(uid) + "Real start" + str(realOnStart))
	if parentComp != null && ownedBy != null && ownedBy.get_crypto() != 0:
		print("Adding Crypto: " + get_directory_path())
		var cryptoFile = parentComp.add_file(ownedBy.get_user_name() + "wallet", ".cry", ownedBy.get_perms(), ownedBy.get_perms(), get_directory_path(), self)
		print("cryptoFile: " + str(cryptoFile))
		cryptoFile.set_crypto(ownedBy.get_crypto())
		print("crypto created at" + str(parentComp.get_ID()) + ownedBy.get_user_name() + " Amount: " + str(ownedBy.get_crypto()))
		ownedBy.set_crypto(0)
		


#Returns this directory's path
func get_directory_path() -> String:
	return path


#Sets this directory's read perms
func set_read_perms(newPerms: String):
	readPerms = newPerms


#Returns this directory's read perms
func get_read_perms() -> String:
	return readPerms


#Sets this directory's write perms
func set_write_perms(newPerms: String):
	writePerms = newPerms


#Returns this directory's write perms
func get_write_perms() -> String:
	return writePerms


#Return this directory's children
func get_directory_children() -> Array:
	return children


func get_directory_owner() -> User:
	return ownedBy


func set_directory_owner(newOwner):
	print("Setting owner..." + str(newOwner))
	ownedBy = newOwner
	_update_crypto()


func get_parent_comp():
	return parentComp


func set_parent_comp(newParent):
	print("Setting parent comp..." + str(newParent))
	parentComp = newParent
	print("set parent comp! " + str(parentComp))
	_update_crypto()



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
func find_item_by_path(parentCompLocal: Computer, pathParsed: Array, pathIn: String):
	print("In:" + pathIn + "name:" + get_directory_name())
	print("path:" + path)
	if pathIn == ".." && parentCompLocal.activeDirectory.get_parent() is Directory:
		return parentCompLocal.activeDirectory.get_parent()
	if pathIn == path:
		print("Self:" + pathIn)
		return self
	var selfParsed = parentCompLocal._parse_path(path)
	for child in children:
																	  #DO NOT REMOVE AGAIN EVERYTHING WILL BREAK
		if is_instance_valid(child) && child is Directory && child.get_directory_name() == pathParsed[selfParsed.size()]:
			return child.find_item_by_path(parentCompLocal, pathParsed, pathIn)
		if is_instance_valid(child) && child is File && child.get_file_name() + child.get_extension() == pathParsed[selfParsed.size()]:
			return child
	var childNames: Array[String]
	for child in children:
		childNames.append(child.get_directory_name())
	print("Failed" + " Path: " + path + " Parsed name: " + pathParsed[selfParsed.size()] + " Children: " + str(childNames))
	return null


#Removes this 'directory' from the scene
func remove_self():
	for child in children:
		child.remove_self()
	queue_free()
