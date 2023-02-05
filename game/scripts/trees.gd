extends Node2D

var current_level_red = 0
var current_level_blue = 0

func grow_level(team):

	var current_level = 0
	if team == "red":
		current_level = current_level_red
		current_level_red += 1
	elif team == "blue":
		current_level = current_level_blue
		current_level_blue += 1

	if current_level != 0 and current_level < 5:
		get_node("/root/root/trees/tree_" + str(team) + "_level" + str(current_level)).hide()
	if current_level < 5:
		get_node("/root/root/trees/tree_" + str(team) + "_level" + str(current_level + 1)).show()
