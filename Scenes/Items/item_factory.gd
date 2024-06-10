extends RefCounted

class_name ItemFactory

static var favourite_scene: Resource = preload("res://Scenes/Items/item_favourite.tres")
static var key_scene: Resource = preload("res://Scenes/Items/item_key.tres")
static var trap_scene: Resource = preload("res://Scenes/Items/item_trap.tres")

static func create(item_type: StringName) -> ItemBase:
    if item_type == &"ItemFavourite":
        return favourite_scene
    elif item_type == &"ItemKey":
        return key_scene
    elif item_type == &"ItemTrap":
        return trap_scene
    return null
