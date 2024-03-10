extends Panel

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1
@export var label_player_name: Label
@export var item_container: HorizontalItemContainer

func _ready() -> void:
    assert(is_instance_valid(label_player_name), "L_player_name label not found")
    assert(is_instance_valid(item_container), "Item container not found")
    label_player_name.set_text(PlayersManager.get_player_name(player_id))

    EventBus.connect("switch_item", _on_switch_item)

func _on_switch_item(player: Player):
    if player == PlayersManager.get_player(player_id):
        var next: ItemElement = item_container.get_next_element_by_active()
        item_container.set_active_by_element(next)
