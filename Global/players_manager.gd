extends Node

var players: Dictionary

enum PlayerID { NONE = 0, PLAYER_1 = 1, PLAYER_2 = 2 }

# # # internal helper class # # #

class PlayerContainer:

    var player_id: PlayerID
    var player: Player

    func _init(player_id_: PlayerID, player_: Player):
        player_id = player_id_
        player = player_

# # # # # # # # # # # # # # # # #

func _ready() -> void:
    for player_id in PlayerID:
        players[player_id] = null

func add_player(player_id: PlayerID, player: Player) -> void:
    if player_id in players.keys() and players[player_id] != null:
        printerr("Player ", str(player_id), " already added as ", get_player(player_id))
        return
    players[player_id] = PlayerContainer.new(player_id, player)

func remove_player(player_id: PlayerID) -> void:
    if player_id not in players.keys():
        printerr("Player ", str(player_id), " not present in manager")
        return
    players.erase(player_id)

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

func get_opponent_id(player_id: PlayerID) -> PlayerID:
    if player_id == PlayerID.PLAYER_1:
        return PlayerID.PLAYER_2
    return PlayerID.PLAYER_1

func get_opponent(player: Player) -> Player:
    var opponent_id = get_opponent_id(player.player_id)
    return get_player(opponent_id)
