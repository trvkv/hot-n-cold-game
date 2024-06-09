extends InputComponent

class_name AdjustmentInputComponent

@export var adjustments_panel: AdjustmentsPanel

signal switch_item()
signal choose_item()

func _ready() -> void:
    assert(is_instance_valid(adjustments_panel), "AdjustmentsPanel invalid")
    if adjustments_panel.player_id == PlayersManager.PlayerID.PLAYER_1:
        action_input_prefix = "player_1_"
    elif adjustments_panel.player_id == PlayersManager.PlayerID.PLAYER_2:
        action_input_prefix = "player_2_"
    super()

func send_action(input: InputEventAction) -> void:
    if input.pressed:
        if input.action == "interact":
            emit_signal("choose_item")
        elif input.action == "switch_item":
            emit_signal("switch_item")
