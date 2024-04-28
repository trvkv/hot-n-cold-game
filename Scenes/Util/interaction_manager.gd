extends Control

@export var player_1_interaction_gui: Control
@export var player_2_interaction_gui: Control

var player_interaction_data: Dictionary = {}

func _ready() -> void:
    # initialize players data
    for player in PlayersManager.get_players():
        player_interaction_data[player] = {}
        player_interaction_data[player]["interaction_area"] = get_interaction_area(player)

    assert(is_instance_valid(player_1_interaction_gui), "Player 1 gui not valid")
    assert(is_instance_valid(player_2_interaction_gui), "Player 2 gui not valid")

    EventBus.connect("trigger_interaction", _on_trigger_interaction)
    EventBus.connect("update_interactees", _on_update_interactees)
    EventBus.connect("update_items", _on_update_items)
    EventBus.connect("update_actions", _on_update_actions)
    EventBus.connect("interact", _on_interact)

func _on_interact(interactee, interactor, action) -> void:
    if interactee.has_method("interact"):
        interactee.interact(interactee, interactor, action)

func _on_trigger_interaction(player, _interaction_area) -> void:
    var active_interactee = get_active_interactee(player)
    if is_instance_valid(active_interactee):
        var action = get_active_action(player)
        EventBus.emit_signal("interact", active_interactee, player, action)

func _on_update_actions(player, actions, active_action) -> void:
    if player not in player_interaction_data.keys():
        printerr("FATAL: Player not found in player interaction data!")
        return

    player_interaction_data[player]["actions"] = actions
    player_interaction_data[player]["active_action"] = active_action

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
    gui.set_actions_inactive()
    gui.remove_actions()

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

    # all actions here should be inactive, because all were deleted above
    # make first action an active one
    var elements = gui.get_elements()
    if elements.size() == 0:
        return

    var action: PlayerActions.ACTIONS = elements[0].action
    gui.set_active_action(action)

func add_action_label_to_gui(gui, action) -> void:
    gui.add_action(action)

func get_player_data(player: Player) -> Dictionary:
    if player not in player_interaction_data.keys():
        printerr("FATAL: Player not found in player interaction data!")
        return {}
    return player_interaction_data[player]

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

func get_interaction_area(player: Player) -> Area3D:
    if is_instance_valid(player):
        return player.interaction_area
    return null

func get_active_interactee(player: Player):
    var player_data = get_player_data(player)
    if not "active_interactee" in player_data:
        return null
    return player_data["active_interactee"]

func get_active_action(player: Player):
    var player_data = get_player_data(player)
    if not "active_action" in player_data:
        return PlayerActions.ACTIONS.INVALID

    var action = player_data["active_action"]
    if not is_instance_valid(action):
        return PlayerActions.ACTIONS.INVALID

    return action.action
