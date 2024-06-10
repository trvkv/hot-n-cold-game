@tool
extends HBoxContainer

class_name HorizontalItemContainer

@export var item_element_scene: PackedScene
@export var items_at_start: Array[ItemBase]:
    set = set_starting_items, get = get_starting_items
@export var set_active_on_ready: bool = true

var active_element: ItemElement

func _ready() -> void:
    assert(is_instance_valid(item_element_scene), "Item element scene is needed")

    starting_items_reload()

    if get_child_count() == 0:
        return

    if set_active_on_ready:
        # set first item as active
        var item_element: ItemElement = get_child(0)
        set_active_by_element(item_element)

func set_starting_items(items: Array[ItemBase]) -> void:
    items_at_start = items
    starting_items_reload()

func get_starting_items() -> Array[ItemBase]:
    return items_at_start

func starting_items_reload() -> void:
    clear()
    for item in items_at_start:
        add_item(item, true)

func add_item(item: ItemBase, allow_empty: bool = false) -> void:
    if not is_instance_valid(item):
        if allow_empty:
            add_empty()
        return
    var item_element: ItemElement = item_element_scene.instantiate()
    if is_instance_valid(item_element):
        add_child(item_element)
        item_element.set_item(item)
        item_element.set_number(1)

func add_empty() -> void:
    var item_element: ItemElement = item_element_scene.instantiate()
    if is_instance_valid(item_element):
        add_child(item_element)

func get_active_element() -> ItemElement:
    return active_element

func get_next_element_by_active() -> ItemElement:
    if get_child_count() == 0:
        return null

    var index = 0

    if is_instance_valid(active_element):
        index = active_element.get_index()

    index += 1 # increase index
    if index < get_child_count():
        return get_child(index)

    return get_child(0)

func clear_element(item_element: ItemElement) -> void:
    if is_instance_valid(item_element):
        remove_child(item_element)
        item_element.queue_free()

func clear() -> void:
    for element in get_children():
        clear_element(element)

func get_elements() -> Array[ItemElement]:
    var elements: Array[ItemElement] = []
    for element in get_children():
        elements.append(element)
    return elements

func get_items() -> Array[ItemBase]:
    var items: Array[ItemBase] = []
    for element in get_children():
        if is_instance_valid(element.item):
            items.append(element.item)
    return items

func set_active_by_element(new_active: ItemElement) -> void:
    if Engine.is_editor_hint():
        return # do not set active items in editor
    if new_active not in get_children():
        printerr("Item element ", new_active, " not found in ", self)
        return
    for item_element: ItemElement in get_children():
        if item_element == new_active:
            item_element.set_active(true)
            active_element = item_element
        else:
            item_element.set_active(false)

func size() -> int:
    return get_child_count()

func has_item(item_to_check: ItemBase) -> bool:
    for item in get_items():
        if item == item_to_check:
            return true
    return false

func clear_item(item_to_clear: ItemBase) -> bool:
    if has_item(item_to_clear):
        for element in get_children():
            if element.item == item_to_clear:
                clear_element(element)
                return true
    return false
