extends MenuScreen

@export var winner_label: Label
@export var finalize: Button

func _ready() -> void:
    assert(finalize, "New game button not found")
    finalize.connect("pressed", _on_pressed_finalize)

func _on_pressed_finalize() -> void:
    load_next()
