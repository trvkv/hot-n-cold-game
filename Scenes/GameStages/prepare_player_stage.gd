extends GameStage

class_name PreparePlayerGameStage

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1
@export var starting_items: Array[ItemBase]

var stored_items: Array = []
var locked_items: Array = []

func _init():
    super("Prepare player %d" % player_id)

func enter() -> void:
    super()
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
    EventBus.disconnect("action_successful", _on_action_successful)
    call_function("show_player_container", [PlayersManager.get_opponent_id(player_id)])
    call_function("freeze", [PlayersManager.get_opponent_id(player_id), false])
    call_function("set_player_inventory", [player_id, []])

func retrieve_player_game_data(data_type: GameStateTypes.TYPES) -> Array[StringName]:
    var game_state = GameStateTypes.GameStateData.new(player_id, data_type)
    EventBus.emit_signal("retrieve_game_state", game_state)
    if game_state.data == null:
        return []
    return game_state.data

func validate_preparation() -> void:
    # check if favourite item is placed in a container
    var favourite_placed_correctly: bool = false
    for item: GameStateTypes.GameStateItem in stored_items:
        if item.item.get_class_name() == &"ItemFavourite":
            if is_instance_valid(item.container):
                favourite_placed_correctly = true

    # check if every used key is placed in a container
    # as opponent must be able to find it :)
    # here, the algorithm will check for a negative case (will set 'false'
    # when at least one key won't be found in some container
    var keys_placed_correctly: bool = false
    for locked_item in locked_items:
        print(" -- Key: ", locked_item.item, " (", locked_item.item.get_class_name(),")")
        for stored_item in stored_items:
             keys_placed_correctly = keys_placed_correctly || (stored_item.item == locked_item.item)

    print("FAVOURITE PLACED CORRECTLY? ", favourite_placed_correctly)
    print("KEYS PLACED CORRECTLY? ", keys_placed_correctly)

func handle_action_put_to_container(interaction_data: InteractionData) -> void:
    if "active_item" in interaction_data.response:
        var active_item: ItemBase = interaction_data.response["active_item"]
        stored_items.append(GameStateTypes.GameStateItem.new(active_item, interaction_data.target))
    validate_preparation()

func handle_action_lock_container(interaction_data: InteractionData) -> void:
    if "active_item" in interaction_data.response:
        var active_item: ItemBase = interaction_data.response["active_item"]
        locked_items.append(GameStateTypes.GameStateItem.new(active_item, interaction_data.target))
    validate_preparation()

func _on_action_successful(interaction_data: InteractionData) -> void:
    if not is_instance_valid(interaction_data):
        printerr("Interaction data is invalid!")
        return
    var action := PlayerActions.action_to_string(interaction_data.action)
    print("--[ACTION]-------------------------------------------------------\n",
        "\t\t-- Player: ", interaction_data.initiator, "\n",
        "\t\t-- Action: ", action, " (", interaction_data.action, ")\n",
        "\t\t-- Target: ", interaction_data.target, "\n",
        "\t\t-- Req.: ", interaction_data.request, "\n",
        "\t\t-- Res.: ", interaction_data.response, "\n",
        "------------------------------------------------------------------"
    )
    if interaction_data.action == PlayerActions.ACTIONS.PUT_TO_CONTAINER:
        handle_action_put_to_container(interaction_data)
    elif interaction_data.action == PlayerActions.ACTIONS.LOCK_CONTAINER:
        handle_action_lock_container(interaction_data)
