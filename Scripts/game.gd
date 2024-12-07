extends Control

const ResponseNoHistory = preload("res://Scenes/responseNoHistory.tscn")
const Response = preload("res://Scenes/response.tscn")

var maxScrollLength = 0
var historyPos: int = -1

@export var maxHistory: int = 30

@onready var commandProcessor = $CommandProcessor
@onready var terminalHistory = $Terminal/MarginContainer/Rows/Stdout/ScrollContainer/TerminalHistory
@onready var scroll = $Terminal/MarginContainer/Rows/Stdout/ScrollContainer
@onready var scrollBar = scroll.get_v_scroll_bar()
@onready var networkManager = $NetworkManager
@onready var input: LineEdit = $Terminal/MarginContainer/Rows/InputArea/HBoxContainer/Input


func _ready() -> void:
	scrollBar.changed.connect(_handle_scrollbar_change)
	maxScrollLength = scrollBar.max_value
	var startingMessage = ResponseNoHistory.instantiate()
	startingMessage.text = "Welcome to the network, type [color=green]'help'[/color] and press [color=green]'enter'[/color] to see available commands!"
	_add_response(startingMessage)
	commandProcessor._initialize(networkManager.get_child(0))


func _process(delta: float) -> void:
	commandProcessor._update_caret()
	if Input.is_action_just_pressed("NavigateHistoryUP"):
		_navigate_history(1)
	if Input.is_action_just_pressed("NavigateHistoryDOWN"):
		_navigate_history(-1)


func _navigate_history(value: int):
	historyPos += value
	var history = commandProcessor.commandHistory
	if historyPos < -1:
		historyPos = -1
	if historyPos > history.size() - 1:
		historyPos = history.size() - 1
	if historyPos != -1:
		input.text = history[historyPos]
		input.caret_column = input.text.length()
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
	if new_text.is_empty():
		return
		
	var response = Response.instantiate()
	var output = commandProcessor._process_command(new_text)
	response.set_text(new_text, output, commandProcessor.currentComputer)
	historyPos = -1
	_add_response(response)


func _add_response(response: Control):
	terminalHistory.add_child(response)
	_clean_history()
	

#Clears "terminalHistory" when the number of responses is greater than "maxHistory"
func _clean_history():
	if terminalHistory.get_child_count() > maxHistory:
		var rowsToForget = terminalHistory.get_child_count() - maxHistory
		for i in range(rowsToForget):
			terminalHistory.get_child(i).queue_free()
