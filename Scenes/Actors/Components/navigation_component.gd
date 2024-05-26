extends Node3D

@export var component_owner: Player
@export var target_position: Vector3 = Vector3(3.0, 0.0, 0.0)
@export var debug: bool = false
@export var debug_line_color: Color = Color(1.0, 1.0, 1.0, 1.0)

@onready var map_rid: RID = get_world_3d().get_navigation_map()
@onready var canvas: CanvasItem = $CanvasLayer/Control

var current_path: PackedVector3Array = []

func _ready() -> void:
    if debug:
        setup_debug_line()
    else:
        if is_instance_valid(canvas):
            canvas.queue_free()

func _process(_delta: float) -> void:
    current_path = get_path_to_target(get_global_position(), target_position)
    if debug:
        setup_debug_line()

func setup_debug_line() -> void:
    if is_instance_valid(canvas):
        canvas.debug_line_color = debug_line_color
        canvas.current_path = current_path

func get_path_to_target(from: Vector3, to: Vector3) -> PackedVector3Array:
    return NavigationServer3D.map_get_path(map_rid, from, to, true)
