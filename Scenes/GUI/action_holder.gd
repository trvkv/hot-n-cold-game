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

func set_active(activate: bool) -> void:
    if activate == is_active:
        return # already set, nothing to do
    is_active = activate
    if activate:
        add_theme_stylebox_override("label", style_active)
    else:
        add_theme_stylebox_override("label", style_inactive)

func set_action(action_: PlayerActions.ACTIONS) -> void:
    action = action_
    label.set_text(PlayerActions.action_to_string(action))
