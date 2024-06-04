extends Node3D

class_name GuiStateMachine

@export var starting_scene: PackedScene

var current_screen: MenuScreen = null

signal change_screen(new_screen)

func _ready() -> void:
    print("State machine ready")
    var starting_screen: MenuScreen = scene_instanciate(starting_scene)
    assert(is_instance_valid(starting_screen), "Cannot instantiate starting node")
    if not is_instance_valid(starting_screen):
        printerr("Cannot instantiate starting node")
        return
    set_scene_current(starting_scene)

func scene_instanciate(scene: PackedScene) -> Node:
    if not scene.can_instantiate():
        return null
    return scene.instantiate()

func set_scene_current(scene: PackedScene) -> MenuScreen:
    if not is_instance_valid(scene):
        printerr("Cannot set scene! Provided PackedScene is not valid")
        return
    var next_screen: MenuScreen = scene_instanciate(scene)
    if not is_instance_valid(next_screen):
        printerr("Cannot set scene! Scene not instantiated properly")
        return
    current_screen = next_screen
    call_deferred("emit_signal", "change_screen", current_screen)
    return next_screen

func _process(_delta) -> void:
    var next_scene: PackedScene = current_screen.get_next()
    if is_instance_valid(next_scene):
        current_screen.on_exit()
        print(current_screen, ": Got next... ", next_scene)
        current_screen = set_scene_current(next_scene)
        current_screen.on_enter()
