extends Node3D

var model_root: Node3D = null
var model_resource = null
var model = null

var animation_player: AnimationPlayer = null
var current_tween: Tween = null

@export var circle_radius: float = 5
@export var current_angle: float = 0.0
@export var circle_center: Vector3 = Vector3(0, 0, 0)

var start_angle: float = 0.0
var target_angle: float = 0.0
var tween_progress: float = 1.0  # 0 = start, 1 = finished

func _input(event):
	if event.is_action_pressed("ui_right"):
		var new_angle = (int(target_angle + 30) % 360)
		move_to_angle(new_angle)
	elif event.is_action_pressed("ui_left"):
		var new_angle = (int(target_angle - 30) % 360)
		move_to_angle(new_angle)

func move_to_angle(new_angle: float) -> void:
	# Cancel any active tween
	if current_tween:
		current_tween.kill()
	# For a smooth transition, we use the current interpolated angle as the start
	start_angle = current_angle
	target_angle = new_angle
	tween_progress = 0.0
	# Tween tween_progress from 0 to 1 over 1 seconds (change second param for timing)
	current_tween = create_tween()
	current_tween.tween_property(self, "tween_progress", 1.0, 1)
	current_tween.tween_callback(Callable(self, "on_tween_completed"))

func on_tween_completed() -> void:
	# Ensure we finish exactly at the target
	current_angle = target_angle
	tween_progress = 1.0
	if animation_player:
		animation_player.play("anim")


func _process(_delta: float) -> void:
	if model_root:
		current_angle = rad_to_deg(lerp_angle(deg_to_rad(start_angle), deg_to_rad(target_angle), tween_progress))
		
		var radians = deg_to_rad(current_angle)
		var new_position = circle_center + Vector3(cos(radians) * circle_radius, 0, sin(radians) * circle_radius)
		model_root.global_transform.origin = new_position
		
		# Compute radial vector from the bird's position toward the center
		var radial = (circle_center - new_position).normalized()
		
		#if tween_progress < 1.0:
			## Determine the direction of movement from the tween
			#var delta_angle = ((int(target_angle) - int(start_angle) + 180) % 360) - 180
			#var tangent: Vector3
			#
			#if delta_angle > 0:
				## Rotate 90 clockwise
				#tangent = Vector3(radial.z, 0, -radial.x)
			#else:
				## Rotate 90 counterclockwise
				#tangent = Vector3(-radial.z, 0, radial.x)
			#tangent = tangent.normalized()
			#
			#var desired_dir = (radial + tangent).normalized()
			#model_root.look_at(new_position - desired_dir, Vector3.UP)
		
		
		model_root.look_at(new_position - radial, Vector3.UP)
		
		# To do on axis rotation
		if (model == 'mega'):
			model_root.rotate_y(deg_to_rad(90))  
			position += Vector3(0, 1, 0)



func _ready():
	var args = OS.get_cmdline_args()
	if OS.has_feature("editor"):
		args = ["--model=mega"] 
		
	for arg in args:
		if arg.begins_with("--model="):
			model = arg.split("=")[1]
			print(model)
			if (model == "bird"):
				model_resource = load("res://bird_orange.glb") as PackedScene
			elif (model == "train"):
				scale = Vector3(.007, .007, .007)
				model_resource = load("res://steam_train.glb") as PackedScene
			elif (model == "mega"):
				scale = Vector3(.2, .2, .2)
				model_resource = load("res://megaphone.glb") as PackedScene
			else:
				assert(false, "Need to pick a model")

	if model_resource:
		model_root = model_resource.instantiate()
		add_child(model_root)
		
		animation_player = model_root.get_node("AnimationPlayer")
		if animation_player:
			animation_player.play("anim")
		
		current_angle = 0.0
		start_angle = current_angle
		target_angle = current_angle
		tween_progress = 1.0
	
		model_root.global_transform.origin = circle_center + Vector3(circle_radius, 0, 0)
