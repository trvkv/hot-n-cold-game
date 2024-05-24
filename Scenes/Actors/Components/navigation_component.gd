extends Node3D

var movement_target_position: Vector3 = Vector3(0.0, 0.0, 0.0)

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready() -> void:
    randomize()
    navigation_agent.path_desired_distance = 0.5
    navigation_agent.target_desired_distance = 0.5
    navigation_agent.debug_path_custom_color = Color(abs(randf()), abs(randf()), abs(randf()), 1.0)
    call_deferred("actor_setup")

func actor_setup() -> void:
    await get_tree().physics_frame
    set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector3):
    navigation_agent.set_target_position(movement_target)

func _physics_process(_delta) -> void:
    if navigation_agent.is_navigation_finished():
        return
    var path = navigation_agent.get_current_navigation_path()
    print(path)
    set_movement_target(movement_target_position)
