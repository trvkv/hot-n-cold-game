extends PanelContainer

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1

@export var horizontal_item_container: HorizontalItemContainer
@export var set_items_at_start: Array[ItemBase] = []

func _ready() -> void:
    assert(is_instance_valid(horizontal_item_container), "Item container not valid")
    hide()
    EventBus.connect("action_successful", _on_action_successful)
    EventBus.connect("update_interactees", _on_update_interactees)

    horizontal_item_container.clear()
    for item in set_items_at_start:
        horizontal_item_container.add_item(item)

func handle_open_container(interaction_data: InteractionData) -> void:
    if "items" not in interaction_data.response:
        printerr("No 'items' in interaction data response")
        return

    horizontal_item_container.clear()

    var item = interaction_data.response["items"] as ItemBase
    if item != null:
        horizontal_item_container.add_item(item)

    if horizontal_item_container.size() == 0:
        horizontal_item_container.add_empty()

    show()

func handle_put_to_container(interaction_data: InteractionData) -> void:
    if 'active_item' in interaction_data.response:
        var active_item: ItemBase = interaction_data.response['active_item']
        if is_instance_valid(active_item):
            # clear contents of the container of empty elements
            # 'open_container' function adds empty element in case when
            # the container is empty.
            for element in horizontal_item_container.get_elements():
                if element.item == null:
                    horizontal_item_container.clear_element(element)

            horizontal_item_container.add_item(active_item)
            show() # show container contents after adding item

func _on_action_successful(interaction_data: InteractionData) -> void:
    if interaction_data.player_id != player_id:
        return

    if interaction_data.action == PlayerActions.ACTIONS.OPEN_CONTAINER:
        handle_open_container(interaction_data)
    elif interaction_data.action == PlayerActions.ACTIONS.PUT_TO_CONTAINER:
        handle_put_to_container(interaction_data)
    return

func _on_update_interactees(_interactor, _interactees, _active_interactee):
    horizontal_item_container.clear()
    hide()
