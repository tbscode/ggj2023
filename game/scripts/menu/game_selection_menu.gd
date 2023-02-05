extends Control

var session_id = ""
var username = ""

func _ready():
	get_node("/root/root/music").play()

func _on_join_game_button_pressed():
	var save_file = File.new()
	var file_exists = save_file.file_exists("user://user.save")

	if false:
		# We always make a new account for now
		save_file.open("user://user.save", File.READ)
		var file_text = ""
		while not save_file.eof_reached():
			file_text += save_file.get_line()

		print("TEXT", file_text)

		var json = JSON.parse(file_text)
		if json.error == OK:
			Global.username = json.result["username"]
			Global.key = json.result["key"]
			$user_auth.login_user(Global.username + ":" + Global.key)
			return
		else:
			print("Error parsing json")
		
		save_file.close()
	
	$user_auth.login_user()

func _on_play_online_pressed():
	_on_join_game_button_pressed()

func login_completed(username, session_id, key, map):
	print(username)
	Global.single_player_map = map
	$name_label.text = username
	Global.session_id = session_id
	Global.username = username
	Global.key = key
	self.session_id = session_id
	self.username = username

func _on_connect_websocket_pressed():
	print("Tying to connect to websocket")
	$socket_manager.connect_to_socket(self.session_id)



func _on_test_message_button_pressed():
	$socket_manager.send_message({"data" : "Hello World"})



func _on_credits_button_pressed():
	get_tree().change_scene("res://scenes/credits.tscn")
	pass # Replace with function body.
