extends Node


var currentComputer: Computer = null
var commandHistory: Array[String]


@onready var home: Computer = $"../NetworkManager/Computer"
@onready var networkManager: Network_Manager = $"../NetworkManager"
@onready var caret: Label = $"../Terminal/MarginContainer/Rows/InputArea/HBoxContainer/Caret"


func _initialize(startingComputer):
	currentComputer = startingComputer
	currentComputer._connect_NetNode(networkManager._get_netNodes().pick_random())


func _process_command(input: String) -> String:
	#Stores the command in 'commandHistory'
	commandHistory.insert(0, input)
	if commandHistory.size() > 30:
		commandHistory.remove_at(commandHistory.size() - 1)
	
	#Separates the 'command' from its 'arguments' for the match-case later
	var commandParsed = input.split(":", false)
	
	#Throws error to 'terminal' if the 'commandParsed' array has no data
	if commandParsed.size() == 0:
		return "[color=red]Error:[/color] Command could not be parsed"
	
	#If 'commandParsed' has any arguments runs the '_parse_command_args' function
	if commandParsed.size() > 1:
		commandParsed = _parse_command_args(commandParsed)

	print(commandParsed.size())
	print(commandParsed)
	
	#Gets the actual 'command' with no arguments from 'commandParsed'
	var command = commandParsed[0].strip_edges()
	
	#Runs a command function if 'command' is recognised 
	match command:
		"help":
			return help(commandParsed)
		"man":
			return help(commandParsed)
		"user":
			return user(commandParsed)
		"cu":
			return changeUser(commandParsed)
		"useradd":
			return addUser(commandParsed)
		"lu":
			return listUsers(commandParsed)
		"ls":
			return listFiles(commandParsed)
		"cd":
			return changeDirectory(commandParsed)
		"mkdir":
			return makeDirectory(commandParsed)
		"rm":
			return remove(commandParsed)
		"scan":
			return scan(commandParsed)
		"comcon":
			return connectComputer(commandParsed)
		"nodecon":
			return connectNetNode(commandParsed)
		"info":
			return info(commandParsed)
		#Default case if 'command' is not recognized
		_:
			return "command [color=red]'%s'[/color] was not recognized!" % command


#Start of command functions
#Displays a list of all available commands
func help(fullCommand: Array):
	if fullCommand.size() != 1:
		return _error_arg_number(fullCommand.size(), 0, "help")

	return "[color=green]help: - [/color] Returns this list of commands.\n[color=green]user: - [/color] Returns information on the current user.[color=green]\nlu: - [/color] List all users on current machine.\n[color=green]ls: - [/color] Lists files and directories in the working directory on the current machine.\n[color=green]info: - [/color]Returns info on the current machine.\n[color=green]scan: - [/color]Returns all computers on the connected NetNode.\n[color=green]comcon:int -> ID - [/color]Connects to the computer with the specified ID. (Cannot connect to a computer on a different NetNode to home)\n[color=green]nodecon:int -> ID - [/color]Connects to the NetNode with the specified ID. (Connecting to a different NetNode than your home computer will break the connection)\n[color=green]cu:String -> username, (optional)String -> password - [/color]Changes active user on current machine.\n[color=green]useradd:String -> username, (optional)String -> password, (optional)String -> permissions - [/color]Adds a new user to the current machine.\n[color=green]cd:String -> directory path('..' to go back a directory) - [/color]Changes the working directory.\n[color=green]mkdir:String -> name, String -> parent path('.' for current directory), (optional)String -> read permissions, (optional)String -> write permissions - [/color]Creates a directory with the specified name under the parent directory."


#Displays information on the current user
func user(fullCommand: Array):
	#If an incorrect number of arguments is used an error will be returned
	if fullCommand.size() != 1:
		return _error_arg_number(fullCommand.size(), 0, "user")
	
	return "Current user: [color=green]'%s'[/color] \nUser password: [color=green]'%s'[/color] \nUser perms: [color=green]'%s'[/color]" % [currentComputer._get_active_user()._get_name(), currentComputer._get_active_user()._get_password(), currentComputer._get_active_user()._get_perms()]


#Changes the 'active user' on the current machine
func changeUser(fullCommand: Array):
	if fullCommand.size() != 2 && fullCommand.size() != 3:
		return _error_arg_number(fullCommand.size(), 1, "cu", 1)
	
	#Result returned from '_set_active_user' as bool indicating success or failure
	var result: bool
	
	#Only passes 'password' argument if a 'password' was specified, if not the password is empty by default
	if fullCommand.size() == 2:
		result = currentComputer._set_active_user(fullCommand[1])
	else:
		result = currentComputer._set_active_user(fullCommand[1], fullCommand[2])
	
	#If result is true the 'active user' is changed, else return error
	if result:
		return "Changed to user [color=green]'%s'[/color]." % fullCommand[1]
	return "command failed, incorrect [color=red]password[/color] or user [color=red]'%s'[/color] does not exist!" % fullCommand[1]


