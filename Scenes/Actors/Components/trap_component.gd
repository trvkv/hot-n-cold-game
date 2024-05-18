extends Area3D

class_name TrapComponent

signal detected(body)

@export var interaction_distance = 0.75
@export var component_owner: Node3D

var interaction_height = 1.5

func _ready():
    assert(is_instance_valid(component_owner), "Component owner invalid")
    connect("body_entered", _on_body_entered)
    connect("body_exited", _on_body_exited)

func _physics_process(_delta) -> void:
    var movement_dir: Vector2 = PlayersManager.get_input(component_owner.player_id).normalized()
    if movement_dir.length() > 0:
        move_interaction_area(movement_dir)

func move_interaction_area(move_direction: Vector2) -> void:
    rotation.y = -move_direction.angle()
    set_position(Vector3(
            interaction_distance * move_direction.x,
            interaction_height,
            interaction_distance * move_direction.y
    ))

func _on_body_entered(body: Node) -> void:
    emit_signal("detected", body)

func _on_body_exited(_body: Node) -> void:
    pass
