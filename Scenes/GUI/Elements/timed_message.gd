extends Label

class_name TimedMessage

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.NONE
@export var timer: Timer
@export var timeout: float = 5.0
@export var autostart: bool = false

signal dismissing_message(timed_message)

func _ready() -> void:
    assert(timer, "Timer invalid")
    timer.connect("timeout", _on_timeout)
    if autostart:
        start()

func start() -> void:
    if timeout > 0:
        timer.start(timeout)

func _on_timeout() -> void:
    emit_signal("dismissing_message", self)
