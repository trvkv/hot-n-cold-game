extends MarginContainer

class_name TimedMessage

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.NONE
@export var timer: Timer
@export var timeout: float = 5.0
@export var autostart: bool = false
@export var icon: Texture2D = null:
    set = set_icon
@export var icon_color: Color = Color(1.0, 1.0, 1.0, 1.0):
    set = set_icon_color
@export var text: String = "":
    set = set_text

@export var icon_rectangle: TextureRect
@export var message_label: Label

signal dismissing_message(timed_message)

func _ready() -> void:
    assert(is_instance_valid(message_label), "Message label is invalid")
    assert(is_instance_valid(timer), "Timer invalid")
    assert(is_instance_valid(icon_rectangle), "icon rectangle invalid")

    set_icon(icon)

    timer.connect("timeout", _on_timeout)
    if autostart:
        start()

func start() -> void:
    if timeout > 0:
        timer.start(timeout)

func set_icon(new_icon: Texture2D) -> void:
    icon = new_icon
    if new_icon == null:
        icon_rectangle.hide()
    else:
        icon_rectangle.texture = icon
        icon_rectangle.show()

func set_icon_color(new_color: Color) -> void:
    icon_color = new_color
    if is_instance_valid(icon_rectangle):
        icon_rectangle.set_modulate(new_color)

func set_text(message: String) -> void:
    text = message
    message_label.text = text

func _on_timeout() -> void:
    emit_signal("dismissing_message", self)
