extends Node

var players: Dictionary

enum PlayerID { PLAYER_1 = 1, PLAYER_2 = 2 }

# # # internal helper class # # #

class InputMapping:
    var valid: bool = false
    var up: String
    var down: String
    var left: String
    var right: String

    static func default(player_id: PlayerID) -> InputMapping:
        if player_id == PlayerID.PLAYER_1:
            assert(InputMap.has_action("player_1_up"), "Action 'player_1_up' not found in input mapping")
            assert(InputMap.has_action("player_1_down"), "Action 'player_1_down' not found in input mapping")
            assert(InputMap.has_action("player_1_left"), "Action 'player_1_left' not found in input mapping")
            assert(InputMap.has_action("player_1_right"), "Action 'player_1_right' not found in input mapping")

            var map = InputMapping.new()
            map.valid = true

            map.up = StringName("player_1_up")
            map.down = StringName("player_1_down")
            map.left = StringName("player_1_left")
            map.right = StringName("player_1_right")

            return map

        elif player_id == PlayerID.PLAYER_2:
            assert(InputMap.has_action("player_2_up"), "Action 'player_2_up' not found in input mapping")
            assert(InputMap.has_action("player_2_down"), "Action 'player_2_down' not found in input mapping")
            assert(InputMap.has_action("player_2_left"), "Action 'player_2_left' not found in input mapping")
            assert(InputMap.has_action("player_2_right"), "Action 'player_2_right' not found in input mapping")

            var map = InputMapping.new()
            map.valid = true

            map.up = StringName("player_2_up")
            map.down = StringName("player_2_down")
            map.left = StringName("player_2_left")
            map.right = StringName("player_2_right")

            return map

        return InputMapping.new()

class PlayerContainer:

    var player_id: PlayerID
    var player: Player
    var mapping: InputMapping

    func _init(player_id_: PlayerID, player_: Player):
        player_id = player_id_
        player = player_
        mapping = InputMapping.default(player_id_)

    func get_input() -> Vector2:
        return Vector2(Input.get_axis(mapping.down, mapping.up), Input.get_axis(mapping.left, mapping.right))

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

func get_input(player_id: PlayerID) -> Vector2:
    var container: PlayerContainer = get_container(player_id)
    if container == null:
        return Vector2.ZERO
    return container.get_input()
