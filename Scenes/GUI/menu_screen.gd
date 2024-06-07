extends Control

class_name MenuScreen

@export var next_scene: PackedScene

var _next_scene_to_load: PackedScene = null

func on_enter() -> void:
    pass

func on_exit() -> void:
    pass

func on_update(_delta) -> void:
    pass

func load_next(next: PackedScene) -> void:
    _next_scene_to_load = next

func is_next_ready() -> PackedScene:
    return _next_scene_to_load
