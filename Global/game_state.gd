extends Node

var game_state = {}

func _ready() -> void:
    EventBus.connect("store_game_state", _on_store_game_state)
    EventBus.connect("retrieve_game_state", _on_retrieve_game_state)

func assure_player_is_in_game_state(player) -> void:
    assert(is_instance_valid(player), "Player is invalid")
    if not game_state.has(player):
        game_state[player] = {}
        for data_type in GameStateTypes.TYPES:
            game_state[player][GameStateTypes.TYPES[data_type]] = null
    assert(game_state.has(player), "CRITICAL: Player not added successfully!")

func _on_store_game_state(state: GameStateTypes.GameStateData) -> void:
    if not is_instance_valid(state):
        printerr("Passed state object is invalid")
        return
    assure_player_is_in_game_state(state.player)
    if state.data_type not in game_state[state.player]:
        printerr("Cannot store: type ", state.data_type, " not found in GameState for ", state.player)
        printerr("   ** State: ", game_state[state.player])
        return
    game_state[state.player][state.data_type] = state.data

func _on_retrieve_game_state(state: GameStateTypes.GameStateData) -> void:
    if state.player not in game_state:
        printerr("Cannot retrieve: player ", state.player, " not found in GameState")
        return
    if state.data_type not in game_state[state.player]:
        printerr("Cannot retrieve: data type ", state.data_type, " not found in player's ", state.player, " GameState")
        printerr("   ** State: ", game_state[state.player])
        return
    state.data = game_state[state.player][state.data_type]
