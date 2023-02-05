extends Node

const BACKEND_URL = Global.BACKEND_URL
const SOCKET_URL = Global.WEBSOCKET_URL
#const BACKEND_URL = "http://localhost:8000"
#const SOCKET_URL = "ws://localhost:8000/ws/game/"

var console_path = "/root/root/console"
var _client = WebSocketClient.new()
var my_group = ""
var my_team = ""
var my_spawn = ""

func init(console_path):
	self.console_path = console_path
	self._client = WebSocketClient.new()

func _ready():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")

func connect_to_socket(session_id):
	print("ATTEMPTING CONNECT", session_id)
	# TODO use secure websocket in production
	var headers = PoolStringArray() # Need this for user authentication
	headers.append("Cookie: sessionid=" + session_id + ";")
	print("DOCK", SOCKET_URL)
	var err = _client.connect_to_url(SOCKET_URL, [], false, headers)
	if err != OK:
		print("Unable to connect")
		set_process(false)

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	_client.get_peer(1).put_packet("Test packet".to_utf8())

func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	var data = _client.get_peer(1).get_packet().get_string_from_utf8()
	print("Got data from server: ", data)
	get_node(console_path).text += data
	data = JSON.parse(data).result
	if data['event'] == 'connected':
		# Now we can start playing
		self.my_group = data['group']
		self.my_team = data['team']
		Global.player_team = data['team']
		self.my_spawn = data['spawn']

		print("SPAWN", self.my_spawn)

		get_node("/root/root/players/player1").init_player(Vector2(self.my_spawn[0], self.my_spawn[1]))
		get_node("/root/root/game_ui/team_label").text = "Team: " + self.my_team
		get_node("/root/root/players/player1").populate_map(data['map'])
		print("CONNECTED TO SERVER", "Got group", self.my_group)
	elif data['event'] == 'game_start':
		get_node(console_path).text += "\nGOT GAME START!\n"
		get_node("/root/root").game_started = true
		get_node("/root/root/pre_game_screen").hide()
	elif data['event'] == 'other_player_spawn_root':
		if data['username'] == Global.username:
			print("Received self broadcast")
			return
		#print("SPAWNING OTHER PLAYER ROOT", data)
		get_node("/root/root/players/player1").spawn_other_player_root(
			Vector2(data['position'][0], data['position'][1]),
			Vector2(data['scale'][0], data['scale'][1]),
			data['rotation']
		)

	elif data['event'] == 'xp_collected':
		var xp = data['xp']
		var team = data['team']

		if team == "red":
			get_node("/root/root").red_team_xp += xp
			get_node("/root/root").change_left_progress_relative()
		elif team == "blue":
			get_node("/root/root").blue_team_xp += xp
			get_node("/root/root").change_right_progress_relative()
	elif data['event'] == "team_won":
		if data["team"] == Global.player_team:
			# Then the player has WON
			print("YOU WON")
			pass
		else:
			# Then the player has LOST
			print("YOU LOST")
			pass
			

func _process(delta):
	_client.poll()

func send_message(data):
	var user_dict = {"type" : "simple", "username" : Global.username, "recipients" : "all", "group" : self.my_group}
	user_dict.merge(data)
	var text_data = JSON.print(user_dict).to_utf8()
	_client.get_peer(1).put_packet(text_data)
