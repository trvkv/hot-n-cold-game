extends Node3D

class_name PlayerStartingPosition

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.NONE

func _ready() -> void:
    if not Engine.is_editor_hint():
        # delete mesh and everything else if not in-editor
        for child in get_children():
            remove_child(child)
            child.queue_free()
