extends PanelContainer

class_name ItemElement

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

func _ready():
    set_number(number)
    set_icon(texture)

func set_number(value: int) -> void:
    if not is_instance_valid(number_label):
        return
    number_label.set_text(str(value))

func set_icon(icon: Texture2D) -> void:
    if not is_instance_valid(texture_rect):
        return
    texture_rect.texture = icon
