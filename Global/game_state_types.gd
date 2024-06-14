extends Object

class_name GameStateTypes

enum TYPES {
    FAVOURITE_ITEM_CONTAINER,
    KEY_ITEM_CONTAINER,
    CHOSEN_ITEMS
}

class GameStateData extends RefCounted:
    var player_id
    var data_type
    var data

    func _init(player_id_, data_type_, data_ = null) -> void:
        player_id = player_id_
        data_type = data_type_
        data = data_

class GameStateItem extends  RefCounted:
    var item: ItemBase
    var container: ItemContainer

    func _init(item_: ItemBase, container_: ItemContainer):
        item = item_
        container = container_

class GameStateItemsContainer extends RefCounted:
    var data = []

    func add(item: ItemBase, container: ItemContainer) -> void:
        data.append(GameStateItem.new(item, container))

static func create_type(data_type: TYPES) -> RefCounted:
    if data_type == TYPES.FAVOURITE_ITEM_CONTAINER:
        return null
    elif data_type == TYPES.KEY_ITEM_CONTAINER:
        return GameStateItemsContainer.new()
    return null
