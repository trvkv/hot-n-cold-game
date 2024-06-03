extends PanelContainer

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1
@export var interaction_gui: VBoxContainer
@export var action_holder_scene: PackedScene

var active_action: ActionHolder

func _ready():
    assert(is_instance_valid(interaction_gui), "Interaction gui instance invalid")
    assert(is_instance_valid(action_holder_scene), "Action holder instance invalid")
    remove_actions()

func add_action(action: PlayerActions.ACTIONS) -> void:
    var holder: ActionHolder = spawn_action_holder(false, action)
    interaction_gui.add_child(holder)

func get_elements() -> Array:
    return interaction_gui.get_children()

func count_elements() -> int:
    return interaction_gui.get_children().size()

func get_actions() -> Array:
    var actions: Array = []
    for element in get_elements():
        actions.append(element.action)
    return actions

func set_active_action(action: PlayerActions.ACTIONS, active: bool = true) -> void:
    for holder in interaction_gui.get_children():
        if holder.action == action:
            holder.set_active(active)
            active_action = holder
            return

func get_active_action() -> PlayerActions.ACTIONS:
    var actions: Array = interaction_gui.get_children()
    if actions.size() == 0:
        return PlayerActions.ACTIONS.INVALID

    for action in actions:
        if action.is_active:
            return action.action

    return PlayerActions.ACTIONS.INVALID

func set_actions_inactive() -> void:
    for child in interaction_gui.get_children():
        child.set_active(false)
    active_action = null

func get_next_action_by_active() -> ActionHolder:
    if not is_instance_valid(active_action):
        return null

    var index = active_action.get_index()
    index += 1 # increase index
    if index < interaction_gui.get_child_count():
        return interaction_gui.get_child(index)
    return interaction_gui.get_child(0)

func remove_actions() -> void:
    for child in interaction_gui.get_children():
        interaction_gui.remove_child(child)
        child.queue_free()

func spawn_action_holder(active: bool, action: PlayerActions.ACTIONS) -> ActionHolder:
    var instance: ActionHolder = action_holder_scene.instantiate()
    instance.set_active(active)
    instance.set_action(action)
    return instance
