extends GameScreen

class_name GameWorld

@export var starting_game_stage: GameStage:
    set = set_starting_game_stage, get = get_starting_game_stage

@export var viewport_player_1: SubViewportContainer
@export var viewport_player_2: SubViewportContainer
@export var player_1: Player
@export var player_2: Player
@export var camera_player_1: CameraPosition
@export var camera_player_2: CameraPosition
@export var trap_scene: PackedScene

var current_game_stage: GameStage:
    set = set_current_game_stage, get = get_current_game_stage

func _ready() -> void:
    assert(trap_scene, "Trap scene invalid")
    assert(viewport_player_1, "Viewport for player 1 invalid")
    assert(viewport_player_2, "Viewport for player 2 invalid")
    assert(camera_player_1, "Camera for player 1 invalid")
    assert(camera_player_2, "Camera for player 2 invalid")
    CameraManager.activate_camera(camera_player_1.UUID)
    CameraManager.activate_camera(camera_player_2.UUID)
    EventBus.connect("set_trap", _on_trap_set)

    # calling only when the node is ready
    set_starting_game_stage(starting_game_stage)

func _process(delta) -> void:
    if is_instance_valid(current_game_stage):
        current_game_stage.update(delta)

func _on_trap_set(player, global_trap_position) -> void:
    if trap_scene.can_instantiate():
        var trap: Trap = trap_scene.instantiate()
        add_child(trap)
        trap.owner = self
        trap.player_id = player.player_id
        trap.set_position(to_local(global_trap_position))

func set_starting_game_stage(stage: GameStage) -> void:
    starting_game_stage = stage
    if is_node_ready():
        set_current_game_stage(stage)

func get_starting_game_stage() -> GameStage:
    return starting_game_stage

func set_current_game_stage(stage: GameStage) -> void:
    if is_instance_valid(current_game_stage):
        current_game_stage.exit()
        current_game_stage.disconnect("get_function_ref", _on_get_function_ref)
    current_game_stage = stage
    current_game_stage.connect("get_function_ref", _on_get_function_ref)
    current_game_stage.enter()

func get_current_game_stage() -> GameStage:
    return current_game_stage

func hide_player_container(player_id: PlayersManager.PlayerID) -> void:
    if player_id == PlayersManager.PlayerID.PLAYER_1:
        viewport_player_1.set_self_modulate(Color(1.0, 1.0, 1.0, 0.0))
    elif player_id == PlayersManager.PlayerID.PLAYER_2:
        viewport_player_2.set_self_modulate(Color(1.0, 1.0, 1.0, 0.0))

func show_player_container(player_id: PlayersManager.PlayerID) -> void:
    if player_id == PlayersManager.PlayerID.PLAYER_1:
        viewport_player_1.set_self_modulate(Color(1.0, 1.0, 1.0, 1.0))
    elif player_id == PlayersManager.PlayerID.PLAYER_2:
        viewport_player_2.set_self_modulate(Color(1.0, 1.0, 1.0, 1.0))

func freeze(player_id: PlayersManager.PlayerID, do_freeze: bool) -> void:
    if player_id == PlayersManager.PlayerID.PLAYER_1:
        _freeze_player(player_1, do_freeze)
    elif player_id == PlayersManager.PlayerID.PLAYER_2:
        _freeze_player(player_2, do_freeze)

func _freeze_player(player: Player, do_freeze: bool) -> void:
    if do_freeze:
        player.freeze()
    else:
        player.unfreeze()

func _on_get_function_ref(function_container: GameStage.FunctionRefContainer) -> void:
    function_container.callback = Callable(self, function_container.function_name)
