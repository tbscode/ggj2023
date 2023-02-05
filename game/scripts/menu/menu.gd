extends Node2D

const FULL_XBAR_WIDTH = 1450.0

var session_id = ""
var username = ""

var game_started = false

var MAXIMUM_XP = 30000.0

var red_team_xp = 0.0
var blue_team_xp = 0.0


func _ready():
	get_node("/root/root/audios/music").play()
	if not Global.playing_online:
		# generate a offline map
		# TODO select a random spawn
		get_node("/root/root/pre_game_screen").hide()
		get_node("/root/root/players/player1").init_player(Vector2(0.0, 0.0))
		game_started = true
	change_left_progress(0.0)
	change_right_progress(0.0)

func _on_back_button_pressed():
	if get_node("/root/root/session_controller").connected:
		get_node("/root/root/session_controller")._client.disconnect_from_host()

	print("SWITCHING DA SCENE")

	get_tree().change_scene("res://scenes/ui.tscn")
	


func _on_join_lobby_pressed():
	print("User trying to join lobby")
	get_node("/root/root/session_controller").console_path = "/root/root/pre_game_screen/terminal"
	get_node("/root/root/session_controller").connect_to_socket(Global.session_id)


func maybe_update_tree_level(team):
	# There are levels from 0 to 5 so we have 0.2 increments
	print("ATTEMPTING TREE UPDATE")
	if team == "red":
		var xp_ration = red_team_xp / MAXIMUM_XP
		print("XP RATION ", xp_ration, "CURRENT LEVEL", get_node("/root/root/trees").current_level_red)
		var compare = (get_node("/root/root/trees").current_level_red + 1) * 0.1
		print("COMP", compare)
		if compare < xp_ration:
			get_node("/root/root/trees").grow_level("red")
	else:
		var xp_ration = blue_team_xp / MAXIMUM_XP
		print("XP RATION ", xp_ration, "CURRENT LEVEL", get_node("/root/root/trees").current_level_blue)
		var compare = (get_node("/root/root/trees").current_level_blue + 1) * 0.1
		print("COMP", compare)
		if compare < xp_ration:
			get_node("/root/root/trees").grow_level("blue")

func _on_join_game_button_pressed():
	$user_auth.login_user()

func change_left_progress_relative():
	var ratio = red_team_xp / MAXIMUM_XP
	print("RATIONS", ratio)
	change_left_progress(ratio)

func change_right_progress_relative():
	var ratio = blue_team_xp / MAXIMUM_XP
	print("RATIONS", ratio)
	change_right_progress(ratio)

func change_left_progress(progress):
	get_node("/root/root/game_ui/xp_bar_red_full").region_rect.size.x = FULL_XBAR_WIDTH * progress

func change_right_progress(progress):
	print("In progress", progress)
	progress = 1.0 - progress
	print("INITAL VALS", get_node("/root/root/game_ui/xp_bar_blue_full").region_rect.size.x, get_node("/root/root/game_ui/xp_bar_blue_full").offset.x)
	get_node("/root/root/game_ui/xp_bar_blue_full").region_rect.size.x = 1450.0
	get_node("/root/root/game_ui/xp_bar_blue_full").offset.x = -1450.0
	get_node("/root/root/game_ui/xp_bar_blue_full").region_rect.size.x -= FULL_XBAR_WIDTH * progress
	get_node("/root/root/game_ui/xp_bar_blue_full").offset.x += FULL_XBAR_WIDTH * progress
	print("Cahnged bar progress", progress)

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


func _on_join_lobby_button_pressed():
	get_node("/root/root/pre_game_screen/player_indicator").show()
	get_node("/root/root/pre_game_screen/animation").play("move_rootle")

	get_node("/root/root/session_controller").console_path = "/root/root/pre_game_screen/terminal"
	get_node("/root/root/session_controller").connect_to_socket(Global.session_id)


func _on_after_game_play_pressed():
	print("PLAY AGAIN PRESSED")

	if get_node("/root/root/session_controller").connected:
		get_node("/root/root/session_controller")._client.disconnect_from_host()	

	get_tree().change_scene("res://scenes/game.tscn")


func _on_after_game_back_pressed():
	if get_node("/root/root/session_controller").connected:
		get_node("/root/root/session_controller")._client.disconnect_from_host()	

	get_tree().change_scene("res://scenes/ui.tscn")
