extends Node
class_name User

#Stores the custom 'class_name' 
#as there is no way to access the name declared using the 'class_name' keyword
const _class = "User"


@export var userName: String = "root"
@export var userPassword: String = "admin"
@export var userPerms: String = "root"
@export var crypto: float = 0


func get_user_name() -> String:
	return userName


func set_user_name(newName: String):
	userName = newName


func get_password() -> String:
	return userPassword


func set_password(newPass: String):
	userPassword = newPass


func get_perms() -> String:
	return userPerms


func set_perms(newPerms: String):
	userPerms = newPerms


func get_crypto() -> float:
	return crypto


func set_crypto(newBalance: float):
	crypto = newBalance


#Compares the 'perms' passed in to this user's 'perms'
func eval_perms(inPerms: String):
	if inPerms == "guest":
		return true
	elif inPerms == userPerms:
		return true
	elif userPerms == "root":
		return true
	return false
