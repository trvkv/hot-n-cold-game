extends Node3D

@export var component_owner: Player

@onready var map_rid: RID = get_world_3d().get_navigation_map()
@onready var timer: Timer = $Timer

var ready_to_use: bool = true
var game_stage: GameStage = null

func _ready() -> void:
    EventBus.connect("query_distance", _on_query_distance)
    EventBus.connect("update_game_stage", _on_update_game_stage)
    timer.connect("timeout", _on_timeout)

func get_path_to_target(from: Vector3, to: Vector3) -> PackedVector3Array:
    return NavigationServer3D.map_get_path(map_rid, from, to, true)

func calculate_distance(path: PackedVector3Array) -> float:
    var distance: float = 0.0
    for segment_id in range(0, path.size()):
        var p1: Vector3 = path[segment_id]
        var p2: Vector3 = path[segment_id]
        if segment_id + 1 < path.size():
            p2 = path[segment_id + 1]
        distance += p1.distance_to(p2)
    return distance

func _on_update_game_stage(action: GameStage.ACTIONS, stage: GameStage) -> void:
    if action == GameStage.ACTIONS.ENTERED:
        game_stage = stage
    elif action == GameStage.ACTIONS.EXITED:
        game_stage = null

func _on_query_distance(player: Player) -> void:
    if game_stage == null:
        printerr("Game state is null!")
        return

    if not game_stage.should_hot_cold_system_work:
        return

    if player != component_owner:
        return

    if not ready_to_use:
        return

    var state = GameStateTypes.GameStateData.new(
        PlayersManager.get_opponent(component_owner.player_id).player_id,
        GameStateTypes.TYPES.FAVOURITE_ITEM_CONTAINER
    )
    EventBus.emit_signal("retrieve_game_state", state)
    if is_instance_valid(state.data):
        assert(state.data as ItemContainer, "Retrieved data should be of ItemContainer class")
        var target_position: Vector3 = state.data.get_global_position()
        var path = get_path_to_target(get_global_position(), target_position)
        EventBus.emit_signal("distance_updated", player.player_id, calculate_distance(path))
        ready_to_use = false
        timer.start()

func _on_timeout() -> void:
    ready_to_use = true
    EventBus.emit_signal("query_ready", component_owner.player_id)