#Lists 'users' on current machine
func listUsers(fullCommand: Array):
	if fullCommand.size() != 1:
		return _error_arg_number(fullCommand.size(), 0, "user")
	
	#String initialized here for formatting later
	var userListString: String
	#Gets the array of 'users' from the current machine
	var users = currentComputer._get_users()
	
	#Formats the 'users' into an ordered list
	for i in range(users.size()):
		if users[i] == currentComputer._get_active_user():
			userListString += "[color=green]"
		userListString += str(i + 1) + ". " + users[i]._get_name() + ": "
		if users[i] == currentComputer._get_active_user():
			userListString += "[/color]"
		userListString += users[i]._get_password() + "\n"
	
	return userListString


#Adds a 'user' to the current machine
func addUser(fullCommand: Array) -> String:
	if fullCommand.size() != 2 && fullCommand.size() != 3 && fullCommand.size() != 4:
		return _error_arg_number(fullCommand.size(), 1, "useradd", 2)
	
	var username = ""
	var password = ""
	var perms = ""
	
	if currentComputer._get_active_user()._get_perms() == "guest":
		return "Users with [color=red]guest[/color] permissions cannot use adduser!"
	
	for user in currentComputer._get_users():
		if user._get_name() == fullCommand[1]:
			return "Name [color=red]'%s'[/color] already taken!" % fullCommand[1]
	username = fullCommand[1]
	perms = username
	
	if fullCommand.size() == 3:
		password = fullCommand[2]
	if fullCommand.size() == 4:
		perms = fullCommand[3]
	
	if currentComputer._get_active_user()._get_perms() != "root" && perms == "root":
		return "Users with [color=red]'%s'[/color] permissions cannot create a user with root access!" % currentComputer._get_active_user()._get_perms()
	
	currentComputer._add_user(username, password, perms)
	
	return "Created user [color=green]%s[/color]!" % username


#Lists children of the 'activeDirectory' on the current machine
func listFiles(fullCommand: Array):
	if fullCommand.size() != 1 && fullCommand.size() != 2:
		return _error_arg_number(fullCommand.size(), 1, "ls", 1)
	
	#String initialized here for formatting later
	var fileListString: String
	#Gets the array of 'users' from the current machine
	var files = currentComputer._get_active_directory()._get_children()
	#Formats the 'users' into an ordered list
	for i in range(files.size()):
		if !is_instance_valid(files[i]):
			continue
		fileListString += str(i + 1) + ". " + "[color=green]" + files[i]._get_name() + ":[/color] "
		if currentComputer._get_active_user()._eval_perms(files[i]._get_read_perms()):
			fileListString += "[color=green]" + files[i]._get_read_perms() + "[/color], "
		else:
			fileListString += "[color=red]" + files[i]._get_read_perms() + "[/color], "
		if currentComputer._get_active_user()._eval_perms(files[i]._get_write_perms()):
			fileListString += "[color=green]" + files[i]._get_write_perms() + "[/color]\n"
		else:
			fileListString += "[color=red]" + files[i]._get_write_perms() + "[/color]\n"
	
	return fileListString


#Changes the 'activeDirectory' of the current machine
func changeDirectory(fullCommand: Array):
	if fullCommand.size() != 2:
		return _error_arg_number(fullCommand.size(), 1, "cd")
	
	var pathString: String = fullCommand[1]
	
	if pathString[0] != "/" && pathString != "..":
		pathString = currentComputer._get_active_directory()._get_path() + pathString
	if pathString[pathString.length() - 1] != "/" && pathString != "..":
		pathString += "/"
	
	var success = currentComputer._set_active_directory(_parse_path(fullCommand[1]), pathString)
	if success == 1:
		return "Changed active directory to [color=green]'%s'[/color]" % currentComputer._get_active_directory()._get_name()
	elif success == 3:
		return "User [color=red]'%s'[/color] does not have permission to view [color=green]'%s'[/color]" % [currentComputer._get_active_user()._get_name(), fullCommand[1]]
	return "No directory with path [color=red]'%s'[/color] was found!" % fullCommand[1]


