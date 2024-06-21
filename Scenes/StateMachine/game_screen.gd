extends Node3D

class_name GameScreen

@export var next_scene: SceneLoader.SCENE

var _next_scene_to_load: PackedScene = null

func on_enter() -> void:
    pass

func on_exit() -> void:
    pass

func on_update(_delta) -> void:
    pass

func load_next() -> void:
    var next = SceneLoader.get_scene(next_scene)
    if not is_instance_valid(next):
        printerr("Obtained scene is not valid")
        return
    _next_scene_to_load = next

func is_next_ready() -> PackedScene:
    return _next_scene_to_load

