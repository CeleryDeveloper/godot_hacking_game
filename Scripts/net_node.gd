extends Node
class_name Net_Node


var _class = "Net_Node"

@export var company: String = "TEMPCORP"
@export var nodeName: String = "NameTemp"
@export var nodeID: int = 123

var connectedComputers: Array


#Returns 'NetNode' name
func _get_name() -> String:
	return nodeName


#Changes 'NetNode' name 
func _set_name(newName: String):
	nodeName = newName


#Returns 'NetNode' ID
func _get_ID() -> int:
	return nodeID


#Changes 'NetNode' ID
func _set_ID(newID: int):
	nodeID = newID


#Returns 'NetNode' company
func _get_corp():
	return company


#Changes 'NetNode' company
func _set_corp(newCorp: String):
	company = newCorp


#Adds a 'Computer' to 'connectedComputers' returns false if failure
func _add_computer(comp: Computer) -> bool:
	if connectedComputers.find(comp) == -1:
		connectedComputers.append(comp)
		return true
	return false


#Removes a 'Computer' from 'connectedComputers' returns false if failure
func _remove_computer(comp: Computer):
	var compIndex = connectedComputers.find(comp)
	if  compIndex != -1:
		connectedComputers.remove_at(compIndex)
		return true
	return false


#Returns 'connectedComputers' Array
func _get_computers() -> Array:
	return connectedComputers
