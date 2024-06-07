extends Node

enum CameraType { PLAYER = 1, PREVIEW = 2, GLOBAL = 4 }

var registered_cameras = {}

var camera_counter: int = 0

func camera_to_name(camera_type: CameraType) -> String:
    if camera_type == CameraType.PLAYER:
        return "PLAYER"
    if camera_type == CameraType.GLOBAL:
        return "GLOBAL"
    if camera_type == CameraType.PREVIEW:
        return "PREVIEW"
    return "UNKNOWN"

func register_camera(camera_owner: Node, camera_type: CameraType, camera_object: Camera3D) -> int:
    assert(camera_type in CameraType.values(), "No such camera type: " + str(camera_type))
    var uuid = camera_counter
    registered_cameras[uuid] = {
        "owner": camera_owner,
        "type": camera_type,
        "camera": camera_object
    }
    camera_object.clear_current(false)
    print("Registering camera (", camera_to_name(camera_type), "): as ", uuid, " ", camera_object)
    camera_counter += 1
    return uuid

func activate_camera(uuid: int) -> void:
    if uuid in registered_cameras.keys():
        registered_cameras[uuid]["camera"].make_current()

func deactivate_camera(uuid: int) -> void:
    if uuid in registered_cameras.keys():
        registered_cameras[uuid]["camera"].clear_current(false)
