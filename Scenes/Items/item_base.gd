extends Resource

class_name ItemBase

@export var icon: Texture2D = null
@export var actions: Array[ItemActions.ACTIONS] = []

func interact() -> void:
    pass

func get_class_name() -> StringName:
    return &"ItemBase"
