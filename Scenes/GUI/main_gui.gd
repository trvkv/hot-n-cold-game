extends CanvasLayer

class_name MainGui

@export var gui_player_1: GuiPlayer
@export var gui_player_2: GuiPlayer
@export var gui_actions_1: GuiActions
@export var gui_actions_2: GuiActions
@export var gui_inventory_1: GuiInventory
@export var gui_inventory_2: GuiInventory
@export var gui_message_1: VBoxContainer
@export var gui_message_2: VBoxContainer
@export var gui_message_container_1: CenterContainer
@export var gui_message_container_2: CenterContainer
@export var ready_button_1: Button
@export var ready_button_2: Button
@export var global_message: Label
@export var global_message_container: PanelContainer
@export var timed_message_scene: PackedScene

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
    assert(global_message, "Global message label invalid")
    assert(global_message_container, "Global message container invalid")
    assert(timed_message_scene, " Timed message scene invalid")

    setup_button(PlayersManager.PlayerID.PLAYER_1, false, false)
    setup_button(PlayersManager.PlayerID.PLAYER_2, false, false)
    update_message_container(PlayersManager.PlayerID.PLAYER_1)
    update_message_container(PlayersManager.PlayerID.PLAYER_2)
    set_global_message("")

    EventBus.connect("action_unsuccessful", _on_action_unsuccessful)

func _on_pressed_1() -> void:
    emit_signal("player_ready", PlayersManager.PlayerID.PLAYER_1)

func _on_pressed_2() -> void:
    emit_signal("player_ready", PlayersManager.PlayerID.PLAYER_2)

func _on_action_unsuccessful(interaction_data: InteractionData):
    if interaction_data.response is Dictionary:
        if interaction_data.response.has("error_message"):
            set_message(interaction_data.player_id, interaction_data.response["error_message"])

func setup_button(player_id: PlayersManager.PlayerID, activate: bool, show_button: bool) -> void:
    var ready_button: Button

    if player_id == PlayersManager.PlayerID.PLAYER_1:
        ready_button = ready_button_1
    elif player_id == PlayersManager.PlayerID.PLAYER_2:
        ready_button = ready_button_2
    else:
        printerr("Wrong player ID passed: ", player_id)
        return

    if activate:
        if not ready_button.is_connected("pressed", _on_pressed_1):
            ready_button.connect("pressed", _on_pressed_1)
    else:
        if ready_button.is_connected("pressed", _on_pressed_1):
            ready_button.disconnect("pressed", _on_pressed_1)

    if show_button:
        ready_button.show()
    else:
        ready_button.hide()

func update_message_container(player_id: PlayersManager.PlayerID) -> void:
    var gui_container: CenterContainer
    var message_box: VBoxContainer
    var ready_button: Button

    if player_id == PlayersManager.PlayerID.PLAYER_1:
        gui_container = gui_message_container_1
        message_box = gui_message_1
        ready_button = ready_button_1
    elif player_id == PlayersManager.PlayerID.PLAYER_2:
        gui_container = gui_message_container_2
        message_box = gui_message_2
        ready_button = ready_button_2
    else:
        printerr("Player ID is invalid: ", player_id)
        return

    if message_box.get_child_count() > 0 or ready_button.is_visible():
        gui_container.set_modulate(Color(1.0, 1.0, 1.0, 1.0))
    else:
        gui_container.set_modulate(Color(1.0, 1.0, 1.0, 0.0))

func set_message(player_id: PlayersManager.PlayerID, message: String, timeout: float = 5.0) -> void:
    if not timed_message_scene.can_instantiate():
        printerr("Cannot instantiate TimedMessage scene")
        return

    var gui_message: VBoxContainer
    if player_id == PlayersManager.PlayerID.PLAYER_1:
        gui_message = gui_message_1
    elif player_id == PlayersManager.PlayerID.PLAYER_2:
        gui_message = gui_message_2
    else:
        printerr("Wrong player ID passed: ", player_id)
        return

    if message.length() > 0:
        var timed_message: TimedMessage = timed_message_scene.instantiate()
        timed_message.player_id = player_id
        timed_message.timeout = timeout
        timed_message.autostart = true
        gui_message.add_child(timed_message)
        gui_message.move_child(timed_message, 0)
        timed_message.connect("dismissing_message", _on_dismissing_message)
        timed_message.set_text(message)

    update_message_container(player_id)

func clear_messages(player_id: PlayersManager.PlayerID) -> void:
    var message_box: VBoxContainer

    if player_id == PlayersManager.PlayerID.PLAYER_1:
        message_box = gui_message_1
    elif player_id == PlayersManager.PlayerID.PLAYER_2:
        message_box = gui_message_2
    else:
        printerr("Player ID is invalid: ", player_id)
        return

    for message in message_box.get_children():
        message_box.remove_child(message)
        message.queue_free()

func set_global_message(message: String) -> void:
    if message.length() == 0:
        global_message_container.set_modulate(Color(1.0, 1.0, 1.0, 0.0))
    else:
        global_message_container.set_modulate(Color(1.0, 1.0, 1.0, 1.0))
    global_message.set_text(message)

func _on_dismissing_message(message: TimedMessage) -> void:
    var player_id = message.player_id

    var gui_message: VBoxContainer
    if player_id == PlayersManager.PlayerID.PLAYER_1:
        gui_message = gui_message_1
    elif player_id == PlayersManager.PlayerID.PLAYER_2:
        gui_message = gui_message_2
    else:
        printerr("Wrong player ID passed: ", player_id)
        return

    gui_message.remove_child(message)
    message.queue_free()
    call_deferred("update_message_container", player_id)
