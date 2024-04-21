extends PanelContainer

@export var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.PLAYER_1
@export var interaction_gui: VBoxContainer
@export var action_holder_scene: PackedScene

var active_action: ActionHolder

func _ready():
    assert(is_instance_valid(interaction_gui), "Interaction gui instance invalid")
    assert(is_instance_valid(action_holder_scene), "Action holder instance invalid")
    EventBus.connect("switch_action", _on_action_switch)
    remove_actions()

func _on_action_switch(player: Player) -> void:
    if player.player_id == player_id:
        print("Player switched action ", player.player_id)
        # TODO: start from here. Implement switching actions

func add_action(action: PlayerActions.ACTIONS) -> void:
    var holder: ActionHolder = spawn_action_holder(false, action)
    interaction_gui.add_child(holder)

func set_active_action(action: PlayerActions.ACTIONS, active: bool = true) -> void:
    for child in interaction_gui.get_children():
        if child.action == action:
            child.set_active(active)
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

func remove_actions() -> void:
    for child in interaction_gui.get_children():
        interaction_gui.remove_child(child)
        child.queue_free()

func spawn_action_holder(active: bool, action: PlayerActions.ACTIONS) -> ActionHolder:
    var instance: ActionHolder = action_holder_scene.instantiate()
    instance.set_active(active)
    instance.set_action(action)
    return instance
