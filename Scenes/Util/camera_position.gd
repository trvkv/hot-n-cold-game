extends Node3D

@onready var collision_area = $Area3D

var faded_objects: Dictionary

func _ready():
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

func disable_distance_fade(body: CollisionObject3D):
    var wall: MeshInstance3D = body.get_parent()
    var material: StandardMaterial3D = wall.get_active_material(0)
    # DISABLE HERE

func set_distance_fade(body: CollisionObject3D, distance: float):
    var wall: MeshInstance3D = body.get_parent()
    var material: StandardMaterial3D = wall.get_active_material(0)
    print(distance)
    # ENABLE HERE
