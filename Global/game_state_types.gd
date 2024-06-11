extends Object

class_name GameStateTypes

enum TYPES {
    FAVOURITE_ITEM_CONTAINER,
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
