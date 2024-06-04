extends Node3D

@export var gui_state_machine: Node3D
@export var gui_menu_container: Control

func _ready() -> void:
    assert(gui_state_machine, "Gui state machine node invalid")
    assert(gui_menu_container, "Gui menu container invalid")
    gui_state_machine.connect("change_screen", _on_change_screen)

func _on_change_screen(new_screen: MenuScreen) -> void:
    for child in gui_menu_container.get_children():
        gui_menu_container.remove_child(child)
        child.queue_free()
    gui_menu_container.add_child(new_screen)