#Creates a 'directory' with the specified details on the current machine
func makeDirectory(fullCommand: Array) -> String:
	if fullCommand.size() < 3 || fullCommand.size() > 5:
		return _error_arg_number(fullCommand.size(), 2, "mkdir", 2)
	
	var dirName: String = fullCommand[1]
	var pathString = fullCommand[2]
	var dirWritePerms = currentComputer._get_active_user()._get_name()
	var dirReadPerms = currentComputer._get_active_user()._get_name()
	
	#Prevents unusable directorys being created
	if dirName.contains("/"):
		return "Path name cannot contain [color=red]'/'[/color]!"
	
	#Checks and prepares the path input for later
	if pathString[0] != "/" && pathString != '.':
		pathString = currentComputer._get_active_directory()._get_path() + pathString
	if pathString == '.':
		pathString = currentComputer._get_active_directory()._get_path()
	if pathString[pathString.length() - 1] != "/":
		pathString += "/"
	
	#Checks if the same 'directory' already exists
	if currentComputer._get_root()._find_directory_by_path(currentComputer, _parse_path(pathString + dirName + "/"), pathString + dirName + "/"):
		return "directory with path [color=red]'%s'[/color] already exists!" % [pathString + dirName + "/"]
	
	#Checks if the 'activeUser' has permission to create the 'directory'
	if fullCommand.size() == 5 && currentComputer._get_active_user()._eval_perms(fullCommand[3]) && currentComputer._get_active_user()._eval_perms(fullCommand[4]):
		dirReadPerms = fullCommand[3]
		dirWritePerms = fullCommand[4]
	elif fullCommand.size() == 4 && currentComputer._get_active_user()._eval_perms(fullCommand[3]):
		dirWritePerms = fullCommand[3]
		dirReadPerms = fullCommand[3]
	#Different errors for insufficient permissions
	elif fullCommand.size() == 4 && !currentComputer._get_active_user()._eval_perms(fullCommand[3]):
		return "user [color=red]'%s'[/color] does not have write permission to level [color=red]'%s'[/color]!" % [currentComputer._get_active_user()._get_name(), fullCommand[3]]
	elif fullCommand.size() == 5 && !currentComputer._get_active_user()._eval_perms(fullCommand[3]):
		return "user [color=red]'%s'[/color] does not have write permission to level [color=red]'%s'[/color]!" % [currentComputer._get_active_user()._get_name(), fullCommand[3]]
	elif fullCommand.size() == 5 && !currentComputer._get_active_user()._eval_perms(fullCommand[4]):
		return "user [color=red]'%s'[/color] does not have write permission to level [color=red]'%s'[/color]!" % [currentComputer._get_active_user()._get_name(), fullCommand[4]]
		
	currentComputer._add_directory(dirName, dirReadPerms, dirWritePerms, pathString)
	return "Created directory [color=green]'%s'[/color]!" % [pathString + dirName + "/"]


#Removes a 'file' or 'directory' on the current machine
func remove(fullCommand: Array):
	if fullCommand.size() != 2:
		return _error_arg_number(fullCommand.size(), 1, "rm")
	
	var pathString: String = fullCommand[1]
	
	if pathString[0] != "/":
		pathString = currentComputer._get_active_directory()._get_path() + pathString
	if pathString[pathString.length() - 1] != "/":
		pathString += "/"
	
	if pathString == "/":
		return "Cannot delete [color=red]'/'[/color] directory!"
	
	if currentComputer._get_active_directory() == currentComputer._get_root()._find_directory_by_path(currentComputer, _parse_path(pathString), pathString):
		currentComputer._set_active_directory(_parse_path("/"), "/")
	
	var success = currentComputer._remove_directory(_parse_path(pathString), pathString)
	
	if success == 1:
		return "Removed directory [color=green]'%s'[/color]" % pathString
	elif success == 3:
		return "User [color=red]'%s'[/color] does not have permission to remove [color=green]'%s'[/color]" % [currentComputer._get_active_user()._get_name(), fullCommand[1]]
	return "No directory with name [color=red]'%s'[/color] was found!" % fullCommand[1]


#Connects to a 'Computer' with the specified 'id'
func connectComputer(fullCommand: Array):
	if fullCommand.size() != 2:
		return _error_arg_number(fullCommand.size(), 1, "comcon")
	
	#Matches the 'id' to a computer
	var toConnect = networkManager._find_computer_by_ID(int(fullCommand[1]))
	if toConnect == null:
		return "Could not find a computer with ID [color=red]'%s'[/color]" % fullCommand[1]
	if toConnect._get_connected_NetNode() != home._get_connected_NetNode():
		return "Could connect to [color=red]'%s'[/color], computer on NetNode different to [color=cyan]home computer[/color]!" % toConnect._get_ID()
	
	changeComputer(toConnect)
	return "Connected to [color=green]'%s'[/color]" % currentComputer.computerName


#Connects to the 'NetNode' with the specified id
func connectNetNode(fullCommand: Array):
	if fullCommand.size() != 2:
		return _error_arg_number(fullCommand.size(), 1, "nodecon")
	
	
	#Matches the 'id' to a NetNode
	var toConnect = networkManager._find_NetNode_by_ID(int(fullCommand[1]))
	if toConnect == null:
		return "Could not find a NetNode with ID [color=red]'%s'[/color]" % fullCommand[1]
	
	if currentComputer != home:
		currentComputer._connect_NetNode(toConnect)
		changeComputer(home)
		return "Returned to [color=cyan]home computer[/color], cannot connect to a computer on a different NetNode to [color=cyan]home[/color]"
	
	currentComputer._connect_NetNode(toConnect)
	return "Connected to [color=green]'%s'[/color]" % currentComputer._get_connected_NetNode()._get_name()



