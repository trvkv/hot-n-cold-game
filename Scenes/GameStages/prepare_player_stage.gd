extends GameStage

class_name PreparePlayerGameStage

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1

func _init():
    super("Prepare player %d" % player_id)
    EventBus.connect("game_state_updated", _on_game_state_updated)

func enter() -> void:
    super()
    call_function("hide_player_container", [PlayersManager.get_opponent_id(player_id)])
    call_function("freeze", [PlayersManager.get_opponent_id(player_id), true])

    var items = retrieve_player_game_data(GameStateTypes.TYPES.CHOSEN_ITEMS)
    call_function("set_player_inventory", [player_id, items])

func exit() -> void:
    super()
    call_function("show_player_container", [PlayersManager.get_opponent_id(player_id)])
    call_function("freeze", [PlayersManager.get_opponent_id(player_id), false])
    call_function("set_player_inventory", [player_id, []])

func update(_delta: float) -> void:
    pass

func retrieve_player_game_data(data_type: GameStateTypes.TYPES) -> Array[StringName]:
    var game_state = GameStateTypes.GameStateData.new(player_id, data_type)
    EventBus.emit_signal("retrieve_game_state", game_state)
    if game_state.data == null:
        return []
    return game_state.data

func _on_game_state_updated(state_data: GameStateTypes.GameStateData) -> void:
    if not state_data.player_id == player_id:
        return
