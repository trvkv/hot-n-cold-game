extends CanvasLayer

class_name MainGui

@export var gui_player_1: GuiPlayer
@export var gui_player_2: GuiPlayer
@export var gui_actions_1: GuiActions
@export var gui_actions_2: GuiActions
@export var gui_inventory_1: GuiInventory
@export var gui_inventory_2: GuiInventory

func _ready() -> void:
    assert(gui_player_1, "gui for player 1 not set correctly")
    assert(gui_player_2, "gui for player 2 not set correctly")
    assert(gui_actions_1, "gui actions for player 1 invalid")
    assert(gui_actions_2, "gui actions for player 2 invalid")
    assert(gui_inventory_1, "gui inventory for player 1 invalid")
    assert(gui_inventory_2, "gui inventory for player 2 invalid")
