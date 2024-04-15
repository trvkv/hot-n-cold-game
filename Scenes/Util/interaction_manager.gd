extends Control

@export var player_1_interaction_gui: Control
@export var player_2_interaction_gui: Control

var player_interaction_data: Dictionary = {}

func _ready() -> void:
    # initialize players data
    for player in PlayersManager.get_players():
        player_interaction_data[player] = {}

    assert(is_instance_valid(player_1_interaction_gui), "Player 1 gui not valid")
    assert(is_instance_valid(player_2_interaction_gui), "Player 2 gui not valid")

    EventBus.connect("update_interactees", _on_update_interactees)
    EventBus.connect("update_items", _on_update_items)

func _on_update_interactees(player, interactees, active_interactee) -> void:
    if player not in player_interaction_data.keys():
        printerr("FATAL: Player not found in player interaction data!")
        return

    player_interaction_data[player]["interactees"] = interactees
    player_interaction_data[player]["active_interactee"] = active_interactee

    reconstruct_gui(player)

func _on_update_items(player, items, active_item) -> void:
    if player not in player_interaction_data.keys():
        printerr("FATAL: Player not found in player interaction data!")
        return

    player_interaction_data[player]["items"] = items
    player_interaction_data[player]["active_item"] = active_item

    reconstruct_gui(player)

func reconstruct_gui(player: Player) -> void:
    var gui = get_interaction_gui(player)
    if not is_instance_valid(gui):
        printerr("Interaction gui for %s is invalid" % PlayersManager.get_player_name(player.player_id))
        return

    # resetting players gui
    gui.clear_actions()

    var active_interactee = null
    if "active_interactee" in player_interaction_data[player].keys():
        active_interactee = player_interaction_data[player]["active_interactee"]
        for action in get_actions(active_interactee):
            add_action_label_to_gui(gui, action)

    if "active_item" in player_interaction_data[player].keys():
        var active_item = player_interaction_data[player]["active_item"]
        for action in get_actions(active_item):
            if PlayerActions.should_action_be_available(action, active_interactee):
                add_action_label_to_gui(gui, action)

func add_action_label_to_gui(gui, action) -> void:
    gui.add_action(action)

func get_actions(active_resource) -> Array[PlayerActions.ACTIONS]:
    if not is_instance_valid(active_resource):
        return []

    var actions: Array[PlayerActions.ACTIONS] = active_resource.get("actions")
    if actions == null:
        printerr("Actions not available on: ", active_resource)
        return []

    return actions

func get_interaction_gui(player: Player) -> Control:
    if player.player_id == PlayersManager.PlayerID.PLAYER_1:
        return player_1_interaction_gui
    elif player.player_id == PlayersManager.PlayerID.PLAYER_2:
        return player_2_interaction_gui
    printerr("Wrong player given... (", player, ")")
    return null
