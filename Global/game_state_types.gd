extends Object

class_name GameStateTypes

enum TYPES {
    ITEM_CONTAINER,
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

class GameStateItemsContainer extends RefCounted:
    var _map = {}

    func add(item_type: StringName, container: ItemContainer) -> void:
        if not item_type in _map:
            _map[item_type] = []
        _map[item_type].append(container)

    func get_containers(item_type: StringName) -> Array:
        if not item_type in _map:
            return []
        return _map[item_type]

static func create_type(data_type: TYPES) -> RefCounted:
    if data_type == TYPES.ITEM_CONTAINER:
        return GameStateItemsContainer.new()
    return null
