@tool
extends Node3D

class_name CameraPosition

@export var camera_owner: Node
@export var camera_type: CameraManager.CameraType = CameraManager.CameraType.GLOBAL
@export var zoom: float = 1.0:
    get:
        return zoom
    set(value):
        zoom = value
        set_zoom(zoom)

@onready var collision_area = $Area3D
@onready var camera: Camera3D = $Camera3D
@onready var starting_camera_position = camera.get_position()

var faded_objects: Dictionary
var UUID: int = -1

func _ready():
    if Engine.is_editor_hint():
        return
    # camera_owner being null should be OK. For example in case of global cameras.
    UUID = CameraManager.register_camera(camera_owner, camera_type, $Camera3D)
    collision_area.connect("body_entered", _on_body_entered)
    collision_area.connect("body_exited", _on_body_exited)

func _process(_delta):
    for body in faded_objects.keys():
        if faded_objects[body]["ray_result"] != null:
            var normal = faded_objects[body]["ray_result"]["normal"]
            var raycast_vec: Vector3 = position - to_local(body.global_position)
            var nearest_wall_position = cos(raycast_vec.angle_to(normal)) * raycast_vec.length()
            set_distance_fade(body, nearest_wall_position)

func _physics_process(_delta):
    for body in faded_objects.keys():
        var space_state = get_world_3d().direct_space_state
        var query = PhysicsRayQueryParameters3D.create(global_position, body.global_position)
        var result = space_state.intersect_ray(query)
        if result:
            faded_objects[body]["ray_result"] = result

func _on_body_entered(body):
    if body.is_in_group("fadable_walls"):
        faded_objects[body] = { "ray_result": null }

func _on_body_exited(body):
    if body.is_in_group("fadable_walls"):
        faded_objects.erase(body)
        disable_distance_fade(body)

func interpolate_max_distance(material: StandardMaterial3D, distance: float, duration: float = 0.3):
    var tween: Tween = get_tree().create_tween()
    tween.tween_property(material, "distance_fade_max_distance", distance, duration)

func disable_distance_fade(body: CollisionObject3D):
    var wall: MeshInstance3D = body.get_parent()
    var material: StandardMaterial3D = wall.get_active_material(0)
    interpolate_max_distance(material, 0.0)

func set_distance_fade(body: CollisionObject3D, distance: float):
    var wall: MeshInstance3D = body.get_parent()
    var material: StandardMaterial3D = wall.get_active_material(0)
    interpolate_max_distance(material, 25.0 - min(distance * 7.0, 25.0))

func set_zoom(new_zoom: float) -> void:
    if is_instance_valid(camera):
        camera.set_position(Vector3(
            starting_camera_position.x * new_zoom,
            starting_camera_position.y * new_zoom,
            0.0
        ))
