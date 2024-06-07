extends CharacterBody3D

class_name Player

@export var register_on_ready: bool = true
@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1
@export var movement_speed: float = 4.0
@export var gravity = 9.8

@onready var animation_player = $AnimationPlayer
@onready var sprite_position = $SpritesPosition
@onready var animated_sprite = $SpritesPosition/AnimatedSprite3D
@onready var interaction_area = $InteractionArea
@onready var item_inventory = $ItemInventory
@onready var trap_component = $TrapComponent

func _ready() -> void:
    if register_on_ready:
        PlayersManager.add_player(player_id, self)
    assert(is_instance_valid(animation_player), "Animation player not present")
    assert(is_instance_valid(sprite_position), "Sprite position not present")
    assert(is_instance_valid(interaction_area), "Interaction area not present")
    assert(is_instance_valid(item_inventory), "Item inventory not present")
    assert(is_instance_valid(trap_component), "Trap component not present")

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

    # movement
    var movement_dir: Vector2 = PlayersManager.get_input(player_id)
    movement_dir = movement_dir.normalized()

    velocity = Vector3(
        movement_dir.x * movement_speed,
        velocity.y,
        movement_dir.y * movement_speed
    )

    move_and_slide()

func handle_input(input: InputEventAction) -> void:
    if input.pressed:
        if input.action == "interact":
            EventBus.emit_signal("trigger_interaction", self, interaction_area)
        elif input.action == "switch_interaction":
            EventBus.emit_signal("switch_interaction", self, interaction_area)
        elif input.action == "switch_item":
            EventBus.emit_signal("switch_item", self)
        elif input.action == "switch_action":
            EventBus.emit_signal("switch_action", self)
        elif input.action == "query_distance":
            EventBus.emit_signal("query_distance", self)

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
