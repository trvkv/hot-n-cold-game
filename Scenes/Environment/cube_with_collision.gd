extends MeshInstance3D

@export var can_fade_when_near_player: bool = false

@onready var collision_body = $StaticBody3D

func _ready():
    if can_fade_when_near_player:
        collision_body.add_to_group("fadable_walls")
        var material: StandardMaterial3D = get_active_material(0)
        material.set_distance_fade(StandardMaterial3D.DISTANCE_FADE_PIXEL_ALPHA)
        material.set_distance_fade_max_distance(0.0)
