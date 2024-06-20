extends GameStage

class_name GameplayStage

var new_stage_wait_time: float = 5.0
var time_elapsed: float = 0.0
var load_new_stage: bool = false

func _init():
    super("Gameplay stage")

func enter() -> void:
    super()
    EventBus.connect("action_successful", _on_action_successful)

func exit() -> void:
    super()
    EventBus.disconnect("action_successful", _on_action_successful)

func update(delta) -> void:
    if load_new_stage:
        time_elapsed += delta
        if time_elapsed > new_stage_wait_time:
            call_function("load_next_game_stage")

func _on_action_successful(interaction_data: InteractionData) -> void:
    if load_new_stage: # after requesting new stage, do not check win conditions
        return

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
        call_function("set_information_message", [interaction_data.player_id, "Winner winner chicken dinner!"])
        load_new_stage = true
    else:
        printerr("Own item picked up? WTF! Got a bug somewhere.")
