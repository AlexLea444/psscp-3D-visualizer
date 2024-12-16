extends Node3D

var circle_radius = 300  # Radius of the speaker circle in pixels
var speakers = []
var number_of_speakers = 8
var radius_of_speakers = 5.0  # Radius in 3D space

func _ready():
	for i in range(number_of_speakers):
		var speaker_mesh = MeshInstance3D.new()
		speaker_mesh.mesh = BoxMesh.new()  # Replace with your speaker mesh
		add_child(speaker_mesh)
		
		# Calculate position in a circle
		var angle = deg_to_rad(i * (360.0 / number_of_speakers))
		var x = cos(angle) * radius_of_speakers
		var z = sin(angle) * radius_of_speakers
		speaker_mesh.position = Vector3(x, 0, z)
		speakers.append(speaker_mesh)
