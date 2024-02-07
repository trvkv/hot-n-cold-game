extends Area3D

@export var interaction_distance = 0.75
@export var interaction_height = 0.5
@export var interaction_initial_direction = Vector2(-1, 0)

@export var interactor: Node3D

var interactees: Array[Node3D]
var active_interactee: Node3D

func _ready() -> void:
    move_interaction_area(interaction_initial_direction)
    connect("body_entered", _on_body_entered)
    connect("body_exited", _on_body_exited)
    EventBus.connect("trigger_interaction", _on_trigger_interaction)
    EventBus.connect("switch_interaction", _on_switch_interaction)

    if not is_instance_valid(interactor):
        printerr(self, ": Interactor not valid, using 'self'")
        interactor = self

func _physics_process(_delta) -> void:
    var movement_dir: Vector2 = Vector2(interactor.velocity.x, interactor.velocity.z).normalized()
    if movement_dir.length() > 0:
        move_interaction_area(movement_dir)

func move_interaction_area(move_direction: Vector2) -> void:
    rotation.y = -move_direction.angle()
    set_position(Vector3(
            interaction_distance * move_direction.x,
            interaction_height,
            interaction_distance * move_direction.y
    ))

func sort_by_distance_ascending(a: Dictionary, b: Dictionary) -> bool:
    if a["distance"] < b["distance"]:
        return true
    return false

func find_closest_node(target: Node3D, nodes: Array[Node3D]) -> Node3D:
    # determine initial active interactee, by finding the
    # closest one from the list
    var distances: Array[Dictionary] = []
    for n in nodes:
        var p = n.get_global_position()
        distances.append({
            "object": n,
            "distance": p.distance_to(target.get_global_position())
        })
    distances.sort_custom(sort_by_distance_ascending)
    if distances.size() > 0:
        return distances[0]["object"]
    return null

func _on_body_entered(body):
    var send_signal = false
    if body.is_in_group("containers"):
        if body in interactees:
            return
        interactees.push_back(body)
        active_interactee = find_closest_node(interactor, interactees)
        send_signal = true
    if send_signal:
        EventBus.emit_signal("update_interactees", interactees, active_interactee)

func _on_body_exited(body):
    var send_signal = false
    if body.is_in_group("containers"):
        interactees.erase(body)
        active_interactee = find_closest_node(interactor, interactees)
        send_signal = true
    if send_signal:
        EventBus.emit_signal("update_interactees", interactees, active_interactee)

func _on_trigger_interaction(interaction_area, event_interactor) -> void:
    if interaction_area != self:
        return
    if is_instance_valid(active_interactee):
        EventBus.emit_signal("interact", active_interactee, event_interactor)

func _on_switch_interaction(interaction_area) -> void:
    if interaction_area != self:
        return
    var index = interactees.find(active_interactee)
    if index > -1:
        index += 1
        if index == interactees.size():
            index = 0
        active_interactee = interactees[index]
        EventBus.emit_signal("update_interactees", interactees, active_interactee)
