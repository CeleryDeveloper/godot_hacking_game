extends Node
class_name Computer


#Stores the custom 'class_name'
var _class = "Computer"


const userPrefab = preload("res://Scenes/user.tscn")
const directoryPrefab = preload("res://Scenes/directory.tscn")
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


func _ready() -> void:
	for user: User in users:
		add_directory(user.get_user_name(), user.get_perms(),user.get_perms(), "/users/")


#Runs on each 'refreshTimer' timeout
func _refresh():
	for user: User in users:
		if root.find_item_by_path(self, _parse_path("/users/" + user.get_user_name() + "/"), "/users/" + user.get_user_name() + "/") != null:
			break
		add_directory(user.get_user_name(), user.get_perms(),user.get_perms(), "/users/")


#Changes this machine's ID
func set_ID(newID: int) -> void:
	computerID = newID


#Returns this machine's ID
func get_ID() -> int:
	return computerID


#Changes this machine's name
func set_com_name(newName: String) -> void:
	computerName = newName


#Returns this machine's name
func get_com_name() -> String:
	return computerName


#Returns this machine's root directory
func get_root() -> Directory:
	return root


#Changes this machine's 'activeDirectory'
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


#Returns the active 'directory'
func get_active_directory() -> Directory:
	return activeDirectory


func add_directory(dirName: String, dirReadPerms: String,dirWritePerms: String, parentPath: String):
	var newDir: Directory = directoryPrefab.instantiate()
	var parent: Directory = root.find_item_by_path(self ,_parse_path(parentPath), parentPath)
	if !is_instance_valid(parent):
		return false
	newDir.set_directory_name(dirName)
	newDir.set_read_perms(dirReadPerms)
	newDir.set_write_perms(dirWritePerms)
	parent.add_child(newDir)


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
	
	#Splits the string of arguments at each comma and appends the returned array to 'commandParsed'
	pathParsed.append_array(pathToParse.split("/", false))
	#Loops through 'commandParsed' and removes spaces
	for i in range(pathParsed.size()):
		pathParsed[i] = pathParsed[i]
	return pathParsed


#Adds a 'user' to this machine, returns false if failure
func add_user(newUserName: String, password: String = "", perms: String = "guest") -> bool:
	var newUser: User = userPrefab.instantiate()
	for user in users:
		if user.get_user_name() == newUserName:
			return false
	users.append(newUser)
	newUser.set_user_name(newUserName)
	newUser.set_password(password)
	newUser.set_perms(perms)
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


#Returns Array of all this machine's 'users'
func get_users() -> Array:
	return users


#Returns the active 'user' on this machine
func get_active_user() -> User:
	return activeUser


#Returns the 'user' with the matching name 
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

#Returns Array of this machine's 'ports'
func get_ports() -> Array:
	return ports

#Returns the 'connectedNetNode'
func get_connected_NetNode() -> Net_Node:
	return connectedNetNode


#Changes the 'connectedNetNode'
func connect_NetNode(newNode: Net_Node):
	connectedNetNode = newNode
	connectedNetNode.add_computer(self)


#Crashes the current computer
func crash():
	crashed = true
