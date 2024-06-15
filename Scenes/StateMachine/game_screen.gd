extends Node3D

class_name GameScreen

@export var next_scene: PackedScene

var _next_scene_to_load: PackedScene = null

func on_enter() -> void:
    pass

func on_exit() -> void:
    pass

func on_update(_delta) -> void:
    pass

func load_next() -> void:
    if is_instance_valid(next_scene):
        print("Loading next... ", next_scene)
    else:
        printerr("Attempting to load next scene, but it's invalid: ", next_scene)
    _next_scene_to_load = next_scene

func is_next_ready() -> PackedScene:
    return _next_scene_to_load

