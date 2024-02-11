extends HBoxContainer

class_name HorizontalItemContainer

@export var items: Array[ItemBase] = []

func _ready() -> void:
    reload_items()

func reload_items() -> void:
    # clear current items
    for child in get_children():
        remove_child(child)


