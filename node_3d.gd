extends Node3D

class SpriteState:
	var node: Node3D
	var model_type: String
	var current_angle: float
	var start_angle:   float
	var target_angle:  float
	var tween_progress := 1.0
	var tween: Tween
	var active : bool
	var color : Color
	var movedYet := false

# Number of sprites to instantiate and manage
var instance_count: int 
# Common configuration for circular path
@export var circle_radius: float = 5.0
@export var circle_center: Vector3 = Vector3.ZERO
var pos : Vector3 = Vector3.ZERO

# Array to hold each sprite's state
var instances: Array = []
	
func start_up(colorsArray : Array, models : Array):
	instance_count = len(colorsArray)
	
	var model_resource: PackedScene
	var model_scale = Vector3.ONE

	for i in range(instance_count):
		var start_ang = 0
		var inst = SpriteState.new()
		inst.active = false
		inst.current_angle = start_ang
		
		inst.model_type = models[i]
		
		match inst.model_type:
			"bird":
				model_resource = preload("res://bird_orange.glb") as PackedScene
				model_scale = Vector3.ONE
			"train":
				model_resource = preload("res://steam_train.glb") as PackedScene
				model_scale = Vector3(0.007, 0.007, 0.007)
			"mega":
				model_resource = preload("res://megaphone.glb") as PackedScene
				model_scale = Vector3(0.2, 0.2, 0.2)
			_: # unknown model type
				push_error("Unknown model_type: %s" % inst.model_type)
				return
		
		inst.node          = model_resource.instantiate()
		inst.node.visible = false
		inst.start_angle   = start_ang
		inst.target_angle  = start_ang
		inst.tween_progress= 1.0
		inst.tween = null
		
		var node = inst.node
		add_child(node)
		
		if inst.model_type == "mega":
			var color_for_this := Color(colorsArray[i])  # your RGB tint
			tint_meshes(node, color_for_this)
		
		node.scale = model_scale
		# Position at its starting angle
		var rad = deg_to_rad(start_ang)
		node.global_transform.origin = circle_center + Vector3(cos(rad) * circle_radius, 0, sin(rad) * circle_radius)
		instances.append(inst)

func tint_meshes(root: Node, tint: Color) -> void:
	for child in root.get_children():
		if child is MeshInstance3D:
			var existing_material: Material = child.get_active_material(0)
			if existing_material is StandardMaterial3D:
				var mat := existing_material.duplicate() as StandardMaterial3D
				mat.albedo_color = tint
				child.set_surface_override_material(0, mat)
		else:
			tint_meshes(child, tint)


func render_and_move(to_angles: Array) -> void:
	for inst in instances:
		inst.active = false
		inst.node.visible = false

	for id in range(len(to_angles)):
		if id >= 0 and id < instances.size():
			var inst = instances[id]
			if to_angles[id] != -999:
				inst.active = true
				inst.node.visible = true
				move_to_angle(id, to_angles[id])	

# Move a specific sprite (by index) to a new angle
func move_to_angle(id: int, new_angle: float) -> void:
	if id < 0 or id >= instances.size():
		push_error("Invalid instance ID: %d" % id)
		return
		
	var inst = instances[id]
	
	# Cancel any existing tween
	if inst.tween:
		inst.tween.kill()
		
	if !inst.movedYet:
		inst.current_angle = new_angle
		inst.movedYet = true
		inst.start_angle   = new_angle
		inst.target_angle  = new_angle
		inst.tween_progress = 1.0
		return
	# Setup interpolation
	inst.tween_progress = 0.0
	inst.start_angle    = inst.current_angle
	inst.target_angle   = new_angle
	inst.tween = create_tween()
	inst.tween.tween_property(inst, "tween_progress", 1.0, 1.0)
	inst.tween.tween_callback(Callable(self, "_on_tween_completed").bind(id))
	
# Callback when a tween finishes
func _on_tween_completed(id: int) -> void:
	var inst = instances[id]
	inst.current_angle = inst.target_angle
	inst.tween_progress = 1.0

func _process(delta: float) -> void:
	# Update all instances each frame
	for i in range(instances.size()):
		var inst = instances[i]
		if not inst.active:
			continue
		# Interpolate angle
		inst.current_angle = rad_to_deg(lerp_angle(deg_to_rad(inst.start_angle), deg_to_rad(inst.target_angle), inst.tween_progress))
		var rad = deg_to_rad(inst.current_angle)
		var node = inst.node
		
		# Compute and apply new position
		if (inst.model_type == 'bird'):
			pos = circle_center + Vector3(cos(rad) * 1.2 * circle_radius, 0, 1.35 * sin(rad) * circle_radius)
		else:
			pos = circle_center + Vector3(cos(rad) * 1.08 * circle_radius, 0, 1.250 * sin(rad) * circle_radius)
		node.global_transform.origin = pos
		# Face toward center
		var radial = (circle_center - pos).normalized()
		node.look_at(pos - radial, Vector3.UP)
		
		if (inst.model_type == 'mega'):
			node.rotate_y(deg_to_rad(90))  
			node.position += Vector3(0, 1, 0)
