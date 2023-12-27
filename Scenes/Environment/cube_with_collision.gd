extends MeshInstance3D

@export var can_fade_when_near_player: bool = false

@onready var collision_body = $StaticBody3D

func _ready():
    if can_fade_when_near_player:
        collision_body.add_to_group("fadable_walls")
