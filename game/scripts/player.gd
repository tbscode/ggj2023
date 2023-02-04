extends Node2D

var IS_ONLINE = Global.playing_online

const FULL_XBAR_WIDTH = 1450.0

const MIN_ANGLE_THRESHOLD = deg2rad(10.0)
const ANGLE_CHANGE_VELOCITY = deg2rad(10.0) * 600.0
const GROW_SPEED = 80.0
const MAXIMUM_ROOT_ELEMENT_LENGTH = 24.0
const MIN_ROOT_ELEMENT_SPAWN_DIST = 100.0
var cur_maximum_root_element_length = MAXIMUM_ROOT_ELEMENT_LENGTH
const ROOT_SHRINK_SPEED = 0.04
const MINIMUM_ROOT_SCALE = 0.4

const XP_DRAIN_SPEED = 2.0

# A player is a 'root'
# The root always grows downwards
# we store the angle of the clockwise rotation between the horizontal as direction
var angle = deg2rad(90.0) # You start facing steight down
var path_lengh_since_root_element = 0.0
var root_element_positions = []
var root_parts = [] # this should hold a list of nodes ( which are all root parts )

var root_path_element_positions = []
var root_path_element_nodes = []

# TODO minimum wulzt size

func _ready():
	pass
	#init_player()

func init_player(spawn):
	$end_of_root.position = spawn
	root_element_positions.append(spawn)
	spawn_root_path_element()

func _process(delta):
	if get_node("/root/root").game_started:
		move_direction(delta)
		process_direction_input(delta)
		scale_root(delta)

func process_direction_input(delta):
	if Input.is_action_pressed("ui_left"):
		# rotate left = increase angle
		#if angle < deg2rad(180.0) - MIN_ANGLE_THRESHOLD:
		angle += deg2rad(ANGLE_CHANGE_VELOCITY) * delta
	elif Input.is_action_pressed("ui_right"):
		#if angle > MIN_ANGLE_THRESHOLD:
		angle -= deg2rad(ANGLE_CHANGE_VELOCITY) * delta
	get_node("/root/root/game_ui/root_direction_display").rotation = angle - deg2rad(90.0)

func scale_root(delta):
	$end_of_root.scale.x -= ROOT_SHRINK_SPEED * delta
	$end_of_root.scale.y -= ROOT_SHRINK_SPEED * delta

	if $end_of_root.scale.x < MINIMUM_ROOT_SCALE:
		relocate_current_root()

func relocate_current_root():
	# We pick a random possible root part
	var selection = randi() % root_path_element_nodes.size()
	var elem = root_path_element_nodes[selection]

	$end_of_root.position.x = elem.position.x
	$end_of_root.position.y = elem.position.y

	$end_of_root.scale.x = elem.scale.x
	$end_of_root.scale.y = elem.scale.y

	angle = deg2rad(90.0)

func move_direction(delta):
	# Check the current angle, calculate the position to move to
	var heading = Vector2(cos(angle), sin(angle)) * GROW_SPEED * delta
	#$end_of_root.position.x += heading.x
	#$end_of_root.position.y += heading.y
	var collide = $end_of_root.move_and_collide(heading)
	if collide != null:
		# print("TOTOATALL COLLLDERAL", collide, collide.collider.name)
		# print("JOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOooooo", collide.collider.get_path())

		var path = str(collide.collider.get_path())

		if (not "water" in path) and (not "groth" in path):
			var owner = collide.collider.get_parent()
			owner.queue_free()
			relocate_current_root()
		else:
			if "water" in path:
				if not get_node("/root/root/audios/collect_water").playing:
					get_node("/root/root/audios/collect_water").play()
			elif "groth" in path:
				if not get_node("/root/root/audios/grow_sound").playing:
					get_node("/root/root/audios/grow_sound").play()
				var owner = collide.collider.get_parent()
				self.scale.x *= owner.groth_multiplier
				self.scale.y *= owner.groth_multiplier
				owner.queue_free()

	path_lengh_since_root_element += heading.length()

	var dist = root_element_positions[-1].distance_to($end_of_root.position)
	#print("DIST", dist)
	if dist >= cur_maximum_root_element_length:
		# now we sould place a new root texture!
		append_root()

	if path_lengh_since_root_element >= MIN_ROOT_ELEMENT_SPAWN_DIST:
		path_lengh_since_root_element = 0.0
		spawn_root_path_element()

