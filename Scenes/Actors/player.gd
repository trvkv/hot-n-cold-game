extends CharacterBody3D

class_name Player

@export var register_on_ready: bool = true
@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1
@export var movement_speed: float = 4.0
@export var gravity = 9.8
@export var player_input_component: PlayerInputComponent

@onready var animation_player = $AnimationPlayer
@onready var sprite_position = $SpritesPosition
@onready var animated_sprite = $SpritesPosition/AnimatedSprite3D
@onready var interaction_area = $InteractionArea
@onready var trap_component = $TrapComponent

func _ready() -> void:
    if register_on_ready:
        PlayersManager.add_player(player_id, self)
    assert(is_instance_valid(animation_player), "Animation player not present")
    assert(is_instance_valid(sprite_position), "Sprite position not present")
    assert(is_instance_valid(interaction_area), "Interaction area not present")
    assert(is_instance_valid(trap_component), "Trap component not present")

    # if player_input_component is invalid, player won't move
    # thus, all animations are also disabled.
    if not is_instance_valid(player_input_component):
        print("No player input controller found for player ", player_id, ", freezing.")
        freeze()

func _exit_tree() -> void:
    if register_on_ready:
        PlayersManager.remove_player(player_id)

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

    # player movement
    var movement_dir: Vector2 = player_input_component.get_input()
    movement_dir = movement_dir.normalized()

    velocity = Vector3(
        movement_dir.x * movement_speed,
        velocity.y,
        movement_dir.y * movement_speed
    )

    # interaction_area movement
    if movement_dir.length() > 0:
        interaction_area.move_interaction_area(movement_dir)

    # trap movement
    if movement_dir.length() > 0:
        trap_component.move_trap_area(movement_dir)

    move_and_slide()

func freeze() -> void:
    set_process(false)
    set_physics_process(false)
    animation_player.pause()
    animated_sprite.pause()

func unfreeze() -> void:
    set_process(true)
    set_physics_process(true)
    animation_player.play()
    animated_sprite.play()
