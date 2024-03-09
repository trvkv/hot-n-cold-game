extends HBoxContainer

class_name HorizontalItemContainer

@export var item_element_scene: PackedScene
@export var items: Array[ItemBase] = []

func _ready() -> void:
    assert(is_instance_valid(item_element_scene), "Item element scene is needed")
    reload_items()

func reload_items() -> void:
    for item_element: ItemElement in get_children():
        # clear current item
        clear_item(item_element)
    for item in items:
        add_item(item)

func add_item(item: ItemBase) -> void:
    if not is_instance_valid(item):
        return
    var item_element: ItemElement = item_element_scene.instantiate()
    if is_instance_valid(item_element):
        add_child(item_element)
        item_element.set_icon(item.icon)
        item_element.set_number(1)

func clear_item(item_element: ItemElement) -> void:
    if is_instance_valid(item_element):
        remove_child(item_element)
        item_element.set_icon(null)
        item_element.queue_free()
