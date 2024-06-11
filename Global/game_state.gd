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
            game_state[player_id][GameStateTypes.TYPES[data_type]] = null
    assert(game_state.has(player_id), "CRITICAL: Player not added successfully!")

func _on_store_game_state(state: GameStateTypes.GameStateData) -> void:
    if not is_instance_valid(state):
        printerr("Passed state object is invalid")
        return
    assure_player_is_in_game_state(state.player_id)
    if state.data_type not in game_state[state.player_id]:
        printerr("Cannot store: type ", state.data_type, " not found in GameState for ", state.player_id)
        printerr("   ** State: ", game_state[state.player_id])
        return
    print("Storing data | Player: ", state.player_id, " | Type: ", state.data_type, " | '", state.data, "'")
    game_state[state.player_id][state.data_type] = state.data

func _on_retrieve_game_state(state: GameStateTypes.GameStateData) -> void:
    if state.player_id not in game_state:
        printerr("Cannot retrieve: player ", state.player_id, " not found in GameState")
        return
    if state.data_type not in game_state[state.player_id]:
        printerr("Cannot retrieve: data type ", state.data_type, " not found in player's ", state.player_id, " GameState")
        printerr("   ** State: ", game_state[state.player_id])
        return
    state.data = game_state[state.player_id][state.data_type]
