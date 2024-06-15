extends CanvasLayer

class_name MainGui

@export var gui_player_1: GuiPlayer
@export var gui_player_2: GuiPlayer
@export var gui_actions_1: GuiActions
@export var gui_actions_2: GuiActions
@export var gui_inventory_1: GuiInventory
@export var gui_inventory_2: GuiInventory
@export var gui_message_container_1: CenterContainer
@export var gui_message_container_2: CenterContainer
@export var gui_message_1: Label
@export var gui_message_2: Label
@export var ready_button_1: Button
@export var ready_button_2: Button

signal player_ready(player_id)

func _ready() -> void:
    assert(gui_player_1, "gui for player 1 not set correctly")
    assert(gui_player_2, "gui for player 2 not set correctly")
    assert(gui_actions_1, "gui actions for player 1 invalid")
    assert(gui_actions_2, "gui actions for player 2 invalid")
    assert(gui_inventory_1, "gui inventory for player 1 invalid")
    assert(gui_inventory_2, "gui inventory for player 2 invalid")
    assert(gui_message_container_1, "gui message container 1 invalid")
    assert(gui_message_container_2, "gui message container 2 invalid")
    assert(gui_message_1, "gui message 1 invalid")
    assert(gui_message_2, "gui message 2 invalid")
    assert(ready_button_1, "ready button 1 invalid")
    assert(ready_button_2, "ready button 2 invalid")

    setup_button(PlayersManager.PlayerID.PLAYER_1, false, false)
    setup_button(PlayersManager.PlayerID.PLAYER_2, false, false)

func _on_pressed_1() -> void:
    emit_signal("player_ready", PlayersManager.PlayerID.PLAYER_1)

func _on_pressed_2() -> void:
    emit_signal("player_ready", PlayersManager.PlayerID.PLAYER_2)

func setup_button(player_id: PlayersManager.PlayerID, activate: bool, show_button: bool) -> void:
    var ready_button: Button

    if player_id == PlayersManager.PlayerID.PLAYER_1:
        ready_button = ready_button_1
    elif player_id == PlayersManager.PlayerID.PLAYER_2:
        ready_button = ready_button_2

    if activate:
        ready_button.connect("pressed", _on_pressed_1)
    else:
        if ready_button.is_connected("pressed", _on_pressed_1):
            ready_button.disconnect("pressed", _on_pressed_1)

    if show_button:
        ready_button.show()
    else:
        ready_button.hide()

func set_message(player_id: PlayersManager.PlayerID, message: String) -> void:
    var gui_message: Label
    var gui_container: CenterContainer

    if player_id == PlayersManager.PlayerID.PLAYER_1:
        gui_message = gui_message_1
        gui_container = gui_message_container_1
    elif player_id == PlayersManager.PlayerID.PLAYER_2:
        gui_message = gui_message_2
        gui_container = gui_message_container_2

    if message.length() == 0:
        gui_container.set_modulate(Color(1.0, 1.0, 1.0, 0.0))
    else:
        gui_container.set_modulate(Color(1.0, 1.0, 1.0, 1.0))

    gui_message.set_text(message)
