extends Area3D

class_name Trap

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var timer: Timer = $Timer

var player_id: PlayersManager.PlayerID

func _ready() -> void:
    assert(mesh_instance, "Mesh instance invalid")
    assert(timer, "Timer invalid")
    timer.connect("timeout", _on_timer_timeout)
    timer.start()

func _on_timer_timeout() -> void:
    var tween: Tween = create_tween()
    tween.tween_property(mesh_instance, "transparency", 1.0, 1.0)
