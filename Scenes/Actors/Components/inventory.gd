extends Node3D

class_name ItemInventory

@export var items: Array[ItemBase] = []

func add_item(item: ItemBase) -> void:
    if is_instance_valid(item) and is_instance_valid(item as ItemBase):
        items.append(item)

func get_items() -> Array:
    return items.duplicate()

func has_item(item: ItemBase) -> bool:
    return items.has(item)

func remove_item(item: ItemBase) -> void:
    items.erase(item)

func size() -> int:
    return items.size()

func clear() -> void:
    items.clear()
