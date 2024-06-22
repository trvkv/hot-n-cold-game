extends Node3D

class_name PlayerStartingPosition

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.NONE

@onready var editor_only: Node3D = $"Editor-only"
@onready var area: Area3D = $MeshInstance3D/Area3D

func _ready() -> void:
    if not Engine.is_editor_hint():
        # delete mesh and everything else if not in-editor
        for child in editor_only.get_children():
            editor_only.remove_child(child)
            child.queue_free()

    area.connect("body_entered", _on_body_entered)
    area.connect("body_exited", _on_body_exited)

func _on_body_entered(body) -> void:
    if not body is Player:
        return
    if body.player_id == player_id:
        EventBus.emit_signal("starting_position_reached", player_id, true)

func _on_body_exited(body) -> void:
    if not body is Player:
        return
    if body.player_id == player_id:
        EventBus.emit_signal("starting_position_reached", player_id, false)
