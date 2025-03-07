extends Node3D

var bird_model_root: Node3D = null
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


func _process(delta: float) -> void:
	if bird_model_root:
		current_angle = rad_to_deg(lerp_angle(deg_to_rad(start_angle), deg_to_rad(target_angle), tween_progress))
		
		var radians = deg_to_rad(current_angle)
		var new_position = circle_center + Vector3(cos(radians) * circle_radius, 0, sin(radians) * circle_radius)
		bird_model_root.global_transform.origin = new_position
		
		# Compute radial vector from the bird's position toward the center
		var radial = (circle_center - new_position).normalized()
		
		if tween_progress < 1.0:
			# Determine the direction of movement from the tween
			var delta_angle = ((int(target_angle) - int(start_angle) + 180) % 360) - 180
			var tangent: Vector3
			
			if delta_angle > 0:
				# Rotate 90 clockwise
				tangent = Vector3(radial.z, 0, -radial.x)
			else:
				# Rotate 90 counterclockwise
				tangent = Vector3(-radial.z, 0, radial.x)
			tangent = tangent.normalized()
			
			var desired_dir = (radial + tangent).normalized()
			bird_model_root.look_at(new_position - desired_dir, Vector3.UP)
		else:
			# Bird is not moving- face center
			bird_model_root.look_at(new_position - radial, Vector3.UP)

func _ready():
	var model_resource = load("res://bird_orange.glb") as PackedScene
	if model_resource:
		bird_model_root = model_resource.instantiate()
		add_child(bird_model_root)
		
		animation_player = bird_model_root.get_node("AnimationPlayer")
		if animation_player:
			animation_player.play("anim")
		
		current_angle = 0.0
		start_angle = current_angle
		target_angle = current_angle
		tween_progress = 1.0
	
		bird_model_root.global_transform.origin = circle_center + Vector3(circle_radius, 0, 0)
