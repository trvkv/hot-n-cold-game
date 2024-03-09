extends Control

@export var frames_value_path: Label
@export var fps_value_path: Label
@export var process_value_path: Label
@export var physics_value_path: Label

func _ready() -> void:
    assert(is_instance_valid(frames_value_path), "Frames path is not correct")
    assert(is_instance_valid(fps_value_path), "FPS path is not correct")
    assert(is_instance_valid(process_value_path), "Process path is not correct")
    assert(is_instance_valid(physics_value_path), "Physics path is not correct")

func _process(_delta: float) -> void:
    var txt = "%0.5f ms" % (Performance.get_monitor(Performance.TIME_PROCESS))
    frames_value_path.set_text(txt)
    txt = "%d" % (Performance.get_monitor(Performance.TIME_FPS))
    fps_value_path.set_text(txt)
    txt = "%0.5f ms" % (Performance.get_monitor(Performance.TIME_PROCESS))
    process_value_path.set_text(txt)
    txt = "%0.5f ms" % (Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS))
    physics_value_path.set_text(txt)
