extends CanvasLayer

class_name MainGui

@export var players_panels: Array[GuiPlayerPanel] = []
@export var global_message: Label
@export var global_message_container: PanelContainer

signal player_ready(player_id)

func _ready() -> void:
    assert(is_instance_valid(global_message), "Global message label invalid")
    assert(is_instance_valid(global_message_container), "Global message container invalid")

    for panel in players_panels:
        assert(is_instance_valid(panel), "Player panel invalid")
        panel.connect("player_ready", _on_player_ready)

    EventBus.connect("action_successful", _on_action_successful)
    EventBus.connect("action_unsuccessful", _on_action_unsuccessful)

    set_global_message("")

func _on_action_unsuccessful(interaction_data: InteractionData):
    if interaction_data.response is Dictionary:
        if interaction_data.response.has("error_message"):
            var panel: GuiPlayerPanel = get_player_panel(interaction_data.player_id)
            if is_instance_valid(panel):
                panel.set_message(interaction_data.response["error_message"])

func _on_action_successful(interaction_data: InteractionData):
    if interaction_data.response is Dictionary:
        if interaction_data.response.has("success_message"):
            var panel: GuiPlayerPanel = get_player_panel(interaction_data.player_id)
            if is_instance_valid(panel):
                panel.set_message(interaction_data.response["success_message"])

func _on_player_ready(player_id: PlayersManager.PlayerID) -> void:
    emit_signal("player_ready", player_id)

func get_player_panel(player_id: PlayersManager.PlayerID) -> GuiPlayerPanel:
    for panel in players_panels:
        if panel.player_id == player_id:
            return panel
    return null

func setup_button(player_id: PlayersManager.PlayerID, activate: bool, show_button: bool) -> void:
    var panel: GuiPlayerPanel = get_player_panel(player_id)
    if not is_instance_valid(panel):
        printerr("Player panel instance invalid for player ", player_id)
        return
    panel.setup_button(activate, show_button)

func update_message_container(player_id: PlayersManager.PlayerID) -> void:
    var panel: GuiPlayerPanel = get_player_panel(player_id)
    if not is_instance_valid(panel):
        printerr("Player panel instance invalid for player ", player_id)
        return
    panel.update_message_container()

func set_message(player_id: PlayersManager.PlayerID, message: String, timeout: float = 5.0) -> void:
    var panel: GuiPlayerPanel = get_player_panel(player_id)
    if not is_instance_valid(panel):
        printerr("Player panel instance invalid for player ", player_id)
        return
    panel.set_message(message, timeout)

func clear_messages(player_id: PlayersManager.PlayerID) -> void:
    var panel: GuiPlayerPanel = get_player_panel(player_id)
    if not is_instance_valid(panel):
        printerr("Player panel instance invalid for player ", player_id)
        return
    panel.clear_messages()

func set_global_message(message: String) -> void:
    if message.length() == 0:
        global_message_container.set_modulate(Color(1.0, 1.0, 1.0, 0.0))
    else:
        global_message_container.set_modulate(Color(1.0, 1.0, 1.0, 1.0))
    global_message.set_text(message)
