extends VBoxContainer


func set_text(input: String, response: String, computer: Computer):
	$InputHistory.text = computer._get_active_user()._get_name() + "@" + computer._get_name() + ":" + computer._get_active_directory()._get_path() + "> " + input
	$Response.text = response
