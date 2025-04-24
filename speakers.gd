extends Node3D

var speakers = []
var number_of_speakers = 8
var radius_of_speakers = 5.0  # Radius in 3D space


# Replace with this to customize speaker locations instead of hardcoded circle
var speaker_positions = [
4.5 * Vector2(-1.2750,   -0.5100),
   4.5 * Vector2(-1.2750,    0.4100),
   4.5 * Vector2(-0.8650,    1.2100),
   4.5 * Vector2(-0.0050,    1.5300),
   4.5 * Vector2( 0.8550,    1.2100),
   4.5 * Vector2( 1.2750,    0.4100),
   4.5 * Vector2( 1.2750,   -0.5100),
   4.5 * Vector2( 0.8450,   -1.2700),
   4.5 * Vector2(-0.0050,   -1.5300),
   4.5 * Vector2(-0.8650,   -1.2500),
]
var speaker_scene = preload("res://speaker_fnaf.glb")

func make_transparent(node: Node):
	for child in node.get_children():
		if child is MeshInstance3D:
			var existing_material: Material = child.get_active_material(0)
			if existing_material is StandardMaterial3D:
				var mat := existing_material.duplicate() as StandardMaterial3D
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				mat.albedo_color.a = .7
				child.set_surface_override_material(0, mat)
		else:
			make_transparent(child)



func _ready():
	for pos in speaker_positions:
		var speaker_instance = speaker_scene.instantiate()
		speaker_instance.scale = Vector3(0.004, 0.004, 0.004)

		var angle = atan2(pos.y, pos.x)
		var adjusted_angle = PI / 2 - angle + deg_to_rad(180)
		speaker_instance.rotate_y(adjusted_angle)
		
		make_transparent(speaker_instance)
		add_child(speaker_instance)

		# Convert (x, y) to 3D coordinates (assuming y corresponds to the Z-axis)
		speaker_instance.position = Vector3(pos.x, 1, pos.y)
		speakers.append(speaker_instance)
