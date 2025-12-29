extends Control
class_name Game

const ResponseNoHistory = preload("res://Scenes/responseNoHistory.tscn")
const Response = preload("res://Scenes/response.tscn")
const RhythmScene = preload("res://Scenes/rhythm.tscn")
const notificationScene = preload("res://Scenes/notification.tscn")

var maxScrollLength = 0
var historyPos: int = -1
var lost: bool = false

#Dosn't apply to _navigate_history, only Response nodes
@export var maxHistory: int = 30

@onready var commandProcessor:CommandProcessor = $CommandProcessor
@onready var terminalHistory = $Terminal/MarginContainer/Rows/Stdout/ScrollContainer/TerminalHistory
@onready var scroll = $Terminal/MarginContainer/Rows/Stdout/ScrollContainer
@onready var scrollBar = scroll.get_v_scroll_bar()
@onready var networkManager = $NetworkManager
@onready var input: LineEdit = $Terminal/MarginContainer/Rows/InputArea/HBoxContainer/Input
@onready var player: Player = $Player


func _ready() -> void:
	#Connects changed signal on scrollBar to handler function
	#Changed triggers if scrollBar's max_value changes e.g. when Response node is added
	scrollBar.changed.connect(_handle_scrollbar_change)
	maxScrollLength = scrollBar.max_value
	#Adds starting message
	var startingMessage = ResponseNoHistory.instantiate()
	startingMessage.text = "Welcome to the network, type [color=green]'help'[/color] and press [color=green]'enter'[/color] to see available commands!"
	_add_response(startingMessage)
	#Initializes the commandProcessor with the home computer
	commandProcessor._initialize(networkManager.get_child(0))
	print(get_children())


func _process(_delta: float) -> void:
	#Updates the caret symbol before the input to display user info, not the cursor
	commandProcessor.update_caret()
	
	if commandProcessor.is_crashed() != null && !lost:
		var crashMessage = ResponseNoHistory.instantiate()
		#If currentComputer has crashed and it's not the home computer show error then return to home
		if commandProcessor.currentComputer != commandProcessor.home:
			crashMessage.text = commandProcessor.is_crashed()
			_add_response(crashMessage)
			commandProcessor.changeComputer(commandProcessor.home)
		#If currentComputer has crashed and is home end game
		else:
			crashMessage.text = commandProcessor.is_crashed()
			_add_response(crashMessage)
			lost = true
	
	#Updates history values when arrow keys are pressed
	if Input.is_action_just_pressed("NavigateHistoryUP"):
		_navigate_history(1)
	if Input.is_action_just_pressed("NavigateHistoryDOWN"):
		_navigate_history(-1)


#Runs when player passes out
func _player_passout():
	var passoutMessage = ResponseNoHistory.instantiate()
	if commandProcessor.currentComputer == commandProcessor.home:
		passoutMessage.text = "You have [color=red]passed out[/color]! You will sleep for [color=red]eight hours[/color]."
		_add_response(passoutMessage)
	else:
		#returns player to home
		passoutMessage.text = "You have [color=red]passed out[/color]! You will sleep for [color=red]eight hours[/color] and be returned to [color=green]home[/color]."
		_add_response(passoutMessage)
		commandProcessor.changeComputer(commandProcessor.home)


#Charges player rent
func _charge_rent():
	var rentMessage = ResponseNoHistory.instantiate()
	
	#Subtracts rent from player's balance
	player.cash_transaction(-player.get_rent_cost())
	
	if player.get_cash_balance() < 0:
		#Makes player lose if they can't pay rent
		lost = true
		rentMessage.text = "You have [color=red]failed[/color] to pay rent and have been [color=red]evicted[/color]!"
		_add_response(rentMessage)
	else:
		rentMessage.text = "You have [color=green]successfully[/color] payed rent and have been charged [color=red]'$%.2f'[/color]!" % player.get_rent_cost()
		_add_response(rentMessage)


#Loads the rhythm game
func load_rhythm_scene(userToDecrypt: User):
	var newScene: RhythmManager = RhythmScene.instantiate()
	newScene.set_user(userToDecrypt)
	newScene.set_password(userToDecrypt.get_password())
	newScene.set_game_manager(self)
	
	#Disables all children of 'game' so they don't cause issues during the mini game
	for child in get_children():
		child.PROCESS_MODE_DISABLED
	
	#Makes it so player can't type in the input while playing 'rhythm'
	input.release_focus()
	add_child(newScene)


#Deloads the rhythm game
func deload_rhythm_scene(rhythm: RhythmManager, winState: bool, user: User):
	var decryptMessage = ResponseNoHistory.instantiate()
	
	#Re-enables all children of 'game'
	for child in get_children():
		child.PROCESS_MODE_INHERIT
	
	#Win/fail message
	if winState == true:
		decryptMessage.text = "[color=green]Successfully[/color] decrypted password! \n[color=green]Password: %s[/color]" % rhythm.get_password()
		#Sets the user's password that is being decrypted to revealed 
		#so it can be seen in the 'lu' command
		user.set_pass_revealed(true)
	else:
		decryptMessage.text = "[color=red]Failed[/color] to decrypt password!"
	_add_response(decryptMessage)
	
	#Makes player be able to type in input after rhythm is over
	input.grab_focus()
	
	rhythm.queue_free()


#Navigates the history of inputs using arrow keys
func _navigate_history(value: int):
	historyPos += value
	var history = commandProcessor.commandHistory
	
	#Clamps historyPos above -2
	if historyPos < -1:
		historyPos = -1
	
	#Clamps historyPos within the history Array
	if historyPos > history.size() - 1:
		historyPos = history.size() - 1
	
	#Sets the input to the String at the position in history
	if historyPos != -1:
		input.text = history[historyPos]
		#Moves the caret to the end of the line
		input.caret_column = input.text.length()
	#If the history pos is equal to -1 the input is whatever the user types 
	else:
		input.text = ""
		input.caret_column = input.text.length()


#Scrolls to the most recent response whenever a command is submitted
func _handle_scrollbar_change():
	if maxScrollLength != scrollBar.max_value:	
		maxScrollLength = scrollBar.max_value
		scroll.scroll_vertical = scrollBar.max_value


#Triggers whenever the player submits a value from "input"
func _on_input_text_submitted(new_text: String) -> void:
	#Exits function if input is empty
	if new_text.is_empty():
		return
		
	var response = Response.instantiate()
	var output = commandProcessor.process_command(new_text)
	#Sets text in response node based on the commandProcessor
	response.set_text(new_text, output, commandProcessor.currentComputer)
	historyPos = -1
	_add_response(response)


#Adds Response node to terminal
func _add_response(response: Control):
	terminalHistory.add_child(response)
	_clean_history()


#Creates a notification and begins its animation
func create_notification(header: String, content: String):
	var newNotification: Notification = notificationScene.instantiate()
	
	newNotification.set_header_text("header")
	newNotification.set_content_text("content")
	
	add_child(newNotification)


#Clears "terminalHistory" when the number of responses is greater than "maxHistory"
func _clean_history():
	if terminalHistory.get_child_count() > maxHistory:
		var rowsToForget = terminalHistory.get_child_count() - maxHistory
		for i in range(rowsToForget):
			terminalHistory.get_child(i).queue_free()
