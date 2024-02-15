extends HBoxContainer

class_name HorizontalItemContainer

@export var items: Array[ItemBase] = []

func _ready() -> void:
    reload_items()

func reload_items() -> void:
    # TODO: not finished yet
    for item_element: ItemElement in get_children():
        # clear current item
        clear_item(item_element)

func add_item(item_element: ItemElement, item: ItemBase) -> void:
    if is_instance_valid(item_element) and is_instance_valid(item):
        item_element.set_icon(item.icon)

func clear_item(item_element: ItemElement) -> void:
    if is_instance_valid(item_element):
        item_element.set_icon(null)
