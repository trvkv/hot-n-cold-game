extends HBoxContainer

class_name ActionHolder

@export var label: Label
@export var style_active: StyleBox
@export var style_inactive: StyleBox

var action: PlayerActions.ACTIONS
var is_active: bool = false

func _ready() -> void:
    assert(is_instance_valid(label), "label instance not valid!")
    assert(is_instance_valid(style_active) and is_instance_valid(style_inactive), "Styles not set")
    set_active(false)

func set_active(active: bool) -> void:
    is_active = active
    if is_active:
        add_theme_stylebox_override("panel", style_active)
    else:
        add_theme_stylebox_override("panel", style_inactive)

func set_action(action_: PlayerActions.ACTIONS) -> void:
    action = action_
    label.set_text(PlayerActions.action_to_string(action))