#Returns all the 'Computers' on the 'Network'
func scan(fullCommand: Array):
	if fullCommand.size() != 1:
		return _error_arg_number(fullCommand.size(), 1, "scan")
	
	#String initialized here for formatting later
	var listString: String
	#Gets the array of 'computers' from the network
	var computers = currentComputer._get_connected_NetNode()._get_computers()
	var netNodes = networkManager._get_netNodes()
	#Index for lists
	var i = 0
	#Formats the 'NetNodes' into an ordered list
	listString += "[color=cyan]NetNodes:[/color]\n"
	for node in netNodes:
		if node == currentComputer._get_connected_NetNode():
			listString += "[color=green]"
		i += 1
		listString += str(i) + ". " + node._get_name() + ": "
		if node == currentComputer._get_connected_NetNode():
			listString += "[/color]"
		listString += str(node._get_ID()) + "\n"
	#Formats the 'computers' into an ordered list
	i = 0
	listString += "\n[color=cyan]Computers:[/color]\n"
	for comp in computers:
		if comp == currentComputer:
			listString += "[color=green]"
		if comp._get_connected_NetNode() == currentComputer._get_connected_NetNode():
			i += 1
			listString += str(i) + ". " + comp._get_name() + ": "
		else:
			pass
		if comp == currentComputer:
			listString += "[/color]"
		if comp._get_connected_NetNode() == currentComputer._get_connected_NetNode():
			listString += str(comp._get_ID()) + "\n"
			
	return listString


#Returns information on the current computer
func info(fullCommand: Array):
	if fullCommand.size() != 1:
		return _error_arg_number(fullCommand.size(), 0, "info")
	
	return "Computer name: [color=green]'%s'[/color] \nComputer ID: [color=green]'%s'[/color] \nNetNode name: [color=green]'%s'[/color] \nNetNode ID: [color=green]'%s'[/color]" % [currentComputer._get_name(), currentComputer._get_ID(), currentComputer._get_connected_NetNode()._get_name(), currentComputer._get_connected_NetNode()._get_ID()]
#End of command functions


func _update_caret():
	caret.text = currentComputer._get_active_user()._get_name() + "@" + currentComputer._get_name() + ":" + currentComputer._get_active_directory()._get_path() + ">"


#Changes 'currentComputer' to the new 'Computer' object
func changeComputer(newComputer: Computer):
	currentComputer = newComputer


#Splits up a path for finding a 'Directory'
func _parse_path(pathToParse: String) -> Array:
	var pathParsed: Array
	if pathToParse[0] != "/":
		pathToParse = currentComputer._get_active_directory()._get_path() + pathToParse
	
	print(pathToParse)
	
	pathParsed.append("/")
	
	#Splits the string of arguments at each comma and appends the returned array to 'commandParsed'
	pathParsed.append_array(pathToParse.split("/", false))
	#Loops through 'commandParsed' and removes spaces
	for i in range(pathParsed.size()):
		pathParsed[i] = pathParsed[i]
	return pathParsed


#Splits up 'commandToParse' into a usable Array
func _parse_command_args(commandToParse: Array) -> Array:
	var commandParsed = commandToParse
	
	#Splits the string of arguments at each comma and appends the returned array to 'commandParsed'
	commandParsed.append_array(commandParsed[1].split(",", false))
	#Removes the string of arguments that was used in the previous line
	commandParsed.remove_at(1)
	#Removes the ')' from the final element in the array
	commandParsed[commandParsed.size() - 1] = commandParsed[commandParsed.size() - 1].trim_suffix(")")
	#Loops through 'commandParsed' and removes spaces
	for i in range(commandParsed.size()):
		commandParsed[i] = commandParsed[i].strip_edges()
	
	return commandParsed


#Template for error message when to many arguments are used
func _error_arg_number(commandSize: int, requiredArgs: int, commandName: String, optionalArgs: int = 0):
	#Changes output if there are 'optional arguments' present
	if optionalArgs == 0:
		return "command [color=green]'%s'[/color] requires [color=green]'%s'[/color] arguements, you passed [color=red]'%s'[/color] arguments!" % [commandName, str(requiredArgs), str(commandSize - 1)]
	return "command [color=green]'%s'[/color] requires [color=green]'%s'[/color] arguements and has [color=green]'%s'[/color] optional arguments, you passed [color=red]'%s'[/color] arguments!" % [commandName, str(requiredArgs), str(optionalArgs) ,str(commandSize - 1)]
