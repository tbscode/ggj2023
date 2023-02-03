extends Node

const MIN_ANGLE_THRESHOLD = deg2rad(10.0)
const ANGLE_CHANGE_VELOCITY = deg2rad(10.0) * 600.0
const GROW_SPEED = 80.0
const MAXIMUM_ROOT_ELEMENT_LENGTH = 40.0
const ROOT_SHRINK_SPEED = 0.1

# A player is a 'root'
# The root always grows downwards
# we store the angle of the clockwise rotation between the horizontal as direction
var angle = deg2rad(90.0) # You start facing steight down
var current_root_element_length = 0.0
var root_parts = [] # this should hold a list of nodes ( which are all root parts )

func _ready():
	pass # Replace with function body.

func init_player(spawn: Vector2):
	pass

func _process(delta):
	move_direction(delta)
	process_direction_input(delta)

func process_direction_input(delta):
	if Input.is_action_pressed("ui_left"):
		# rotate left = increase angle
		#if angle < deg2rad(180.0) - MIN_ANGLE_THRESHOLD:
		angle += deg2rad(ANGLE_CHANGE_VELOCITY) * delta
	elif Input.is_action_pressed("ui_right"):
		#if angle > MIN_ANGLE_THRESHOLD:
		angle -= deg2rad(ANGLE_CHANGE_VELOCITY) * delta
	get_node("/root/root/game_ui/root_direction_display").rotation = angle - deg2rad(90.0)

func move_direction(delta):
	# Check the current angle, calculate the position to move to
	var heading = Vector2(cos(angle), sin(angle)) * GROW_SPEED * delta
	$end_of_root.position.x += heading.x
	$end_of_root.position.y += heading.y
	current_root_element_length += heading.length()

	if current_root_element_length >= MAXIMUM_ROOT_ELEMENT_LENGTH:
		# now we sould place a new root texture!
		current_root_element_length = 0.0
		append_root()

func append_root():
	# TODO in the furture this would also place the root texture along the way
	print("APPENDING A ROOT")
	var node = get_node("/root/root/resources/root_element").duplicate()
	add_child(node)
	node.position.x = $end_of_root.position.x
	node.position.y = $end_of_root.position.y
	own(node, self)
	print("INSTANCE", node);

static func own(node, new_owner):
	if not node == new_owner and (not node.owner or node.filename):
		node.owner = new_owner
	if node.get_child_count():
		for kid in node.get_children():
			own(kid, new_owner)
