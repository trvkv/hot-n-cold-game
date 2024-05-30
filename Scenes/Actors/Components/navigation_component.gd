extends Node3D

@export var component_owner: Player

@onready var map_rid: RID = get_world_3d().get_navigation_map()

func _ready() -> void:
    EventBus.connect("query_distance", _on_query_distance)

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

func _on_query_distance(player: Player) -> void:
    if player != component_owner:
        return

    var game_state = GameStateTypes.GameStateData.new(
        PlayersManager.get_opponent(component_owner),
        GameStateTypes.TYPES.FAVOURITE_ITEM_CONTAINER
    )
    EventBus.emit_signal("retrieve_game_state", game_state)
    if is_instance_valid(game_state.data):
        var target_position: Vector3 = game_state.data.get_global_position()
        var path = get_path_to_target(get_global_position(), target_position)
        EventBus.emit_signal("distance_updated", player, calculate_distance(path))
