extends Node
class_name Contact


@export var contactName: String = "DEBUG"
@export var lastMessage: String = "Debug"
var playerTurn: bool = false
var messagesNPC: Array[String] = []
var messagesPlayer: Array[String] = []


func set_contact_name(newName: String):
	contactName = newName


func get_contact_name() -> String:
	return contactName


func set_last_message(newLastMessage: String):
	lastMessage = newLastMessage


func get_last_message() -> String:
	return lastMessage


func new_message(newMessage: String):
	messagesNPC.append(newMessage)
	lastMessage = newMessage


func new_message_player(newMessage: String):
	messagesPlayer.append(newMessage)
	lastMessage = newMessage
