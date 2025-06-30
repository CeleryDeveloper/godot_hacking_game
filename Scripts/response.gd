extends VBoxContainer


func set_text(input: String, response: String, computer: Computer):
	$InputHistory.text = computer.get_active_user().get_user_name() + "@" + computer.get_com_name() + ":" + computer.get_active_directory().get_directory_path() + "> " + input
	$Response.text = response
