extends Node

enum CameraType { PLAYER_1 = 1, PLAYER_2 = 2, GLOBAL = 4 }

var cameras = {
    CameraType.PLAYER_1: null,
    CameraType.PLAYER_2: null,
    CameraType.GLOBAL: null
}

func camera_to_name(camera_type: CameraType) -> String:
    if camera_type == CameraType.PLAYER_1:
        return "PLAYER_1"
    if camera_type == CameraType.PLAYER_2:
        return "PLAYER_2"
    if camera_type == CameraType.GLOBAL:
        return "GLOBAL"
    return "UNKNOWN"

func register_camera(camera_type: CameraType, camera_object: Camera3D) -> void:
    assert(camera_type in cameras.keys(), "No such camera type: " + str(camera_type))
    assert(cameras[camera_type] == null, camera_to_name(camera_type) + " camera already registered!")
    cameras[camera_type] = camera_object
    camera_object.clear_current(false)
    print("Registering camera (", camera_to_name(camera_type), "): ", camera_object)

func set_active_cameras(camera_types: int) -> void:
    for type in cameras.keys():
        var camera = type & camera_types
        if camera > 0:
            assert(cameras[type] != null, "Camera doesn't exists, cannot set active.")
            print("Current camera (", camera_to_name(type), "): ", cameras[type])
            cameras[type].make_current()
        else:
            print("Clearing camera (", camera_to_name(type), "): ", cameras[type])
            cameras[type].clear_current(false)
