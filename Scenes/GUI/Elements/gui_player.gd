extends PanelContainer

class_name GuiPlayer

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1
@export var label_player_name: Label

@export var position_label_value: Label
@export var rotation_label_value: Label
@export var hotcold_ready_label_value: Label
@export var hotcold_distance_label_value: Label

@export var horizontal_item_container: HorizontalItemContainer
@export var set_items_at_start: Array[ItemBase] = []

func _ready() -> void:
    assert(is_instance_valid(label_player_name), "L_player_name label not found")
    assert(is_instance_valid(horizontal_item_container), "Item container not found")
    assert(is_instance_valid(rotation_label_value), "Rotation label not found")
    assert(is_instance_valid(hotcold_ready_label_value), "Hot/cold ready label not found")
    assert(is_instance_valid(hotcold_distance_label_value), "Hot/cold distance label not found")

    label_player_name.set_text(PlayersManager.get_player_name(player_id))

    set_items(set_items_at_start, true)

    EventBus.connect("switch_item", _on_switch_item)
    EventBus.connect("action_successful", _on_action_successful)
    EventBus.connect("query_ready", _on_query_ready)
    EventBus.connect("distance_updated", _on_distance_updated)

func _process(_delta: float) -> void:
    var player: Player = PlayersManager.get_player(player_id)
    if not is_instance_valid(player):
        return

    position_label_value.set_text("%0.1f, %0.1f, %0.1f" % [
        player.get_position().x,
        player.get_position().y,
        player.get_position().z
    ])
    rotation_label_value.set_text(str(player.get_rotation_degrees()))

func _on_query_ready(player) -> void:
    if player == PlayersManager.get_player(player_id):
        hotcold_ready_label_value.set_text("YES!")

func _on_distance_updated(player: Player, distance: float) -> void:
    if player == PlayersManager.get_player(player_id):
        hotcold_ready_label_value.set_text("no..:(")
        hotcold_distance_label_value.set_text("(%s)" % distance_to_hotcold_string(distance))

func _on_switch_item(player: Player):
    if player == PlayersManager.get_player(player_id):
        var next: ItemElement = horizontal_item_container.get_next_element_by_active()
        var item: ItemBase = next.item if is_instance_valid(next) else null
        horizontal_item_container.set_active_by_element(next)
        EventBus.emit_signal("update_items", player, horizontal_item_container.get_items(), item)

func _on_action_successful(interaction_data: InteractionData) -> void:
    if interaction_data.player_id != player_id:
        return

    if interaction_data.action == PlayerActions.ACTIONS.PUT_TO_CONTAINER:
        if 'active_item' in interaction_data.response:
            var active_item: ItemBase = interaction_data.response['active_item']
            if not horizontal_item_container.clear_item(active_item):
                printerr("Cannot clear active item: ", active_item, ", on player ", player_id)
    elif interaction_data.action == PlayerActions.ACTIONS.GET_FROM_CONTAINER:
        if 'item' in interaction_data.response:
            var item: ItemBase = interaction_data.response['item']
            if is_instance_valid(item):
                horizontal_item_container.add_item(item)
            else:
                printerr("Item instance invalid: ", item, " on player ", player_id)
        else:
            printerr("'item' field not found in interaction data response for player ", player_id)
    elif interaction_data.action == PlayerActions.ACTIONS.SET_TRAP:
        var active_element = horizontal_item_container.get_active_element()
        assert(is_instance_valid(active_element.item), "Critical: item invalid!")
        if active_element.item.get_class_name() == &"ItemTrap":
            var next = horizontal_item_container.get_next_element_by_active()
            horizontal_item_container.clear_element(active_element)
            horizontal_item_container.set_active_by_element(next)
            EventBus.emit_signal(
                "update_items",
                interaction_data.initiator,
                horizontal_item_container.get_items(),
                next.item
            )

func distance_to_hotcold_string(distance: float) -> String:
    if distance < 3.0:
        return "HOT! =D"
    elif distance < 7.0:
        return "Warm"
    elif distance < 10.0:
        return "Cold"
    return "FREEZING x("

func set_items(items: Array[ItemBase], clear: bool = false) -> void:
    if clear:
        horizontal_item_container.clear()
    for item in items:
        horizontal_item_container.add_item(item)
