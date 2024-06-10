extends GameScreen

@export var viewport_player_1: SubViewportContainer
@export var viewport_player_2: SubViewportContainer

@export var camera_player_1: CameraPosition
@export var camera_player_2: CameraPosition
@export var camera_global: CameraPosition

@export var trap_scene: PackedScene

func _ready() -> void:
    assert(trap_scene, "Trap scene invalid")
    assert(viewport_player_1, "Viewport for player 1 invalid")
    assert(viewport_player_2, "Viewport for player 2 invalid")
    assert(camera_player_1, "Camera for player 1 invalid")
    assert(camera_player_2, "Camera for player 2 invalid")
    assert(camera_global, "Global camera invalid")
    CameraManager.activate_camera(camera_player_1.UUID)
    CameraManager.activate_camera(camera_player_2.UUID)
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
        CameraManager.activate_camera(camera_player_1.UUID)
        CameraManager.activate_camera(camera_player_1.UUID)
        viewport_player_1.set_visible(true)
        viewport_player_2.set_visible(true)
    elif event.is_action_pressed("ui_end"):
        CameraManager.activate_camera(camera_global.UUID)
        viewport_player_1.set_visible(false)
        viewport_player_2.set_visible(false)
