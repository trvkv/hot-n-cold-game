extends PanelContainer

class_name AdjustmentsPanel

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1
@export var title_label: Label
@export var proceed_button: Button

signal player_ready(player_id)

func _ready() -> void:
    assert(is_instance_valid(title_label), "Title label invalid")
    assert(is_instance_valid(proceed_button), "Proceed button invalid")
    proceed_button.connect("pressed", _on_pressed)
    title_label.set_text(PlayersManager.get_player_name(player_id))

func _on_pressed() -> void:
    emit_signal("player_ready", player_id)
    proceed_button.set_modulate(Color(0.0, 1.0, 0.0))
