extends CharacterBody3D

@export var movement_speed: float = 4.0
@export var gravity = 0.9

func _physics_process(delta):
    # gravity comes first
    velocity.y -= gravity * delta

    # movement
    var movement_dir = Vector2(Input.get_axis("ui_down", "ui_up"), Input.get_axis("ui_left", "ui_right"))
    movement_dir = movement_dir.normalized()
    velocity = Vector3(movement_dir.x, 0.0, movement_dir.y) * movement_speed

    move_and_slide()