func spawn_root_path_element():
	var node = get_node("/root/root/resources/root_element").duplicate()
	add_child(node)
	node.position.x = $end_of_root.position.x
	node.position.y = $end_of_root.position.y
	node.scale.x = $end_of_root.scale.x
	node.scale.y = $end_of_root.scale.y
	own(node, self)

	root_path_element_positions.append($end_of_root.position)
	root_path_element_nodes.append(node)

func append_root():
	# TODO in the furture this would also place the root texture along the way
	var vec_dir = -root_element_positions[-1] + $end_of_root.position
	var rot_dir = atan2(vec_dir.y, vec_dir.x) - deg2rad(90.0)
	var node = get_node("/root/root/resources/root_branch").duplicate()

	add_child(node)
	root_element_positions.append($end_of_root.position)
	node.position.x = $end_of_root.position.x
	node.position.y = $end_of_root.position.y
	node.scale.x = $end_of_root.scale.x
	node.scale.y = $end_of_root.scale.y
	node.rotation = rot_dir

	cur_maximum_root_element_length = $end_of_root.scale.y * MAXIMUM_ROOT_ELEMENT_LENGTH

	get_node("/root/root/audios/grow_root").play()

	own(node, self)
	root_parts.append(node)

	if IS_ONLINE:
		get_node("/root/root/session_controller").send_message({
			"event" : "other_player_spawn_root",
			"position": [$end_of_root.position.x, $end_of_root.position.y],
			"scale": [$end_of_root.scale.x, $end_of_root.scale.y],
			"rotation": rot_dir
		})

	#print("INSTANCE", node);

func spawn_other_player_root(position, scale, rotation):
	var node = get_node("/root/root/resources/root_branch_collide").duplicate()

	var container = get_node("/root/root/players/others")

	container.add_child(node)
	node.rect_position.x = position[0]
	node.rect_position.y = position[1]
	node.rect_scale.x = scale[0]
	node.rect_scale.y = scale[1]
	node.rect_rotation = rotation

	own(node, container)

func populate_map(map):
	print("PUPULATING", map)
	for item in map:	
		# print("TIEM", item)
		# print("ADDMING", item)
		if item['type'] == "water":
			var node = get_node("/root/root/resources/water").duplicate()
			var container = get_node("/root/root/items")

			container.add_child(node)
			node.position.x = item['position'][0]
			node.position.y = item['position'][1]
			node.xp = item['xp']
			node.INITAL_XP = item['xp']

			own(node, container)
		elif item['type'] == "growth":
			var node = get_node("/root/root/resources/groth").duplicate()
			var container = get_node("/root/root/items")

			container.add_child(node)
			node.position.x = item['position'][0]
			node.position.y = item['position'][1]

			node.groth_multiplier = item['grow']

			own(node, container)
		elif item['type'] == 'stone':
			var node = get_node("/root/root/resources/stone1").duplicate()
			var container = get_node("/root/root/items")

			container.add_child(node)
			node.position.x = item['position'][0]
			node.position.y = item['position'][1]

			own(node, container)
		elif item['type'] == 'bone':
			var node = get_node("/root/root/resources/bone1").duplicate()
			var container = get_node("/root/root/items")

			container.add_child(node)
			node.position.x = item['position'][0]
			node.position.y = item['position'][1]

			own(node, container)

static func own(node, new_owner):
	if not node == new_owner and (not node.owner or node.filename):
		node.owner = new_owner
	if node.get_child_count():
		for kid in node.get_children():
			own(kid, new_owner)

func _on_body_body_entered(body):
	print("COLLLIDDDAAAA", body)
