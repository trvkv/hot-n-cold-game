extends MarginContainer

class_name GuiPlayerPanel

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.NONE:
    set = set_player_id
@export var gui_player: GuiPlayer
@export var gui_actions: GuiActions
@export var gui_inventory: GuiInventory
@export var gui_message: VBoxContainer
@export var gui_message_container: CenterContainer
@export var ready_button: Button
@export var timed_message_scene: PackedScene

signal player_ready(player_id)

func _ready() -> void:
    assert(is_instance_valid(gui_player), "Gui player invalid")
    assert(is_instance_valid(gui_actions), "Gui actions invalid")
    assert(is_instance_valid(gui_inventory), "gui inventory for player invalid")
    assert(is_instance_valid(gui_message), "gui message invalid")
    assert(is_instance_valid(gui_message_container), "gui message container invalid")
    assert(is_instance_valid(ready_button), "ready button invalid")
    assert(is_instance_valid(timed_message_scene), "times message scene invalid")

    set_player_id(player_id)

    setup_button(false, false)
    update_message_container()

func set_player_id(player_id_) -> void:
    player_id = player_id_
    if is_instance_valid(gui_player):
        gui_player.player_id = player_id
    if is_instance_valid(gui_actions):
        gui_actions.player_id = player_id
    if is_instance_valid(gui_inventory):
        gui_inventory.player_id = player_id

func _enter_tree():
    set_player_id(player_id)

func _on_pressed() -> void:
    emit_signal("player_ready", player_id)

func setup_button(activate: bool, show_button: bool) -> void:
    if activate:
        if not ready_button.is_connected("pressed", _on_pressed):
            ready_button.connect("pressed", _on_pressed)
    else:
        if ready_button.is_connected("pressed", _on_pressed):
            ready_button.disconnect("pressed", _on_pressed)

    if show_button:
        ready_button.show()
    else:
        ready_button.hide()

func update_message_container() -> void:
    if gui_message.get_child_count() > 0 or ready_button.is_visible():
        gui_message_container.set_modulate(Color(1.0, 1.0, 1.0, 1.0))
    else:
        gui_message_container.set_modulate(Color(1.0, 1.0, 1.0, 0.0))

func set_message(message: String, timeout: float = 5.0) -> void:
    if not timed_message_scene.can_instantiate():
        printerr("Cannot instantiate TimedMessage scene")
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

    update_message_container()

func clear_messages() -> void:
    for message in gui_message.get_children():
        gui_message.remove_child(message)
        message.queue_free()
    update_message_container()

func _on_dismissing_message(message: TimedMessage) -> void:
    if message.player_id == player_id:
        gui_message.remove_child(message)
        message.queue_free()
        call_deferred("update_message_container")
