extends HBoxContainer

class_name HorizontalItemContainer

@export var item_element_scene: PackedScene
@export var items: Array[ItemBase] = []

var active_element: ItemElement

func _ready() -> void:
    assert(is_instance_valid(item_element_scene), "Item element scene is needed")
    reload_items()

    if get_child_count() == 0:
        return

    # set first item as active
    var item_element: ItemElement = get_child(0)
    set_active_by_element(item_element)

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
        item_element.set_item(item)
        item_element.set_number(1)

func get_next_element_by_active() -> ItemElement:
    var index = active_element.get_index()
    index += 1 # increase index
    if index < get_child_count():
        return get_child(index)
    return get_child(0)

func clear_item(item_element: ItemElement) -> void:
    if is_instance_valid(item_element):
        remove_child(item_element)
        item_element.queue_free()

func set_active_by_element(new_active: ItemElement) -> void:
    if new_active not in get_children():
        printerr("Item element ", new_active, " not found in ", self)
        return
    for item_element: ItemElement in get_children():
        if item_element == new_active:
            item_element.set_active(true)
            active_element = item_element
        else:
            item_element.set_active(false)
