extends CanvasLayer

class_name MainGui

@export var gui_player_1: GuiPlayer
@export var gui_player_2: GuiPlayer

func _ready() -> void:
    assert(gui_player_1, "gui for player 1 not set correctly")
    assert(gui_player_2, "gui for player 2 not set correctly")
