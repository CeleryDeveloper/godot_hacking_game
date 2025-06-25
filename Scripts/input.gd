extends LineEdit


#Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grab_focus()
	set_keep_editing_on_text_submit(true)


#Clears "input" when a value is submitted
func _on_text_submitted(_new_text: String) -> void:
	clear()
