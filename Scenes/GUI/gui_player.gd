extends Panel

@export var player: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1

@onready var label_player_name: Label = $PanelContainer/MarginContainer/VBoxContainer/L_player_name

func _ready() -> void:
    assert(is_instance_valid(label_player_name), "L_player_name label not found")
    label_player_name.set_text(PlayersManager.get_player_name(player))
