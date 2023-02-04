extends Node2D

var session_id = ""
var username = ""

var game_started = false

func _ready():
	pass

func _on_join_lobby_pressed():
	print("User trying to join lobby")
	get_node("/root/root/session_controller").console_path = "/root/root/pre_game_screen/terminal"
	get_node("/root/root/session_controller").connect_to_socket(Global.session_id)

func _on_join_game_button_pressed():
	$user_auth.login_user()

func login_completed(username, session_id, key):
	print(username)
	$name_label.text = username
	Global.session_id = session_id
	Global.username = username
	Global.key = ""
	self.session_id = session_id
	self.username = username

	var safe_user = File.new()
	safe_user.open("user://user.save", File.WRITE)
	safe_user.store_line(JSON.print({
		"username": username,
		"session" : session_id,
		"key" : key
	}))
	safe_user.close()


func _on_connect_websocket_pressed():
	print("Tying to connect to websocket")
	$socket_manager.connect_to_socket(self.session_id)



func _on_test_message_button_pressed():
	$socket_manager.send_message({"data" : "Hello World"})
