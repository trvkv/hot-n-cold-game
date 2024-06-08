extends InputComponent

class_name PlayerInputComponent

@export var player: Player

var player_id: PlayersManager.PlayerID

func _ready() -> void:
    assert(is_instance_valid(player), "Player is not valid")
    player_id = player.player_id
    if player_id == PlayersManager.PlayerID.PLAYER_1:
        action_input_prefix = "player_1_"
    elif player_id == PlayersManager.PlayerID.PLAYER_2:
        action_input_prefix = "player_2_"
    super()

func send_action(input: InputEventAction) -> void:
    if input.pressed:
        if input.action == "interact":
            EventBus.emit_signal("trigger_interaction", player, player.interaction_area)
        elif input.action == "switch_interaction":
            EventBus.emit_signal("switch_interaction", player, player.interaction_area)
        elif input.action == "switch_item":
            EventBus.emit_signal("switch_item", player)
        elif input.action == "switch_action":
            EventBus.emit_signal("switch_action", player)
        elif input.action == "query_distance":
            EventBus.emit_signal("query_distance", player)

func get_input() -> Vector2:
    return Vector2(
        Input.get_axis(mapping["down"], mapping["up"]),
        Input.get_axis(mapping["left"], mapping["right"])
    )
