extends PanelContainer

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1
@export var label_player_name: Label
@export var item_container: HorizontalItemContainer

@export var position_label_value: Label
@export var rotation_label_value: Label

func _ready() -> void:
    assert(is_instance_valid(label_player_name), "L_player_name label not found")
    assert(is_instance_valid(item_container), "Item container not found")
    assert(is_instance_valid(rotation_label_value), "Rotation label not found")

    label_player_name.set_text(PlayersManager.get_player_name(player_id))

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
        var next: ItemElement = item_container.get_next_element_by_active()
        item_container.set_active_by_element(next)
        EventBus.emit_signal("update_items", player, item_container.items, next.item)
