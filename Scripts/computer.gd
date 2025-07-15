extends Node
class_name Computer


#Stores the custom 'class_name'
var _class = "Computer"


const userPrefab = preload("res://Scenes/user.tscn")
const directoryPrefab = preload("res://Scenes/directory.tscn")
const filePrefab = preload("res://Scenes/file.tscn")
const portPrefab = preload("res://Scenes/port.tscn")


@export var computerName: String = "NameTemp"
@export var computerID: int = 12345
@export var playerOwned: bool = false


@onready var root: Directory = $Directory
@onready var activeDirectory: Directory = root
@onready var users: Array = [$User, $User2]
@onready var ports: Array = [$Port]
@onready var activeUser: User = users[1]

var connectedNetNode: Net_Node
var crashed: bool = false


#Runs on each 'refreshTimer' timeout
func _refresh():
	for user: User in users:
		if root.find_item_by_path(self ,_parse_path("/users/" + user.get_user_name() + "/"), "/users/" + user.get_user_name() + "/") != null:
			continue
		var userDir = add_directory(user.get_user_name(), user.get_perms(),user.get_perms(), "/users/", user)
		userDir.set_parent_comp(self)


func set_ID(newID: int) -> void:
	computerID = newID


func get_ID() -> int:
	return computerID


func set_com_name(newName: String) -> void:
	computerName = newName


func get_com_name() -> String:
	return computerName


func get_root() -> Directory:
	return root


func set_active_directory(dirPathParsed: Array, dirPath: String) -> int:
	var returnedDirectory = root.find_item_by_path(self, dirPathParsed, dirPath)
	if is_instance_valid(returnedDirectory) && returnedDirectory._class == "File":
		return 2
	if is_instance_valid(returnedDirectory) && activeUser.eval_perms(returnedDirectory.get_read_perms()):
		activeDirectory = returnedDirectory
		return 1
	elif is_instance_valid(returnedDirectory) && !activeUser.eval_perms(returnedDirectory.get_read_perms()):
		return 3
	return 2


func get_active_directory() -> Directory:
	return activeDirectory


func add_directory(dirName: String, dirReadPerms: String, dirWritePerms: String, parentPath: String, ownedBy: User = null):
	var newDir: Directory = directoryPrefab.instantiate()
	var parent: Directory = root.find_item_by_path(self, _parse_path(parentPath), parentPath)
	if !is_instance_valid(parent):
		print("invalid" + parentPath)
		return null
	newDir.set_directory_name(dirName)
	newDir.set_read_perms(dirReadPerms)
	newDir.set_write_perms(dirWritePerms)
	newDir.set_directory_owner(ownedBy)
	newDir.realOnStart = false
	parent.add_child(newDir)
	return newDir


func add_file(fileName: String, fileExtension: String, fileReadPerms: String, fileWritePerms: String, parentPath: String, parentDir: Directory = null):
	var newFile: File = filePrefab.instantiate()
	var parent: Directory = root.find_item_by_path(self, _parse_path(parentPath), parentPath)
	if parentDir != null:
		parent = parentDir
	if !is_instance_valid(parent):
		print("add file invalid: " + parentPath + "| Path parsed: " + str(_parse_path(parentPath)))
		return null
	newFile.set_file_name(fileName)
	newFile.set_extension(fileExtension)
	newFile.set_read_perms(fileReadPerms)
	newFile.set_write_perms(fileWritePerms)
	parent.add_child(newFile)
	return newFile


func remove_item(parsedPath: Array, Path: String):
	var returnedItem = root.find_item_by_path(self, parsedPath, Path)
	if returnedItem != null && activeUser.eval_perms(returnedItem.get_write_perms()):
		returnedItem.remove_self()
		return 1
	elif returnedItem != null && !activeUser.eval_perms(returnedItem.get_write_perms()):
		return 3
	return 2


#Splits up a path for finding a 'Directory'
func _parse_path(pathToParse: String) -> Array:
	var pathParsed: Array
	pathParsed.append("/")
	
	#Splits the path at each slash and appends the returned array to 'pathParsed'
	pathParsed.append_array(pathToParse.split("/", false))
	#Loops through 'commandParsed' and removes spaces
	for i in range(pathParsed.size()):
		pathParsed[i] = pathParsed[i]
	return pathParsed


#Adds a 'user' to this machine, returns false if failure
func add_user(newUserName: String, password: String = "", perms: String = "guest", crypto: float = 0) -> bool:
	var newUser: User = userPrefab.instantiate()
	for user in users:
		if user.get_user_name() == newUserName:
			return false
	users.append(newUser)
	newUser.set_user_name(newUserName)
	newUser.set_password(password)
	newUser.set_perms(perms)
	newUser.set_crypto(crypto)
	self.add_child(newUser)
	return true


func add_port(newPortNumber: int) -> bool:
	var newPort: Port = portPrefab.instantiate()
	for port: Port in ports:
		if port.get_number() == newPortNumber:
			return false
	newPort.set_number(newPortNumber)
	self.add_child(newPort)
	return true


#Removes a 'user' from this machine, returns false if failure
func remove_user(user: String) -> bool:
	var toRemove = users.find(user)
	if  toRemove != -1 && user != "root":
		users.remove_at(toRemove)
		return true
	return false


func get_users() -> Array:
	return users


func get_active_user() -> User:
	return activeUser


func find_user_by_name(searchName: String):
	for user in users:
		if user.get_user_name() == searchName:
			return user
	return null


#Sets the 'activeUser', returns false if failure
func set_active_user(userName: String, password: String = "") -> bool:
	var user = find_user_by_name(userName)
	if user != null && user.get_password() == password:
		activeUser = user
		return true
	return false


func get_ports() -> Array:
	return ports


func get_connected_NetNode() -> Net_Node:
	return connectedNetNode


#Changes the 'connectedNetNode'
func connect_NetNode(newNode: Net_Node):
	connectedNetNode = newNode
	connectedNetNode.add_computer(self)


#Crashes the current computer
func crash():
	crashed = true
