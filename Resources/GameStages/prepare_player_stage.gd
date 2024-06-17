extends GameStage

class_name PreparePlayerGameStage

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1
@export var starting_items: Array[ItemBase]

@export var debug: bool = false

var stored_items: Array = []
var locked_items: Array = []

var favourite_placed_correctly: bool = false
var keys_placed_correctly: bool = false

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

    var opponent: Player = PlayersManager.get_opponent(player_id)
    opponent.hide()
    update_user_message()

    call_function("set_player_starting_position", [player_id])
    call_function("set_player_starting_position", [PlayersManager.get_opponent_id(player_id)])

func exit() -> void:
    super()
    EventBus.disconnect("action_successful", _on_action_successful)
    call_function("show_player_container", [PlayersManager.get_opponent_id(player_id)])
    call_function("freeze", [PlayersManager.get_opponent_id(player_id), false])
    call_function("set_player_inventory", [player_id, []])
    call_function("set_ready_button", [player_id, false])
    call_function("set_message", [player_id, ""])

    var opponent: Player = PlayersManager.get_opponent(player_id)
    opponent.show()

    call_function("set_player_starting_position", [player_id])
    call_function("set_player_starting_position", [PlayersManager.get_opponent_id(player_id)])

func retrieve_player_game_data(data_type: GameStateTypes.TYPES) -> Array[StringName]:
    var game_state = GameStateTypes.GameStateData.new(player_id, data_type)
    EventBus.emit_signal("retrieve_game_state", game_state)
    if game_state.data == null:
        return []
    return game_state.data

func validate_preparation() -> void:
    # check if favourite item is placed in a container
    favourite_placed_correctly = false
    for item: GameStateTypes.GameStateItem in stored_items:
        if item.item.get_class_name() == &"ItemFavourite":
            if is_instance_valid(item.container):
                favourite_placed_correctly = true

    # check if every used key is placed in a container
    # as opponent must be able to find it :)
    # here, the algorithm will check for a negative case (will set 'false'
    # when at least one key won't be found in some container
    keys_placed_correctly = false

    if locked_items.size() > 0:
        for locked_item in locked_items:
            for stored_item in stored_items:
                keys_placed_correctly = keys_placed_correctly || (stored_item.item == locked_item.item)
    else:
        keys_placed_correctly = true

func update_user_message() -> void:
    var message: String = ""
    if not favourite_placed_correctly:
        message += "* Favourite item not placed in a container\n"

    if not keys_placed_correctly:
        message += "* Keys not placed correctly. Each key which\n"
        message += "  was used for locking, should be placed in\n"
        message += "  a container"

    if favourite_placed_correctly and keys_placed_correctly:
        message = "Preparation finished! Click ready button below."

    call_function("set_message", [player_id, message])

func update_ready_button() -> void:
    if favourite_placed_correctly and keys_placed_correctly:
        call_function("set_ready_button", [player_id, true])
    else:
        call_function("set_ready_button", [player_id, false])

func handle_action_put_to_container(interaction_data: InteractionData) -> void:
    if "active_item" in interaction_data.response:
        var active_item: ItemBase = interaction_data.response["active_item"]
        stored_items.append(GameStateTypes.GameStateItem.new(active_item, interaction_data.target))
    validate_preparation()
    update_user_message()
    update_ready_button()

func handle_action_lock_container(interaction_data: InteractionData) -> void:
    if "active_item" in interaction_data.response:
        var active_item: ItemBase = interaction_data.response["active_item"]
        locked_items.append(GameStateTypes.GameStateItem.new(active_item, interaction_data.target))
    validate_preparation()
    update_user_message()
    update_ready_button()

func _on_action_successful(interaction_data: InteractionData) -> void:
    if not is_instance_valid(interaction_data):
        printerr("Interaction data is invalid!")
        return
    var action := PlayerActions.action_to_string(interaction_data.action)
    if debug:
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
