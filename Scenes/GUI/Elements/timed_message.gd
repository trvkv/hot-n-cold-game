extends MarginContainer

class_name TimedMessage

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.NONE
@export var timer: Timer
@export var timeout: float = 5.0
@export var autostart: bool = false
@export var text: String = "":
    set = set_text

@export var message_label: Label

signal dismissing_message(timed_message)

func _ready() -> void:
    assert(is_instance_valid(message_label), "Message label is invalid")
    assert(is_instance_valid(timer), "Timer invalid")
    timer.connect("timeout", _on_timeout)
    if autostart:
        start()

func start() -> void:
    if timeout > 0:
        timer.start(timeout)

func set_text(message: String) -> void:
    text = message
    message_label.text = text

func _on_timeout() -> void:
    emit_signal("dismissing_message", self)
