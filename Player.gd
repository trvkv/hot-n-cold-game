extends CharacterBody3D

var acc: float = 0.0
var current_frame: int = 0

var gravity = 0.9

@onready var sprite = $AnimatedSprite3D

func _physics_process(_delta):
    var movement_dir = Vector2(Input.get_axis("ui_down", "ui_up"), Input.get_axis("ui_left", "ui_right"))
    movement_dir = movement_dir.normalized()
    #velocity.y -= gravity * delta
    velocity += Vector3(movement_dir.x, 0.0, movement_dir.y) * 0.12
    move_and_slide()
