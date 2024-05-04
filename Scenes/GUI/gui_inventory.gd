extends PanelContainer

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1
@export var horizontal_item_container: HorizontalItemContainer

func _ready() -> void:
    assert(is_instance_valid(horizontal_item_container), "Item container not valid")
    hide()
    EventBus.connect("action_successful", _on_action_successful)
    EventBus.connect("update_interactees", _on_update_interactees)

func _on_action_successful(interaction_data: InteractionData) -> void:
    if interaction_data.action != PlayerActions.ACTIONS.OPEN_CONTAINER:
        return

    var player = PlayersManager.get_player(player_id)
    if interaction_data.initiator != player:
        return

    if not "items" in interaction_data.response:
        printerr("No 'items' in interaction data response")
        return

    var items = interaction_data.response["items"] as Array
    if items == null:
        return

    horizontal_item_container.items = items
    horizontal_item_container.reload_items()

    if horizontal_item_container.items.size() == 0:
        horizontal_item_container.add_empty()

    show()

func _on_update_interactees(_interactor, _interactees, _active_interactee):
    hide()
