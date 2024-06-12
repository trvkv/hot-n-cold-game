extends Node

var game_state = {}

func _ready() -> void:
    EventBus.connect("store_game_state", _on_store_game_state)
    EventBus.connect("retrieve_game_state", _on_retrieve_game_state)

func assure_player_is_in_game_state(player_id: int) -> void:
    assert(player_id in PlayersManager.PlayerID.values(), "Player is invalid")
    if not game_state.has(player_id):
        game_state[player_id] = {}
        for data_type in GameStateTypes.TYPES:
            var t: int = GameStateTypes.TYPES[data_type]
            game_state[player_id][t] = GameStateTypes.create_type(t)
    assert(game_state.has(player_id), "CRITICAL: Player not added successfully!")

func _on_store_game_state(state: GameStateTypes.GameStateData) -> void:
    if not is_instance_valid(state):
        printerr("Passed state object is invalid")
        return
    assure_player_is_in_game_state(state.player_id)
    print("Storing data | Player: ", state.player_id, " | Type: ", state.data_type, " | '", state.data, "'")
    game_state[state.player_id][state.data_type] = state.data
    EventBus.emit_signal("game_state_updated", state)

func _on_retrieve_game_state(state: GameStateTypes.GameStateData) -> void:
    if not is_instance_valid(state):
        printerr("Passed state object is invalid")
        return
    assure_player_is_in_game_state(state.player_id)
    state.data = game_state[state.player_id][state.data_type]
