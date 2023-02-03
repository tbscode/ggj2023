extends Node

const BACKEND_URL = "http://localhost:8000"
const GUEST_LOGIN_URL = BACKEND_URL + "/guest_login"
const USER_LOGIN_URL = BACKEND_URL + "/user_login"

func request_login(username, password):
	var request = HTTPRequest.new()
	var body = to_json({"username": username, "password" : password})

	request.connect("request_completed", self, "_on_login_request_completed")
	var error = request.request(BACKEND_URL, [], true, HTTPClient.METHOD_POST, body)

	if error != OK:
		print("ERROR cant login")

func request_guest_login():
	pass


func _on_login_request_completed(request_id, result, headers, body):
	if result == 200:
		var response = parse_json(body.get_string_from_utf8())
		print("GOT")
		print(response)
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

func _ready():
	pass # Replace with function body.
