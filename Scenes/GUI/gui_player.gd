extends PanelContainer

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1
@export var label_player_name: Label

@export var position_label_value: Label
@export var rotation_label_value: Label

@export var horizontal_item_container: HorizontalItemContainer
@export var set_items_at_start: Array[ItemBase] = []

func _ready() -> void:
    assert(is_instance_valid(label_player_name), "L_player_name label not found")
    assert(is_instance_valid(horizontal_item_container), "Item container not found")
    assert(is_instance_valid(rotation_label_value), "Rotation label not found")

    label_player_name.set_text(PlayersManager.get_player_name(player_id))

    horizontal_item_container.clear()
    for item in set_items_at_start:
        horizontal_item_container.add_item(item)

    EventBus.connect("switch_item", _on_switch_item)

func _process(_delta: float) -> void:
    var player: Player = PlayersManager.get_player(player_id)
    position_label_value.set_text("%0.1f, %0.1f, %0.1f" % [
        player.get_position().x,
        player.get_position().y,
        player.get_position().z
    ])
    rotation_label_value.set_text(str(player.get_rotation_degrees()))

func _on_switch_item(player: Player):
    if player == PlayersManager.get_player(player_id):
        var next: ItemElement = horizontal_item_container.get_next_element_by_active()
        var item: ItemBase = next.item if is_instance_valid(next) else null
        horizontal_item_container.set_active_by_element(next)
        EventBus.emit_signal("update_items", player, horizontal_item_container.get_items(), item)
