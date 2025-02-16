extends Node3D

var bird_model_root: Node3D = null

var animation_player: AnimationPlayer = null

@export var circle_radius: float = 5
@export var current_angle: float = 0.0
@export var circle_center: Vector3 = Vector3(0, 0, 0)  # Center of the circle


func _input(event):
	if event.is_action_pressed("ui_right"):
		move_to_angle(int(current_angle + 30) % 360)

# Function to move the bird to a specific angle
func move_to_angle(degrees: float):
	var radians = deg_to_rad(degrees)
	current_angle = degrees
	
	# Calculate the new position on the circle path
	bird_model_root.global_transform.origin = circle_center + Vector3(
		cos(radians) * circle_radius,
		0, 
		sin(radians) * circle_radius
	)
	
	animation_player = bird_model_root.get_node("AnimationPlayer")
	animation_player.play("anim") 

func _ready():
	var model_resource = load("res://bird_orange.glb") as PackedScene
	if model_resource != null:
		bird_model_root = model_resource.instantiate()
		add_child(bird_model_root)
		
		# Find the AnimationPlayer node and start playing the animation
		animation_player = bird_model_root.get_node("AnimationPlayer")
		if animation_player != null:
			animation_player.play("anim") 
		
		bird_model_root.global_transform.origin = circle_center + Vector3(circle_radius, 0, 0)
