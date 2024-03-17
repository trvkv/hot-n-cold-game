extends Node

var players: Dictionary

enum PlayerID { PLAYER_1 = 1, PLAYER_2 = 2 }

# # # internal helper class # # #

class InputMappingBuilder:

    static func default(player_id: PlayerID) -> Dictionary:
        var map = {}
        if player_id == PlayerID.PLAYER_1:
            assert(InputMap.has_action("player_1_up"), "Action 'player_1_up' not found in input mapping")
            assert(InputMap.has_action("player_1_down"), "Action 'player_1_down' not found in input mapping")
            assert(InputMap.has_action("player_1_left"), "Action 'player_1_left' not found in input mapping")
            assert(InputMap.has_action("player_1_right"), "Action 'player_1_right' not found in input mapping")
            assert(InputMap.has_action("player_1_interact"), "Action 'player_1_interact' not found in input mapping")

            map["up"] = StringName("player_1_up")
            map["down"] = StringName("player_1_down")
            map["left"] = StringName("player_1_left")
            map["right"] = StringName("player_1_right")
            map["interact"] = StringName("player_1_interact")

        elif player_id == PlayerID.PLAYER_2:
            assert(InputMap.has_action("player_2_up"), "Action 'player_2_up' not found in input mapping")
            assert(InputMap.has_action("player_2_down"), "Action 'player_2_down' not found in input mapping")
            assert(InputMap.has_action("player_2_left"), "Action 'player_2_left' not found in input mapping")
            assert(InputMap.has_action("player_2_right"), "Action 'player_2_right' not found in input mapping")
            assert(InputMap.has_action("player_2_interact"), "Action 'player_2_interact' not found in input mapping")

            map["up"] = StringName("player_2_up")
            map["down"] = StringName("player_2_down")
            map["left"] = StringName("player_2_left")
            map["right"] = StringName("player_2_right")
            map["interact"] = StringName("player_2_interact")

        return map

class PlayerContainer:

    var player_id: PlayerID
    var player: Player
    var mapping: Dictionary = {}

    func _init(player_id_: PlayerID, player_: Player):
        player_id = player_id_
        player = player_
        mapping = InputMappingBuilder.default(player_id_)

    func get_input() -> Vector2:
        return Vector2(
            Input.get_axis(mapping["down"], mapping["up"]),
            Input.get_axis(mapping["left"], mapping["right"])
        )

    func send_action(event: InputEventAction) -> void:
        player.handle_input(event)

    func translate_event_to_action(action_name: String, event: InputEvent) -> InputEventAction:
        var action = InputEventAction.new()
        action.action = action_name.substr("player_*_".length())
        action.pressed = event.is_pressed()
        # should be fixed when Controller support will be introduced
        # action.strength = event.strength
        action.device = event.device
        return action

    func translate_and_send_input(action_name: String, event: InputEvent) -> void:
        var action: InputEventAction = translate_event_to_action(action_name, event)
        send_action(action)

# # # # # # # # # # # # # # # # #

func _ready() -> void:
    for player_id in PlayerID:
        players[player_id] = null

func add_player(player_id: PlayerID, player: Player) -> void:
    if player_id in players.keys() and players[player_id] != null:
        printerr("Player ", str(player_id), " already added as ", get_player(player_id))
        return
    players[player_id] = PlayerContainer.new(player_id, player)

func get_container(player_id: PlayerID) -> PlayerContainer:
    if player_id not in players.keys():
        return null
    return players[player_id]

func get_player(player_id: PlayerID) -> Player:
    var container: PlayerContainer = get_container(player_id)
    if container == null:
        return null
    return container.player

func get_players() -> Array[Player]:
    var all_players: Array[Player] = []
    for player_id in PlayerID:
        all_players.append(get_player(PlayerID[player_id]))
    return all_players

func get_player_name(player_id: PlayerID) -> String:
    if player_id == PlayerID.PLAYER_1:
        return "Player 1"
    elif player_id == PlayerID.PLAYER_2:
        return "Player 2"
    return "Unknown"

func get_input(player_id: PlayerID) -> Vector2:
    var container: PlayerContainer = get_container(player_id)
    if container == null:
        return Vector2.ZERO
    return container.get_input()

func find_associated_action(event: InputEvent) -> String:
    var detected_action: String = ""
    for action in InputMap.get_actions():
        if InputMap.event_is_action(event, action):
            detected_action = action
    return detected_action

func _unhandled_input(event: InputEvent) -> void:
    # ignore mouse input
    if event as InputEventMouseButton:
        return
    if event as InputEventMouseMotion:
        return

    # find which action was made
    var action_name: String = find_associated_action(event)
    if action_name.is_empty():
        return

    # figure out which player made an action
    var container = null

    if action_name.begins_with("player_1"):
        container = get_container(PlayerID.PLAYER_1)
    elif action_name.begins_with("player_2"):
        container = get_container(PlayerID.PLAYER_2)

    if container == null:
        return

    container.translate_and_send_input(action_name, event)
