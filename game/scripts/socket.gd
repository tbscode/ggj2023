extends Node

#const BACKEND_URL = "http://localhost:8000"
const BACKEND_URL = "https://t1m.me"
const SOCKET_URL = "wss://t1m.me/ws/game/"
#const SOCKET_URL = "ws://localhost:8000/ws/game/"

var _client = WebSocketClient.new()
var my_group = ""

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
	get_node("/root/root/console").text += data
	data = JSON.parse(data).result
	if data['event'] == 'connected':
		# Now we can start playing
		self.my_group = data['group']
		print("CONNECTED TO SERVER", "Got group", self.my_group)

func _process(delta):
	_client.poll()

func send_message(data):
	var user_dict = {"type" : "simple", "username" : get_node("/root/root").username, "recipients" : "all", "group" : self.my_group}
	user_dict.merge(data)
	var text_data = JSON.print(user_dict).to_utf8()
	_client.get_peer(1).put_packet(text_data)
