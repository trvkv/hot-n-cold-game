extends Object

class_name GameStateTypes

enum TYPES {
    FAVOURITE_ITEM_CONTAINER
}

class GameStateData extends RefCounted:
    var player
    var data_type
    var data

    func _init(player_, data_type_, data_ = null) -> void:
        player = player_
        data_type = data_type_
        data = data_
