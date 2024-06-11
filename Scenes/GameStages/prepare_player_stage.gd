extends GameStage

class_name PreparePlayerGameStage

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1

func _init():
    super("Prepare player %d" % player_id)

func enter() -> void:
    super()
    call_function("hide_player_container", [PlayersManager.get_opponent_id(player_id)])
    call_function("freeze", [PlayersManager.get_opponent_id(player_id), true])

func exit() -> void:
    super()
    call_function("show_player_container", [PlayersManager.get_opponent_id(player_id)])
    call_function("freeze", [PlayersManager.get_opponent_id(player_id), false])

func update(_delta: float) -> void:
    pass
