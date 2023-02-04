extends Node

# For upsteam
const IS_PROD = true
const BACKEND_URL = "https://t1m.me" if IS_PROD else "http://localhost:8000"
const WEBSOCKET_PROTOCOL = "wss://"  if IS_PROD else "ws://"
const WEBSOCKET_URL = WEBSOCKET_PROTOCOL + "t1m.me/ws/game/" if IS_PROD else WEBSOCKET_PROTOCOL + "localhost:8000/ws/game/"

var key = ""
var session_id = ""
var username = ""

var playing_online = true