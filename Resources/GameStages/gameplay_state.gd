extends GameStage

class_name GameplayStage

var new_stage_wait_time: float = 5.0
var time_elapsed: float = 0.0
var load_new_stage: bool = false

var favourite_item_obtained: Dictionary = {}
var starting_position_reached: Dictionary = {}

func _init():
    super("Gameplay stage")

func enter() -> void:
    super()
    EventBus.connect("action_successful", _on_action_successful)
    EventBus.connect("starting_position_reached", _on_starting_position_reached)

func exit() -> void:
    super()
    EventBus.disconnect("action_successful", _on_action_successful)
    EventBus.disconnect("starting_position_reached", _on_starting_position_reached)

func update(delta) -> void:
    if load_new_stage:
        time_elapsed += delta
        if time_elapsed > new_stage_wait_time:
            load_new_stage = false
            call_function("load_next")

func set_player_win(player_id: PlayersManager.PlayerID) -> void:
    if load_new_stage: # after requesting new stage, do not check win conditions
        return
    call_function("set_information_message", [player_id, "Winner winner chicken dinner!"])
    load_new_stage = true
    # store winner id
    var state := GameStateTypes.GameStateData.new(player_id, GameStateTypes.TYPES.WINNER, player_id)
    EventBus.emit_signal("store_game_state", state)

func check_win_conditions(player_id: PlayersManager.PlayerID) -> void:
    if not favourite_item_obtained.has(player_id):
        return
    if favourite_item_obtained[player_id] == false:
        return
    if not starting_position_reached.has(player_id):
        return
    if starting_position_reached[player_id] == false:
        return
    set_player_win(player_id)

func _on_starting_position_reached(player_id: PlayersManager.PlayerID, reached: bool) -> void:
    starting_position_reached[player_id] = reached
    if reached:
        call_function("set_information_message", [player_id, "Starting position reached!"])
    check_win_conditions(player_id)

func _on_action_successful(interaction_data: InteractionData) -> void:
    if interaction_data.action != PlayerActions.ACTIONS.GET_FROM_CONTAINER:
        return

    if not interaction_data.response is Dictionary:
        printerr("FATAL: Response is not a dictionary!")
        return
    if not interaction_data.response.has("item"):
        printerr("FATAL: Response is invalid, 'active_item' key not present in: ", interaction_data.response)
        return

    var active_item: ItemBase = interaction_data.response["item"]
    if not is_instance_valid(active_item):
        printerr("Active item instance not valid")
        return

    if active_item.get_class_name() != &"ItemFavourite":
        return

    if interaction_data.player_id != active_item.player_id:
        favourite_item_obtained[interaction_data.player_id] = true
        call_function("set_information_message", [interaction_data.player_id, "Opponents favourite item obtained!!!"])
        call_function("set_requirement_message", [interaction_data.player_id, "NOW GO TO YOUR STARTING POSITION!"])
        check_win_conditions(interaction_data.player_id)
    else:
        printerr("Own item picked up? WTF! Got a bug somewhere.")
