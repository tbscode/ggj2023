extends Node2D

var session_id = ""
var username = ""

func _ready():
	pass

func _on_join_game_button_pressed():
	$user_auth.login_user()

func login_completed(username, session_id):
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
		"username": response['username'],
		"session" : session_id,
		"key" : response['key']
	}))
	safe_user.close()


func _on_connect_websocket_pressed():
	print("Tying to connect to websocket")
	$socket_manager.connect_to_socket(self.session_id)



func _on_test_message_button_pressed():
	$socket_manager.send_message({"data" : "Hello World"})
