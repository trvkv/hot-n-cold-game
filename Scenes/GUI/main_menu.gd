extends MenuScreen

@export var button_new_game: Button
@export var button_exit: Button

func _ready() -> void:
    assert(button_new_game, "New game button not found")
    assert(button_exit, "Exit button not found")
    assert(next_scene, "Next scene not set")

    button_new_game.connect("pressed", _on_pressed_new_game)
    button_exit.connect("pressed", _on_pressed_exit)

func _on_pressed_new_game() -> void:
    load_next(next_scene)

func _on_pressed_exit() -> void:
    get_tree().quit(0)
