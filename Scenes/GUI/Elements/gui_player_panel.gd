extends MarginContainer

class_name GuiPlayerPanel

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.NONE:
    set = set_player_id
@export var gui_player: GuiPlayer
@export var gui_actions: GuiActions
@export var gui_inventory: GuiInventory
@export var gui_requirements_list: VBoxContainer
@export var gui_requirements_container: CenterContainer
@export var gui_message_list: VBoxContainer
@export var gui_message_container: MarginContainer
@export var ready_button: Button
@export var timed_message_scene: PackedScene

@export var query_ready_icon: Texture2D
@export var query_ready_icon_color: Color = Color(1.0, 1.0, 1.0, 1.0)

@export var icon_hot: Texture2D
@export var icon_hot_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var icon_warm: Texture2D
@export var icon_warm_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var icon_cold: Texture2D
@export var icon_cold_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var icon_freezing: Texture2D
@export var icon_freezing_color: Color = Color(1.0, 1.0, 1.0, 1.0)

signal player_ready(player_id)

func _ready() -> void:
    assert(is_instance_valid(gui_player), "Gui player invalid")
    assert(is_instance_valid(gui_actions), "Gui actions invalid")
    assert(is_instance_valid(gui_inventory), "gui inventory for player invalid")
    assert(is_instance_valid(gui_requirements_list), "gui requirements list invalid")
    assert(is_instance_valid(gui_requirements_container), "gui requirements container invalid")
    assert(is_instance_valid(gui_message_list), "gui message list invalid")
    assert(is_instance_valid(gui_message_container), "gui message container invalid")
    assert(is_instance_valid(ready_button), "ready button invalid")
    assert(is_instance_valid(timed_message_scene), "times message scene invalid")

    EventBus.connect("distance_updated", _on_distance_updated)
    EventBus.connect("query_ready", _on_query_ready)

    set_player_id(player_id)

    setup_ready_button(false, false)
    update_requirements_container()
    update_information_container()

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

func _on_query_ready(query_player_id: PlayersManager.PlayerID) -> void:
    if player_id == query_player_id:
        set_information_message("HOT-COLD query is ready!", 9.0, query_ready_icon, query_ready_icon_color)

func _on_distance_updated(requesting_player_id: PlayersManager.PlayerID, distance: float) -> void:
    if player_id == requesting_player_id:
        var message: String = ""
        var icon: Texture2D = null
        var color: Color = Color(1.0, 1.0, 1.0, 1.0)
        if distance < 3.0:
            message = "HOT!"
            icon = icon_hot
            color = icon_hot_color
        elif distance < 9.0:
            message = "WARM..."
            icon = icon_warm
            color = icon_warm_color
        elif distance < 15.0:
            message = "Cold..."
            icon = icon_cold
            color = icon_cold_color
        else: # freezing
            message = "FREEZING!"
            icon = icon_freezing
            color = icon_freezing_color
        print(color)
        set_information_message(message, 9.0, icon, color)

func setup_ready_button(activate: bool, show_button: bool) -> void:
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

func update_requirements_container() -> void:
    if gui_requirements_list.get_child_count() > 0 or ready_button.is_visible():
        gui_requirements_container.set_modulate(Color(1.0, 1.0, 1.0, 1.0))
    else:
        gui_requirements_container.set_modulate(Color(1.0, 1.0, 1.0, 0.0))

func update_information_container() -> void:
    if gui_message_list.get_child_count() > 0:
        gui_message_container.set_modulate(Color(1.0, 1.0, 1.0, 1.0))
    else:
        gui_message_container.set_modulate(Color(1.0, 1.0, 1.0, 0.0))

func instance_timed_message(message: String, timeout: float) -> TimedMessage:
    if not timed_message_scene.can_instantiate():
        printerr("Cannot instantiate TimedMessage scene")
        return null

    var timed_message: TimedMessage = timed_message_scene.instantiate()
    timed_message.player_id = player_id
    timed_message.timeout = timeout
    timed_message.autostart = true
    timed_message.text = message
    return timed_message

func set_requirement_message(message: String) -> void:
    if message.length() > 0:
        var timed_message: TimedMessage = instance_timed_message(message, 0.0)
        if is_instance_valid(timed_message):
            gui_requirements_list.add_child(timed_message)
            gui_requirements_list.move_child(timed_message, 0)
    update_requirements_container()

func set_information_message(message: String, timeout: float = 5.0, icon: Texture2D = null, color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
    if message.length() > 0:
        var timed_message: TimedMessage = instance_timed_message(message, timeout)
        if is_instance_valid(timed_message):
            gui_message_list.add_child(timed_message)
            gui_message_list.move_child(timed_message, 0)
            timed_message.icon = icon
            timed_message.icon_color = color
            timed_message.connect("dismissing_message", _on_dismissing_message)
    update_information_container()

func clear_requirement_messages() -> void:
    for message in gui_requirements_list.get_children():
        gui_requirements_list.remove_child(message)
        message.queue_free()
    update_requirements_container()

func _on_dismissing_message(message: TimedMessage) -> void:
    if message.player_id == player_id:
        gui_message_list.remove_child(message)
        message.queue_free()
        call_deferred("update_information_container")
