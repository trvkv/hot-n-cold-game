extends PanelContainer

class_name AdjustmentsPanel

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1
@export_range(1, 3) var max_items_to_choose: int = 3
@export var title_label: Label
@export var message_label: Label
@export var proceed_button_margin: MarginContainer
@export var proceed_button: Button

@export var chosen_items: HorizontalItemContainer
@export var required_items: HorizontalItemContainer
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
        set_success_message(result.message)
        proceed_button.set_modulate(Color(0.0, 1.0, 0.0))
    else:
        emit_signal("player_error", player_id, result.message)
        set_failure_message(result.message)

func _on_switch_item() -> void:
    if not is_favourite_item_already_chosen():
        var next = required_items.get_next_element_by_active()
        required_items.set_active_by_element(next)
    else:
        var next = all_items.get_next_element_by_active()
        all_items.set_active_by_element(next)

func _on_choose_item() -> void:
    if not is_favourite_item_already_chosen():
        # first make player to choose required items
         if add_active_item_from_container_to_chosen_items(required_items):
            # after favourite was chosen, set all required to non-active
            # and first item from additional items as active
            required_items.set_all_not_active()
            var next: ItemElement = all_items.get_next_element_by_active()
            all_items.set_active_by_element(next)
    else:
        # now, additional items can be chosen
        add_active_item_from_container_to_chosen_items(all_items)

func is_favourite_item_already_chosen() -> bool:
    var items: Array[ItemBase] = chosen_items.get_items()
    for item in items:
        if item.get_class_name() == &"ItemFavourite":
            return true
    return false

func add_active_item_from_container_to_chosen_items(container: HorizontalItemContainer) -> bool:
    var active_element = container.get_active_element()
    if not is_instance_valid(active_element):
        printerr("Active element in required items is invalid")
        return false
    var active_item_type: StringName = active_element.item.get_class_name()
    var new_item: ItemBase = ItemFactory.create(active_item_type)
    if not is_instance_valid(new_item):
        printerr("Newly created item is not valid! ", new_item)
        return false
    add_item_to_chosen_items(new_item)
    return true

func add_item_to_chosen_items(item: ItemBase) -> void:
    var items = chosen_items.get_items()
    if items.size() < max_items_to_choose:
        chosen_items.clear()
        for posessed_item in items:
            chosen_items.add_item(posessed_item)
        chosen_items.add_item(item)
    else:
        set_failure_message("Max items number reached!")

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

func set_success_message(message: String) -> void:
    message_label.set_text(message)
    message_label.self_modulate = Color(0.0, 1.0, 0.0)

func set_failure_message(message: String) -> void:
    message_label.set_text(message)
    message_label.self_modulate = Color(1.0, 0.0, 0.0)
