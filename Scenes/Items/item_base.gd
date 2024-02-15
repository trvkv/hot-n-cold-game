extends Resource

class_name ItemBase

@export var icon: Texture2D = null

func interact() -> void:
    pass

func get_class_name() -> StringName:
    return &"ItemBase"
