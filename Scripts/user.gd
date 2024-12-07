extends Node
class_name User


#Stores the custom 'class_name'
var _class = "User"


@export var userName: String = "root"
@export var userPassword: String = "admin"
@export var userPerms: String = "root"


#Returns this user's name
func _get_name() -> String:
	return userName


#Changes this user's name
func _set_name(newName: String):
	userName = newName


#Returns this user's password
func _get_password() -> String:
	return userPassword


#Changes this user's password
func _set_password(newPass: String):
	userPassword = newPass


#Returns this user's perms
func _get_perms() -> String:
	return userPerms


#Changes this user's perms
func _set_perms(newPerms: String):
	userPerms = newPerms


#Compares the 'perms' passed in to this user's 'perms'
func _eval_perms(inPerms: String):
	if inPerms == "guest":
		return true
	elif inPerms == userPerms:
		return true
	elif userPerms == "root":
		return true
	return false
