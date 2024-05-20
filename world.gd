extends Node3D

@onready var viewport_player_1: SubViewportContainer = $GridContainer/SubViewportContainer_P1
@onready var viewport_player_2: SubViewportContainer = $GridContainer/SubViewportContainer_P2

@export var trap_scene: PackedScene

func _ready() -> void:
    assert(trap_scene, "Trap scene invalid")
    CameraManager.set_active_cameras(CameraManager.CameraType.PLAYER_1 | CameraManager.CameraType.PLAYER_2)
    EventBus.connect("set_trap", _on_trap_set)

func _on_trap_set(player, global_trap_position) -> void:
    if trap_scene.can_instantiate():
        var trap: Trap = trap_scene.instantiate()
        add_child(trap)
        trap.owner = self
        trap.player_id = player.player_id
        trap.set_position(to_local(global_trap_position))

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_home"):
        CameraManager.set_active_cameras(CameraManager.CameraType.PLAYER_1 | CameraManager.CameraType.PLAYER_2)
        viewport_player_1.set_visible(true)
        viewport_player_2.set_visible(true)
    elif event.is_action_pressed("ui_end"):
        CameraManager.set_active_cameras(CameraManager.CameraType.GLOBAL)
        viewport_player_1.set_visible(false)
        viewport_player_2.set_visible(false)
