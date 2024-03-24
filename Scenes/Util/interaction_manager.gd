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

func _on_update_interactees(player, interactees, active_interactee) -> void:
    if player not in player_interaction_data.keys():
        printerr("FATAL: Player not found in player interaction data!")
        return

    player_interaction_data[player]["interactees"] = interactees
    player_interaction_data[player]["active_interactee"] = active_interactee

    var gui = get_interaction_gui(player)
    if not is_instance_valid(gui):
        printerr("Interaction gui for %s is invalid" % PlayersManager.get_player_name(player.player_id))
        return

    # resetting players gui
    for child in gui.get_children():
        gui.remove_child(child)
        child.queue_free()

    if is_instance_valid(active_interactee):
        # TODO: for active interactee gather possible actions
        # and print them as strings in the gui.
        pass

    for interactee in player_interaction_data[player]["interactees"]:
        var label = Label.new()
        label.set_text(str(interactee))
        gui.add_child(label)

func get_interaction_gui(player: Player) -> Control:
    if player.player_id == PlayersManager.PlayerID.PLAYER_1:
        return player_1_interaction_gui
    elif player.player_id == PlayersManager.PlayerID.PLAYER_2:
        return player_2_interaction_gui
    printerr("Wrong player given... (", player, ")")
    return null
