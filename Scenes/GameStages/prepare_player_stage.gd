extends GameStage

class_name PreparePlayerGameStage

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1
@export var starting_items: Array[ItemBase]

var favourite_item_container: ItemContainer = null

func _init():
    super("Prepare player %d" % player_id)

func enter() -> void:
    super()
    EventBus.connect("game_state_updated", _on_game_state_updated)
    EventBus.connect("action_successful", _on_action_successful)
    call_function("hide_player_container", [PlayersManager.get_opponent_id(player_id)])
    call_function("freeze", [PlayersManager.get_opponent_id(player_id), true])

    var items = retrieve_player_game_data(GameStateTypes.TYPES.CHOSEN_ITEMS)
    if items.size() == 0:
        for item in starting_items:
            items.append(item.get_class_name())
    print("Starting items: ", items)
    call_function("set_player_inventory", [player_id, items])

func exit() -> void:
    super()
    EventBus.disconnect("game_state_updated", _on_game_state_updated)
    call_function("show_player_container", [PlayersManager.get_opponent_id(player_id)])
    call_function("freeze", [PlayersManager.get_opponent_id(player_id), false])
    call_function("set_player_inventory", [player_id, []])

func retrieve_player_game_data(data_type: GameStateTypes.TYPES) -> Array[StringName]:
    var game_state = GameStateTypes.GameStateData.new(player_id, data_type)
    EventBus.emit_signal("retrieve_game_state", game_state)
    if game_state.data == null:
        return []
    return game_state.data

func _on_game_state_updated(state_data: GameStateTypes.GameStateData) -> void:
    if not state_data.player_id == player_id:
        return
    if state_data.data_type == GameStateTypes.TYPES.FAVOURITE_ITEM_CONTAINER:
        favourite_item_container = state_data.data
        print("Favourite item stored in ", favourite_item_container)

func _on_action_successful(interaction_data: InteractionData) -> void:
    var action := PlayerActions.action_to_string(interaction_data.action)
    print("Got successful action ", interaction_data.initiator, " | ", action)
