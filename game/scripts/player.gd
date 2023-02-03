extends Node

const MIN_ANGLE_THRESHOLD = deg2rad(10.0)
const ANGLE_CHANGE_VELOCITY = deg2rad(10.0)
const GROW_SPEED = 0.8

# A player is a 'root'
# The root always grows downwards
# we store the angle of the clockwise rotation between the horizontal as direction
var angle = deg2rad(90.0) # You start facing steight down

var root_parts = [] # this should hold a list of nodes ( which are all root parts )

func _ready():
	pass # Replace with function body.

func init_player(spawn: Vector2):

	pass

func _process(delta):
	move_direction(delta)

func move_direction(delta):
	# Check the current angle, calculate the position to move to
	var heading = Vector2(cos(angle), sin(angle)) * GROW_SPEED * delta
	print("HEADING", heading)
	$end_of_root.position.x += heading.x
	$end_of_root.position.y += heading.y

func _input(event):
	if event.is_action_pressed("ui_left"):
		print("LEFT pressed")
		# rotate left = increase angle
		angle += deg2rad(ANGLE_CHANGE_VELOCITY)
