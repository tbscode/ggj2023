extends Control


var room_name = ""

func _ready():
	pass

func _on_room_name_input_text_changed(new_text):
	print("room name changed to: " + new_text)


func _on_join_game_button_pressed():
	print("TRIGGER BUTTOn")
	$user_auth.login_user()

func login_completed(username):
	print(username)
	$name_label.text = username
	pass
