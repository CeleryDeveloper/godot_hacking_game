extends Node
class_name User

#Stores the custom 'class_name' 
#as there is no way to access the name declared using the 'class_name' keyword
const _class = "User"


@export var userName: String = "root"
@export var userPassword: String = "admin"
@export var userPerms: String = "root"


#Returns this user's name
func get_user_name() -> String:
	return userName


#Changes this user's name
func set_user_name(newName: String):
	userName = newName


#Returns this user's password
func get_password() -> String:
	return userPassword


#Changes this user's password
func set_password(newPass: String):
	userPassword = newPass


#Returns this user's perms
func get_perms() -> String:
	return userPerms


#Changes this user's perms
func set_perms(newPerms: String):
	userPerms = newPerms


#Compares the 'perms' passed in to this user's 'perms'
func eval_perms(inPerms: String):
	if inPerms == "guest":
		return true
	elif inPerms == userPerms:
		return true
	elif userPerms == "root":
		return true
	return false
