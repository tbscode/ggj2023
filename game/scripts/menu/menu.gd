extends Control

var session_id = ""
var username = ""

func _ready():
	pass

func _on_join_game_button_pressed():
	$user_auth.login_user()

func login_completed(username, session_id):
	print(username)
	$name_label.text = username
	self.session_id = session_id
	self.username = username


func _on_connect_websocket_pressed():
	print("Tying to connect to websocket")
	$socket_manager.connect_to_socket()
