extends Area3D

class_name TrapComponent

signal obstacles_updated(player, obstacles)

@export var interaction_distance = 0.75
@export var component_owner: Node3D

@onready var trap_indicator = $MeshInstance3D

var interaction_height = 1.5

var bodies: Array = []

func _ready() -> void:
    assert(is_instance_valid(component_owner), "Component owner invalid")
    assert(is_instance_valid(trap_indicator), "Trap indicator invalid")

    connect("body_entered", _on_body_entered)
    connect("body_exited", _on_body_exited)

    EventBus.connect("update_actions", _on_update_actions)

    update_indicator()
    hide()

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

func update_indicator() -> void:
    if bodies.size() > 0:
        update_indicator_color(Color(1.0, 0.0, 0.0, 1.0))
    else:
        update_indicator_color(Color(0.0, 1.0, 0.0, 1.0))

func update_indicator_color(color: Color) -> void:
    var mat: StandardMaterial3D = trap_indicator.get_surface_override_material(0)
    if is_instance_valid(mat):
        mat.albedo_color = color

func _on_update_actions(player, _actions, active_action) -> void:
    if component_owner == player:
        if active_action == PlayerActions.ACTIONS.SET_TRAP:
            show()
        else:
            hide()

func _on_body_entered(body: Node) -> void:
    if body not in bodies:
        emit_signal("obstacles_updated", component_owner, bodies)
        bodies.append(body)
        update_indicator()

func _on_body_exited(body: Node) -> void:
    if body in bodies:
        bodies.erase(body)
        emit_signal("obstacles_updated", component_owner, bodies)
        update_indicator()
