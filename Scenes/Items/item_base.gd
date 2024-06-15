extends Resource

class_name ItemBase

@export var icon: Texture2D = null
@export var actions: Array[PlayerActions.ACTIONS] = []
@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.NONE

func get_class_name() -> StringName:
    return &"ItemBase"
