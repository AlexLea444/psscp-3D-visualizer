# Assume the root node of the imported model is called "BirdModelRoot"
var bird_model_root : Node3D

@export var circle_radius = 200.0
@export var current_angle = 0.0

func _ready():
	# Make sure to set the root node reference correctly
	bird_model_root = $Sketchfab_scene  # or your root node name
	
	# Initial positioning of the model
	move_bird_to_angle(0)

# Move the bird to a specific angle on a circle
func move_bird_to_angle(degrees: float):
	var radians = deg_to_rad(degrees)
	current_angle = degrees
	bird_model_root.position = Vector3(cos(radians) * circle_radius, 0, sin(radians) * circle_radius)

# Input handling to rotate the bird by 30 degrees every time the right arrow is pressed
func _input(event):
	if event.is_action_pressed("ui_right"):
		move_bird_to_angle(current_angle + 30)
