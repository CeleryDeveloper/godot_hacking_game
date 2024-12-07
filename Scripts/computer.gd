extends Node
class_name Computer


#Stores the custom 'class_name'
var _class = "Computer"


const userPrefab = preload("res://Scenes/user.tscn")
const directoryPrefab = preload("res://Scenes/directory.tscn")


@export var computerName: String = "NameTemp"
@export var computerID: int = 12345


@onready var root: Directory = $Directory
@onready var activeDirectory: Directory = root
@onready var users = [$User, $User2]
@onready var activeUser: User = users[1]


var connectedNetNode: Net_Node


func _ready() -> void:
	for user in users:
		_add_directory(user._get_name(), user._get_perms(), "/users/")


#Runs on each 'refreshTimer' timeout
func _refresh():
	for user: User in users:
		if root._find_directory_by_path(self, _parse_path("/users/" + user._get_name() + "/"), "/users/" + user._get_name() + "/") != null:
			break
		_add_directory(user._get_name(), user._get_perms(), "/users/")


#Changes this machine's ID
func _set_ID(newID: int) -> void:
	computerID = newID


#Returns this machine's ID
func _get_ID() -> int:
	return computerID


#Changes this machine's name
func _set_name(newName: String) -> void:
	computerName = newName


#Returns this machine's name
func _get_name() -> String:
	return computerName


#Returns this machine's root directory
func _get_root() -> Directory:
	return root


#Changes this machine's 'activeDirectory'
func _set_active_directory(dirPathParsed: Array, dirPath: String) -> int:
	var returnedDirectory: Directory = root._find_directory_by_path(self, dirPathParsed, dirPath)
	if returnedDirectory != null && activeUser._eval_perms(returnedDirectory._get_perms()):
		activeDirectory = returnedDirectory
		return 1
	elif returnedDirectory != null && !activeUser._eval_perms(returnedDirectory._get_perms()):
		return 3
	return 2


#Returns the active 'directory'
func _get_active_directory() -> Directory:
	return activeDirectory


func _add_directory(dirName: String, dirPerms: String, parentPath: String):
	var newDir: Directory = directoryPrefab.instantiate()
	var parent: Directory = root._find_directory_by_path(self ,_parse_path(parentPath), parentPath)
	if !is_instance_valid(parent):
		return false
	newDir._set_name(dirName)
	newDir._set_perms(dirPerms)
	parent.add_child(newDir)


func _remove_directory(parsedPath: Array, Path: String):
	var returnedDirectory: Directory = root._find_directory_by_path(self, parsedPath, Path)
	if returnedDirectory != null && activeUser._eval_perms(returnedDirectory._get_perms()):
		returnedDirectory.queue_free()
		return 1
	elif returnedDirectory != null && !activeUser._eval_perms(returnedDirectory._get_perms()):
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
func _add_user(newUserName: String, password: String = "", perms: String = "guest") -> bool:
	var newUser: User = userPrefab.instantiate()
	for user in users:
		if user._get_name() == newUserName:
			return false
	users.append(newUser)
	newUser._set_name(newUserName)
	newUser._set_password(password)
	newUser._set_perms(perms)
	self.add_child(newUser)
	return true


#Removes a 'user' from this machine, returns false if failure
func _remove_user(user: String) -> bool:
	var toRemove = users.find(user)
	if  toRemove != -1 && user != "root":
		users.remove_at(toRemove)
		return true
	return false


#Returns Array of all this machine's 'users'
func _get_users() -> Array:
	return users


#Returns the active 'user' on this machine
func _get_active_user() -> User:
	return activeUser


#Returns the 'user' with the matching name 
func _find_user_by_name(searchName: String):
	for user in users:
		if user._get_name() == searchName:
			return user
	return null


#Sets the 'activeUser', returns false if failure
func _set_active_user(userName: String, password: String = "") -> bool:
	var user = _find_user_by_name(userName)
	if user != null && user._get_password() == password:
		activeUser = user
		return true
	return false


#Returns the 'connectedNetNode'
func _get_connected_NetNode() -> Net_Node:
	return connectedNetNode


#Changes the 'connectedNetNode'
func _connect_NetNode(newNode: Net_Node):
	connectedNetNode = newNode
	connectedNetNode._add_computer(self)
