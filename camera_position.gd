extends Node3D

@export var rotation_speed = 0.3

var rotation_y: float = 0.0

func _process(delta):
	set_rotation(Vector3(0.0, rotation_y, 0.0))
	rotation_y += rotation_speed * delta
