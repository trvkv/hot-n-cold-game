extends GameStage

class_name GameplayStage

func _init():
    super("Gameplay stage")

func enter() -> void:
    super()
    EventBus.connect("action_successful", _on_action_successful)

func exit() -> void:
    super()
    EventBus.disconnect("action_successful", _on_action_successful)

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
        printerr("Found item is not favourite! :) it's: ", active_item.get_class_name())
        return

    if interaction_data.player_id != active_item.player_id:
        print("Winner winner chicken dinner: Player ", interaction_data.player_id)
    else:
        printerr("Own item picked up? WTF! Got a bug somewhere.")
