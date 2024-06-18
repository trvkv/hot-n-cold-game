extends Resource

class_name GameStage

@export var next_stage: GameStage

# Each container has few inventories: one for each player.
# During the item hiding stage (prepare_player_*_stage.tres)
# player is using it's own container inventory.
# But, during gameplay, player is searching through his opponent
# inventory when opening containers. This option is used to
# adjust this behaviour on per-stage basis.
@export var reverse_container_inventory_search: bool = false

# if set to "true", when favourite item will be placed in
# the container it's position will save in GameState, otherwise
# it will be ignored. This setting should be 'true' in preparation
# stages, but 'false' during the gameplay.
@export var save_favourite_items: bool = false

var stage_name: String

signal get_function_ref(function_ref_container)

enum ACTIONS { ENTERED = 1, EXITED = 2 }

class FunctionRefContainer:
    var sender: Object
    var function_name: String
    var arguments: Array
    var callback: Callable

    func _init(sender_: Object, function_name_: String, arguments_: Array):
        sender = sender_
        function_name = function_name_
        arguments = arguments_

func _init(stage_name_: String) -> void:
    stage_name = stage_name_

func enter() -> void:
    print("Entering game stage: ", stage_name)

func exit() -> void:
    print("Exiting game stage: ", stage_name)

func update(_delta: float) -> void:
    pass

func call_function(function: String, arguments: Array = []):
    var function_container = FunctionRefContainer.new(self, function, arguments)
    emit_signal("get_function_ref", function_container)
    if function_container.sender != self:
        return
    if not function_container.callback is Callable:
        return
    if not function_container.callback.is_valid():
        printerr("Callback invalid: ", function_container.callback)
        return
    return function_container.callback.callv(arguments)
