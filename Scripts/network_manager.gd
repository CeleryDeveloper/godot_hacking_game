extends Node
class_name Network_Manager


var _class = "Network_Manager"

const computerPrefab = preload("res://Scenes/computer.tscn")
const netNodePrefab = preload("res://Scenes/net_node.tscn")


@export var startingComputers: int = 10
@export var startingNetNodes: int = 4
@export var maxComputers: int = 50
@export var maxBatch: int = 15


var connectedComputers: Array
var connectedNetNodes: Array

#Arrays for 'computer' generation
var computerNameGenPrefix = ["Cool", "Epic", "Lame", "Super", "Potato", "Sexy", "New", "Trash", "Secure", "Premium", "Ultimate", "Uber", "Hacker", "Pirate", "Private", "Speedy"]
var computerNameGenSuffix = ["Computer", "PC", "Laptop", "Comp", "Workstation", "Battlestation", "Machine", "Server", "Desktop", "Cruncher", "Processor", "PersonalComputer", "GamingPC"]
var computerUserGen = ["Tracy", "Robert", "Sam", "Cherry", "Lynn", "Thor", "Daddy", "User", "XxRogueWarriorxX", "Viper", "Admin", "Corprate", "Amy", "Jared", "AJ", "Sammy", "Bob", "Jimmy", "Ford", "Wizard", "Sorcerer", "Mage", "Terance"]


#Arrays for 'NetNode' generation
var netNodeNameGenPrefix = ["Secure", "Solid", "Premium", "Standard", "Fast", "Speedy", "Reliable"]
var netNodeNameGenSuffix = ["NetNode", "NN", "Network", "NSP", "NetworkServiceProvider", "AccessPoint"]
var netNodeCompanyNameGen = ["GlobalNetworks", "CyberSec", "SilverComputers", "SpeedyAccess", "MilNET"]


#Arrays for 'password' generation
var passwordGenPrefix = ["love", "Sexy", "sad", "g00d", "BAD", "Super", "ev1l", "Stup1d", "m1SSin9", "4wEs0me", "AwFu1", "SeCUrE", "H4cKeR", "P0RT", "Pr1vate"]
var passwordGenSuffix = ["", "password", "daddy", "GUY", "K3Y", "Dexter", "Spike", "Spagett1", "bEEfStr0gan0ff", "g0d", "p1easeD0n'tHackMEi'mSORRY!", "h4CkEr", "B0X", "K1TtEn2", "C0mpU1ER", "admin", "P1r4t3", "w1Z4rd", "S0rc3r3r", "m4G3"]


func _ready() -> void:
	_refresh_connected_children()
	for i in range(startingNetNodes):
		_random_NetNode()
	for i in range(startingComputers):
		_random_computer()


#Returns the 'connectedComputers' Array
func _get_computers() -> Array:
	return connectedComputers


#Returns the 'connectedNetNodes' Array
func _get_netNodes() -> Array:
	return connectedNetNodes


#Adds all children of type 'computer' or 'Net_Node' on 'network manager' to 'connectedComputer'
func _refresh_connected_children():
	for child in get_children():
		if connectedComputers.find(child) == -1 && child._class == "Computer":
			connectedComputers.append(child)
		if connectedNetNodes.find(child) == -1 && child._class == "Net_Node":
			connectedNetNodes.append(child)


#Finds a 'computer' with the specified 'id', returns null if failure
func _find_computer_by_ID(id: int) -> Computer:
	for comp in connectedComputers:
		if comp._get_ID() == id:
			return comp
	return null


#Finds a 'NetNode' with the specified 'id', returns null if failure
func _find_NetNode_by_ID(id: int) -> Net_Node:
	for node in connectedNetNodes:
		if node._get_ID() == id:
			return node
	return null


