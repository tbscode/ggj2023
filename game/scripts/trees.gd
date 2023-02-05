extends Node2D

var current_level = 0

func grow_level(team):

	get_node("/root/root/trees/tree_" + str(team) + "_level" + str(current_level)).hide()
	current_level += 1
	get_node("/root/root/trees/tree_" + str(team) + "_level" + str(current_level)).show()
