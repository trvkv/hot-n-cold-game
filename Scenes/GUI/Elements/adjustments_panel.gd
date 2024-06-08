extends PanelContainer

class_name AdjustmentsPanel

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1
@export var title_label: Label
@export var message_label: Label
@export var proceed_button: Button

@export var chosen_items: HorizontalItemContainer

signal player_ready(player_id)
signal player_error(player_id, message)

func _ready() -> void:
    assert(is_instance_valid(title_label), "Title label invalid")
    assert(is_instance_valid(message_label), "Message label invalid")
    assert(is_instance_valid(proceed_button), "Proceed button invalid")
    proceed_button.connect("pressed", _on_pressed)
    title_label.set_text(PlayersManager.get_player_name(player_id))

func _on_pressed() -> void:
    var result: GuiResult = check_ready_conditions()
    if result.status == OK:
        emit_signal("player_ready", player_id)
        message_label.set_text("READY!")
        message_label.self_modulate = Color(0.0, 1.0, 0.0)
        proceed_button.set_modulate(Color(0.0, 1.0, 0.0))
    else:
        emit_signal("player_error", player_id, result.message)
        message_label.set_text(result.message)
        message_label.self_modulate = Color(1.0, 0.0, 0.0)

func count_item_types(items: Array[ItemBase], item_type: StringName) -> int:
    var count: int = 0
    for item in items:
        if is_instance_valid(item):
            if item.get_class_name() == item_type:
                count += 1
    return count

func check_ready_conditions() -> GuiResult:
    var items: Array = chosen_items.get_items()
    var favourite_count: int = count_item_types(items, &"ItemFavourite")
    if favourite_count == 1:
        return GuiResult.new(OK) # correct!
    if favourite_count > 0:
        GuiResult.new(FAILED, "Too much favourite items chosen! Only a single one should be added")
    return GuiResult.new(FAILED, "Please choose single favourite item!")
