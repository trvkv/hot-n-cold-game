extends Control

class_name MenuScreen

var _next_scene_to_load: PackedScene = null

func on_enter() -> void:
    pass

func on_exit() -> void:
    pass

func on_update(_delta) -> void:
    pass

func set_next(next: PackedScene) -> void:
    _next_scene_to_load = next

func get_next() -> PackedScene:
    return _next_scene_to_load
