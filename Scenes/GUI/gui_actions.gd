extends PanelContainer

@export var interaction_gui: VBoxContainer
@export var action_holder_scene: PackedScene

func _ready():
    assert(is_instance_valid(interaction_gui), "Interaction gui instance invalid")
    assert(is_instance_valid(action_holder_scene), "Action holder instance invalid")

    clear_actions()

func add_action(action: PlayerActions.ACTIONS) -> void:
    var holder: ActionHolder = spawn_action_holder(false, action)
    interaction_gui.add_child(holder)

func set_action_active(action: PlayerActions.ACTIONS, active: bool = true) -> void:
    for child in interaction_gui.get_children():
        if child.action == action:
            child.set_active(active)

func clear_actions() -> void:
    for child in interaction_gui.get_children():
        interaction_gui.remove_child(child)
        child.queue_free()

func spawn_action_holder(active: bool, action: PlayerActions.ACTIONS) -> ActionHolder:
    var instance: ActionHolder = action_holder_scene.instantiate()
    instance.set_active(active)
    instance.set_action(action)
    return instance
