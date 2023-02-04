extends Node

#const BACKEND_URL = "http://localhost:8000"
#const BACKEND_URL = "http://localhost:8000"
const BACKEND_URL = "https://t1m.me"
const GUEST_LOGIN_URL = BACKEND_URL + "/api/guest_login/"
const USER_LOGIN_URL = BACKEND_URL + "/api/user_login/"

func request_login(username, password):
	var request = HTTPRequest.new()
	add_child(request)
	var body = to_json({"username": username, "password" : password})

	request.connect("request_completed", self, "_on_login_request_completed")
	var error = request.request(USER_LOGIN_URL, [], true, HTTPClient.METHOD_POST, body)

	if error != OK:
		get_node("/root/root/console").text += "ERROR cant login \n"
		print("ERROR cant login")

func request_guest_login():
	var request = HTTPRequest.new()
	add_child(request)
	var body = to_json({})

	request.connect("request_completed", self, "_on_guest_login_request_completed")
	var error = request.request(GUEST_LOGIN_URL)

	if error != OK:
		get_node("/root/root/console").text += "ERROR guest login failed \n"

func _on_guest_login_request_completed(request_id, result, headers, body):
	if result == 200:
		var response = parse_json(body.get_string_from_utf8())

		# We need to extract the session token so we can stay logged in!
		var header_str = str(headers)
		print("HEAD", header_str)
		var id_start = str(headers).find("sessionid=")
		header_str = header_str.substr(id_start + len("sessionid="))
		var session_id = header_str.split(";")[0]

		get_node("/root/root").login_completed(response['username'], session_id, response['key'])
	else:
		# TODO: handle the error
		print("ERROR cant login")

func _on_login_request_completed(request_id, result, headers, body):
	if result == 200:
		var response = parse_json(body.get_string_from_utf8())

		# We need to extract the session token so we can stay logged in!
		var header_str = str(headers)
		print("HEAD", header_str)
		var id_start = str(headers).find("sessionid=")
		header_str = header_str.substr(id_start + len("sessionid="))
		var session_id = header_str.split(";")[0]

		get_node("/root/root").login_completed(response['username'], session_id, response['key'])
		return response
	else:
		# TODO: handle the error
		print("ERROR cant login")

func login_user(login_data=""):
	if login_data == "":
		# then we will create a guest user for the login
		request_guest_login()
	elif ":" in login_data:
		var user_and_pass = login_data.split(":")
		request_login(user_and_pass[0], user_and_pass[1])
	else:
		# TODO display this error to the user
		print("ERROR cant login")
		return false

func _ready():
	pass # Replace with function body.
