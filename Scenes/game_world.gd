extends GameScreen

class_name GameWorld

@export var starting_game_stage: GameStage:
    set = set_starting_game_stage, get = get_starting_game_stage

@export var viewport_player_1: SubViewportContainer
@export var viewport_player_2: SubViewportContainer
@export var splitscreen_container: GridContainer
@export var player_1: Player
@export var player_2: Player
@export var camera_player_1: CameraPosition
@export var camera_player_2: CameraPosition
@export var trap_scene: PackedScene
@export var gui: MainGui
@export var level: Level

var current_game_stage: GameStage:
    set = set_current_game_stage, get = get_current_game_stage

func _ready() -> void:
    assert(trap_scene, "Trap scene invalid")
    assert(viewport_player_1, "Viewport for player 1 invalid")
    assert(viewport_player_2, "Viewport for player 2 invalid")
    assert(splitscreen_container, "splitscreen container invalid")
    assert(player_1, "Invalid player 1")
    assert(player_2, "Invalid player 2")
    assert(camera_player_1, "Camera for player 1 invalid")
    assert(camera_player_2, "Camera for player 2 invalid")
    assert(gui, "Gui invalid")
    assert(level, "Level invalid")
    CameraManager.activate_camera(camera_player_1.UUID)
    CameraManager.activate_camera(camera_player_2.UUID)
    EventBus.connect("set_trap", _on_trap_set)

    # calling only when the node is ready
    set_starting_game_stage(starting_game_stage)

    splitscreen_container.connect("resized", _on_resized)

func _on_resized() -> void:
    print("############# CHANGING SCREEN SIZES NOT IMPLEMENTED ##############")
    print("# Splitscreen container: ", splitscreen_container.get_size())
    print("##################################################################")

func _process(delta) -> void:
    if current_game_stage != null:
        current_game_stage.update(delta)

func _on_trap_set(player, global_trap_position) -> void:
    if trap_scene.can_instantiate():
        var trap: Trap = trap_scene.instantiate()
        add_child(trap)
        trap.owner = self
        trap.player_id = player.player_id
        trap.set_position(to_local(global_trap_position))
        trap.game_stage = current_game_stage

func set_starting_game_stage(stage: GameStage) -> void:
    starting_game_stage = stage
    if is_node_ready():
        set_current_game_stage(stage)

func get_starting_game_stage() -> GameStage:
    return starting_game_stage

func set_current_game_stage(stage: GameStage) -> void:
    print("Setting current game stage: ", stage)
    if current_game_stage != null:
        current_game_stage.exit()
        current_game_stage.disconnect("get_function_ref", _on_get_function_ref)
        EventBus.emit_signal("update_game_stage", GameStage.ACTIONS.EXITED, current_game_stage)
    current_game_stage = stage
    if current_game_stage != null:
        current_game_stage.connect("get_function_ref", _on_get_function_ref)
        current_game_stage.enter()
    EventBus.emit_signal("update_game_stage", GameStage.ACTIONS.ENTERED, current_game_stage)

func get_current_game_stage() -> GameStage:
    return current_game_stage

func load_next_game_stage() -> void:
    var current: GameStage = get_current_game_stage()
    if current == null:
        printerr("Loading next stage failed: current game stage is null")
        return
    set_current_game_stage(current.next_stage)

func hide_player_container(player_id: PlayersManager.PlayerID) -> void:
    if player_id == PlayersManager.PlayerID.PLAYER_1:
        viewport_player_1.set_self_modulate(Color(1.0, 1.0, 1.0, 0.0))
    elif player_id == PlayersManager.PlayerID.PLAYER_2:
        viewport_player_2.set_self_modulate(Color(1.0, 1.0, 1.0, 0.0))

    var panel: GuiPlayerPanel = gui.get_player_panel(player_id)
    if not is_instance_valid(panel):
        printerr("Player panel not valid")
        return
    panel.gui_player.set_modulate(Color(1.0, 1.0, 1.0, 0.0))
    panel.gui_inventory.set_modulate(Color(1.0, 1.0, 1.0, 0.0))
    panel.gui_actions.set_modulate(Color(1.0, 1.0, 1.0, 0.0))

func show_player_container(player_id: PlayersManager.PlayerID) -> void:
    if player_id == PlayersManager.PlayerID.PLAYER_1:
        viewport_player_1.set_self_modulate(Color(1.0, 1.0, 1.0, 1.0))
    elif player_id == PlayersManager.PlayerID.PLAYER_2:
        viewport_player_2.set_self_modulate(Color(1.0, 1.0, 1.0, 1.0))

    var panel: GuiPlayerPanel = gui.get_player_panel(player_id)
    if not is_instance_valid(panel):
        printerr("Player panel not valid")
        return
    panel.gui_player.set_modulate(Color(1.0, 1.0, 1.0, 1.0))
    panel.gui_inventory.set_modulate(Color(1.0, 1.0, 1.0, 1.0))
    panel.gui_actions.set_modulate(Color(1.0, 1.0, 1.0, 1.0))

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

func set_player_inventory(player_id: PlayersManager.PlayerID, items: Array[StringName]) -> void:
    var panel: GuiPlayerPanel = gui.get_player_panel(player_id)
    if not is_instance_valid(panel):
        printerr("Player panel not valid")
        return

    var gui_player: GuiPlayer = panel.gui_player
    var inventory: Array[ItemBase] = []
    for item in items:
        inventory.append(ItemFactory.create(player_id, item))
    gui_player.set_items(inventory, true) # clean and set inventory

func set_player_starting_position(player_id: PlayersManager.PlayerID) -> void:
    var level_position: Vector3
    for starting_position in level.player_starting_positions:
        if starting_position.player_id == player_id:
            level_position = level.to_local(starting_position.get_position())
            var player: Player = PlayersManager.get_player(player_id)
            if not is_instance_valid(player):
                printerr("Player not found!")
                return
            player.set_position(level_position)
            break

func set_requirement_message(player_id: PlayersManager.PlayerID, message: String) -> void:
    gui.set_requirement_message(player_id, message)

func clear_requirement_messages(player_id: PlayersManager.PlayerID):
    gui.clear_requirement_messages(player_id)

func set_information_message(player_id: PlayersManager.PlayerID, message: String) -> void:
    gui.set_information_message(player_id, message)

func set_global_message(message: String) -> void:
    gui.set_global_message(message)

func set_ready_button(player_id: PlayersManager.PlayerID, activate: bool) -> void:
    if activate:
        if not gui.is_connected("player_ready", _on_player_ready):
            gui.connect("player_ready", _on_player_ready)
    else:
        if gui.is_connected("player_ready", _on_player_ready):
            gui.disconnect("player_ready", _on_player_ready)
    gui.setup_ready_button(player_id, activate, activate)

func _on_player_ready(player_id: PlayersManager.PlayerID) -> void:
    set_ready_button(player_id, false)
    load_next_game_stage()

func _on_get_function_ref(function_container: GameStage.FunctionRefContainer) -> void:
    function_container.callback = Callable(self, function_container.function_name)
