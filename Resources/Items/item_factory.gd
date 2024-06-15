extends RefCounted

class_name ItemFactory

static var favourite: Resource = preload("res://Resources/Items/item_favourite.tres")
static var key: Resource = preload("res://Resources/Items/item_key.tres")
static var trap: Resource = preload("res://Resources/Items/item_trap.tres")

static func create(player_id: PlayersManager.PlayerID, item_type: StringName) -> ItemBase:
    var resource: ItemBase = null
    if item_type == &"ItemFavourite":
        resource = favourite.duplicate()
    elif item_type == &"ItemKey":
        resource = key.duplicate()
    elif item_type == &"ItemTrap":
        resource = trap.duplicate()
    if not is_instance_valid(resource):
        return null
    resource.player_id = player_id
    return resource
