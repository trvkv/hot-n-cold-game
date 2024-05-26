extends Control

@export var debug_line_color: Color = Color(1.0, 1.0, 1.0, 1.0)

var current_path: Array = []

func _process(_delta: float) -> void:
    if Engine.get_process_frames() % 10 == 0:
        queue_redraw()

func _draw() -> void:
    var camera: Camera3D = get_viewport().get_camera_3d()
    var points2d: Array = []
    for point in current_path:
        points2d.append(camera.unproject_position(point))
    if points2d.size() > 0:
        draw_polyline(points2d, debug_line_color, 1.0, true)
