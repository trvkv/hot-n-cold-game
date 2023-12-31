extends CharacterBody3D

class_name Player

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1
@export var movement_speed: float = 4.0
@export var gravity = 0.9
@export var interaction_distance = 0.75
@export var interaction_height = 0.5
@export var interaction_initial_direction = Vector2(-1, 0)

@onready var animation_player = $AnimationPlayer
@onready var sprite_position = $SpritesPosition
@onready var interaction_area = $InteractionArea

func _ready() -> void:
    PlayersManager.add_player(player_id, self)

    move_interaction_area(interaction_initial_direction)
    interaction_area.connect("body_entered", _on_body_entered)

func _process(_delta):
    if velocity.length() > 0.0:
        animation_player.current_animation = "move"
        if velocity.z > 0.0:
            sprite_position.rotation.y = deg_to_rad(180.0)
        if velocity.z < 0.0:
            sprite_position.rotation.y = deg_to_rad(0.0)

    if velocity == Vector3.ZERO:
        animation_player.current_animation = "idle"

func _physics_process(delta):
    # gravity comes first
    velocity.y -= gravity * delta

    # movement
    var movement_dir = PlayersManager.get_input(player_id)
    movement_dir = movement_dir.normalized()
    velocity = Vector3(movement_dir.x, 0.0, movement_dir.y) * movement_speed

    if movement_dir.length() > 0:
        move_interaction_area(movement_dir)

    move_and_slide()

func _on_body_entered(body):
    if body.is_in_group("containers"):
        EventBus.emit_signal("interact", body, self)

func move_interaction_area(move_direction: Vector2) -> void:
    interaction_area.rotation.y = -move_direction.angle()
    interaction_area.set_position(Vector3(
            interaction_distance * move_direction.x,
            interaction_height,
            interaction_distance * move_direction.y
    ))
