extends Node3D

class_name StateMachine

@export var starting_scene: PackedScene

var current_screen: Node = null
var previous_screen: Node = null

signal change_screen(new_screen)

func _ready() -> void:
    var starting_screen = scene_instanciate(starting_scene)
    if not is_instance_valid(starting_screen):
        return
    set_scene_current(starting_scene)

func set_scene_current(scene: PackedScene) -> Node:
    if not is_instance_valid(scene):
        printerr("Cannot set scene! Provided PackedScene is not valid")
        return
    var next_screen: Node = scene_instanciate(scene)
    if not is_instance_valid(next_screen):
        printerr("Cannot set scene! Scene not instantiated properly")
        return
    previous_screen = current_screen
    current_screen = next_screen
    call_deferred("emit_signal", "change_screen", previous_screen, current_screen)
    return next_screen

func scene_instanciate(scene: PackedScene) -> Node:
    if not is_instance_valid(scene):
        return null
    if not scene.can_instantiate():
        return null
    return scene.instantiate()

func _process(_delta) -> void:
    if not is_instance_valid(current_screen):
        return

    var next_scene: PackedScene = current_screen.is_next_ready()
    if is_instance_valid(next_scene):
        current_screen.on_exit()
        print(current_screen, ": Got next... ", next_scene)
        current_screen = set_scene_current(next_scene)
        current_screen.on_enter()
