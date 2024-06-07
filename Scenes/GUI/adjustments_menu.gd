extends MenuScreen

class_name AdjustmentsMenu

@export var panel_p1: AdjustmentsPanel
@export var panel_p2: AdjustmentsPanel

var players = {
    PlayersManager.PlayerID.PLAYER_1: false,
    PlayersManager.PlayerID.PLAYER_2: false
}

func _ready() -> void:
    assert(is_instance_valid(panel_p1), "Panel P1 is not valid")
    assert(is_instance_valid(panel_p2), "Panel P2 is not valid")
    panel_p1.connect("player_ready", _on_player_ready)
    panel_p2.connect("player_ready", _on_player_ready)

func _on_player_ready(player_id: int) -> void:
    if player_id in players.keys():
        print("Player ready: ", player_id)
        players[player_id] = true

    if players_ready():
        print("Loading next scene...")
        load_next(next_scene)

func players_ready() -> bool:
    for player in players:
        if players[player] == false:
            return false
    return true
