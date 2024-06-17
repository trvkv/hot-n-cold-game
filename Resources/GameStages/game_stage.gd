extends Resource

class_name GameStage

@export var next_stage: GameStage

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
