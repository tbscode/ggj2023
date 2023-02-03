extends Control


var room_name = ""

func _ready():
	pass

func _on_room_name_input_text_changed(new_text):
	print("room name changed to: " + new_text)
