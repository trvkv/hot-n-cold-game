extends PanelContainer

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1
@export var item_container: HorizontalItemContainer

func _ready() -> void:
    assert(is_instance_valid(item_container), "Item container not valid")
    hide()
    EventBus.connect("action_successful", _on_action_successful)
    EventBus.connect("update_interactees", _on_update_interactees)

func _on_action_successful(interactor, _interactee, action, custom_data) -> void:
    if action != PlayerActions.ACTIONS.OPEN_CONTAINER:
        return

    var player = PlayersManager.get_player(player_id)
    if interactor != player:
        return

    var items = custom_data as Array
    if items == null:
        return

    item_container.items = items
    item_container.reload_items()

    show()

func _on_update_interactees(_interactor, _interactees, _active_interactee):
    hide()