func _batch_gen():
	var available_space = maxComputers - len(connectedComputers)  # Ensure we're using len()

	if available_space >= maxBatch:
		for i in range(maxBatch):
			_random_computer()
		print("Generating '%s' computers..." % str(maxBatch))
		print("%s Total computers!" % len(connectedComputers))

	elif available_space > 0:  # Ensure this only runs when there's space for at least 1 computer
		for i in range(available_space):
			_random_computer()
		print("Generating '%s' computers..." % str(available_space))
		print("%s Total computers!" % len(connectedComputers))

#Generates a 'computer' with the specified information
func _generate_computer(ID: int, name: String) -> Computer:
	var newComputer = computerPrefab.instantiate()
	newComputer._set_ID(ID)
	newComputer._set_name(name)
	connectedComputers.append(newComputer)
	add_child(newComputer)
	newComputer._connect_NetNode(connectedNetNodes.pick_random())
	return newComputer


#Randomly generates a 'computer'
func _random_computer():
	var mainUser: String = computerUserGen.pick_random() 
	var computerName: String
	var password: String = ""
	
	if randi_range(1, 4):
		mainUser += str(randi_range(1, 99))
	
	if randi_range(1, 4) == 1:
		computerName += mainUser + "'s"
	if randi_range(1, 2) == 1:
		computerName += computerNameGenPrefix.pick_random()
	
	computerName += computerNameGenSuffix.pick_random()
	
	if randi_range(1, 3) == 1:
		computerName += str(randi_range(1, 9999))
	
	var newID = randi_range(1, 999999)
	
	while(_find_computer_by_ID(newID) != null):
		newID = randi_range(1, 999999)
	
	var computer = _generate_computer(newID, computerName)
	
	if randi_range(1, 10) != 1:
		password = _random_password(mainUser)
	
	#Picks if the 'mainUser' should have root perms
	var mainUserPerms
	if randi_range(1, 3) == 1:
		mainUserPerms = "root"
	else:
		mainUserPerms = mainUser
	
	computer._add_user(mainUser, password, mainUserPerms)
	
	#Generates a second user
	if randi_range(1, 3) == 1:
		var secondUser = computerUserGen.pick_random()
		var secondUserPerms
		if randi_range(1, 4) == 1:
			secondUserPerms = "root"
		else:
			secondUserPerms = secondUser
		if randi_range(1, 4):
			secondUser += str(randi_range(1, 99))
		var secondPassword = ""
		if randi_range(1, 10) != 1:
			secondPassword = _random_password(secondUser)
		computer._add_user(secondUser, secondPassword, secondUser)


#Generates a 'NetNode' with the specified information
func _generate_NetNode(ID: int, name: String, company: String) -> Net_Node:
	var newNetNode = netNodePrefab.instantiate()
	newNetNode._set_ID(ID)
	newNetNode._set_name(name)
	newNetNode._set_corp(company)
	connectedNetNodes.append(newNetNode)
	add_child(newNetNode)
	return newNetNode


#Randomly generates a 'computer'
func _random_NetNode():
	var companyName: String = netNodeCompanyNameGen.pick_random()
	var netNodeName: String
	var password: String = ""
	
	if randi_range(1, 4) == 1:
		netNodeName += companyName
	if randi_range(1, 2) == 1:
		netNodeName += netNodeNameGenPrefix.pick_random()
	
	netNodeName += netNodeNameGenSuffix.pick_random()
	
	if randi_range(1, 3) == 1:
		netNodeName += str(randi_range(1, 9999))
	
	var newID = randi_range(1, 999)
	
	while(_find_computer_by_ID(newID) != null):
		newID = randi_range(1, 999)
	
	var netNode = _generate_NetNode(newID, netNodeName, companyName)


#Randomly generates a 'password'
func _random_password(userName: String = "") -> String:
	var password: String
	
	
	if randi_range(1, 5) == 1:
		password += userName
		
	if randi_range(1, 3) == 1:
		password += passwordGenPrefix.pick_random()
	
	password += passwordGenSuffix.pick_random()
	
	if randi_range(1, 4) == 1:
		password += str(randi_range(1, 9999))
	
	return password
