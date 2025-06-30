extends Node
class_name Net_Node

#Stores the custom 'class_name' 
#as there is no way to access the name declared using the 'class_name' keyword
const _class = "Net_Node"

@export var company: String = "TEMPCORP"
@export var nodeName: String = "NameTemp"
@export var nodeID: int = 123

var connectedComputers: Array


#Returns 'NetNode' name
func get_NetNode_name() -> String:
	return nodeName


#Changes 'NetNode' name 
func set_NetNode_name(newName: String):
	nodeName = newName


#Returns 'NetNode' ID
func get_ID() -> int:
	return nodeID


#Changes 'NetNode' ID
func set_ID(newID: int):
	nodeID = newID


#Returns 'NetNode' company
func get_corp():
	return company


#Changes 'NetNode' company
func set_corp(newCorp: String):
	company = newCorp


#Adds a 'Computer' to 'connectedComputers' returns false if failure
func add_computer(comp: Computer) -> bool:
	if connectedComputers.find(comp) == -1:
		connectedComputers.append(comp)
		return true
	return false


#Removes a 'Computer' from 'connectedComputers' returns false if failure
func remove_computer(comp: Computer):
	var compIndex = connectedComputers.find(comp)
	if  compIndex != -1:
		connectedComputers.remove_at(compIndex)
		return true
	return false


#Returns 'connectedComputers' Array
func get_computers() -> Array:
	return connectedComputers
