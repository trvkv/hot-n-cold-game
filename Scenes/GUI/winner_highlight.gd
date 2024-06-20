extends MenuScreen

@export var winner_label: Label
@export var finalize: Button

func _ready() -> void:
    assert(finalize, "New game button not found")
    finalize.connect("pressed", _on_pressed_finalize)

    var state := GameStateTypes.GameStateData.new(PlayersManager.PlayerID.PLAYER_1, GameStateTypes.TYPES.WINNER)
    EventBus.emit_signal("retrieve_game_state", state)
    if state.data != null:
        winner_label.set_text("THE WINNER IS PLAYER 1")

    state = GameStateTypes.GameStateData.new(PlayersManager.PlayerID.PLAYER_2, GameStateTypes.TYPES.WINNER)
    EventBus.emit_signal("retrieve_game_state", state)
    if state.data != null:
        winner_label.set_text("THE WINNER IS PLAYER 2")

func _on_pressed_finalize() -> void:
    load_next()
