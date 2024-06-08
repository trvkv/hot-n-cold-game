extends RefCounted

class_name GuiResult

var status: int
var message: String

func _init(status_: int = FAILED, message_: String = "") -> void:
    status = status_
    message = message_
