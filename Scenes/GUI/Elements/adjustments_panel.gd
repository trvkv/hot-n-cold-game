extends PanelContainer

class_name AdjustmentsPanel

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1
@export var title_label: Label
@export var message_label: Label
@export var proceed_button_margin: MarginContainer
@export var proceed_button: Button

@export var chosen_items: HorizontalItemContainer
@export var all_items: HorizontalItemContainer
@export var adjusement_input: AdjustmentInputComponent

signal player_ready(player_id)
signal player_error(player_id, message)

func _ready() -> void:
    assert(is_instance_valid(title_label), "Title label invalid")
    assert(is_instance_valid(message_label), "Message label invalid")
    assert(is_instance_valid(proceed_button_margin), "Proceed button margin invalid")
    assert(is_instance_valid(proceed_button), "Proceed button invalid")
    assert(is_instance_valid(adjusement_input), "adjusement input component invalid")

    adjusement_input.connect("switch_item", _on_switch_item)
    adjusement_input.connect("choose_item", _on_choose_item)

    proceed_button.connect("pressed", _on_pressed)
    proceed_button_margin.connect("resized", _on_resized)
    title_label.set_text(PlayersManager.get_player_name(player_id))

func _on_resized() -> void:
    var margin_factor = 0.2 # each margin should take 20% of the X size
    var sx = proceed_button_margin.get_size().x * margin_factor
    proceed_button_margin.begin_bulk_theme_override()
    proceed_button_margin.add_theme_constant_override("margin_left", sx)
    proceed_button_margin.add_theme_constant_override("margin_right", sx)
    proceed_button_margin.end_bulk_theme_override()

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

func _on_switch_item() -> void:
    var next = all_items.get_next_element_by_active()
    all_items.set_active_by_element(next)

func _on_choose_item() -> void:
    pass

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
