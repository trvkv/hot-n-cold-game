extends Node3D

@export var state_machine: Node3D
@export var gui_menu_container: Control
@export var game_container: Node3D

func _ready() -> void:
    assert(state_machine, "State machine node invalid")
    assert(gui_menu_container, "Gui menu container invalid")
    assert(game_container, "Game container invalid")
    state_machine.connect("change_screen", _on_change_screen)

func _on_change_screen(previous_screen: Node, new_screen: Node) -> void:
    if previous_screen is MenuScreen:
        for child in gui_menu_container.get_children():
            gui_menu_container.remove_child(child)
            child.queue_free()
    elif previous_screen is GameScreen:
        for child in game_container.get_children():
            game_container.remove_child(child)
            child.queue_free()

    if new_screen is MenuScreen:
        gui_menu_container.add_child(new_screen)
    elif new_screen is GameScreen:
        game_container.add_child(new_screen)

func _on_load_game(new_game: Node3D) -> void:
    for child in game_container.get_children():
        game_container.remove_child(child)
        child.queue_free()
    game_container.add_child(new_game)
