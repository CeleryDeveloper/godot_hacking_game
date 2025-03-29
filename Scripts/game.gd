extends Control

const ResponseNoHistory = preload("res://Scenes/responseNoHistory.tscn")
const Response = preload("res://Scenes/response.tscn")

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


func _process(_delta: float) -> void:
	#Updates the caret symbol before the input to display user info, not the cursor
	commandProcessor._update_caret()
	
	if commandProcessor._is_crashed() != null && !lost:
		var crashMessage = ResponseNoHistory.instantiate()
		#If currentComputer has crashed and it's not the home computer show error then return to home
		if commandProcessor.currentComputer != commandProcessor.home:
			crashMessage.text = commandProcessor._is_crashed()
			_add_response(crashMessage)
			commandProcessor.changeComputer(commandProcessor.home)
		#If currentComputer has crashed and is home end game
		else:
			crashMessage.text = commandProcessor._is_crashed()
			_add_response(crashMessage)
			lost = true
	
	#Updates history values when arrow keys are pressed
	if Input.is_action_just_pressed("NavigateHistoryUP"):
		_navigate_history(1)
	if Input.is_action_just_pressed("NavigateHistoryDOWN"):
		_navigate_history(-1)


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
	var output = commandProcessor._process_command(new_text)
	#Sets text in response node based on the commandProcessor
	response.set_text(new_text, output, commandProcessor.currentComputer)
	historyPos = -1
	_add_response(response)


#Adds Response node to terminal
func _add_response(response: Control):
	terminalHistory.add_child(response)
	_clean_history()
	

#Clears "terminalHistory" when the number of responses is greater than "maxHistory"
func _clean_history():
	if terminalHistory.get_child_count() > maxHistory:
		var rowsToForget = terminalHistory.get_child_count() - maxHistory
		for i in range(rowsToForget):
			terminalHistory.get_child(i).queue_free()
