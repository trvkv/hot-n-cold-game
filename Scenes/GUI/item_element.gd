extends PanelContainer

class_name ItemElement

@export var style_active: StyleBox
@export var style_inactive: StyleBox

@onready var texture_rect = $MarginContainer/TextureRect
@onready var number_label = $MarginContainer/MarginContainer/CenterContainer/Panel/LabelNumber

@export var texture: Texture2D = null:
    set(value):
        texture = value
        set_icon(texture)
    get:
        return texture

@export var number: int = 0:
    set(value):
        number = value
        set_number(number)
    get:
        return number

var item: ItemBase
var is_active: bool = false

func _ready():
    assert(is_instance_valid(style_active) and is_instance_valid(style_inactive), "Styles not set")
    set_number(number)
    set_icon(texture)
    set_active(false)

func set_item(new_item: ItemBase) -> void:
    item = new_item
    set_icon(item.icon)

func set_number(value: int) -> void:
    if not is_instance_valid(number_label):
        return
    number_label.set_text(str(value))

func set_icon(icon: Texture2D) -> void:
    if not is_instance_valid(texture_rect):
        return
    texture_rect.texture = icon

func set_active(activate: bool) -> void:
    if activate == is_active:
        return # already set, nothing to do
    if activate:
        add_theme_stylebox_override("panel", style_active)
        is_active = true
    else:
        add_theme_stylebox_override("panel", style_inactive)
        is_active = false
