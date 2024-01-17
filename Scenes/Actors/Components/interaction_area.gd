extends Area3D

@export var interaction_distance = 0.75
@export var interaction_height = 0.5
@export var interaction_initial_direction = Vector2(-1, 0)

@export var interactor: Node3D

func _ready() -> void:
    move_interaction_area(interaction_initial_direction)
    connect("body_entered", _on_body_entered)

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

func _on_body_entered(body):
    if body.is_in_group("containers"):
        EventBus.emit_signal("interact", body, interactor)
