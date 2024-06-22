extends Node3D

class_name InputComponent

@export var action_input_prefix: String = ""

var mapping: Dictionary = {}


class InputMappingBuilder:

    static func default(input_prefix: String = "") -> Dictionary:
        var map = {}

        for input_action in InputMap.get_actions():
            if not input_action.begins_with(input_prefix):
                continue
            var action_name = input_action.trim_prefix(input_prefix)
            map[action_name] = StringName(input_action)

        return map


func _ready():
    mapping = InputMappingBuilder.default(action_input_prefix)

func send_action(_event: InputEventAction) -> void:
    pass

func translate_event_to_action(action_name: String, event: InputEvent) -> InputEventAction:
    var action = InputEventAction.new()
    action.action = action_name
    action.pressed = event.is_pressed()
    # should be fixed when Controller support will be introduced
    # action.strength = event.strength
    action.device = event.device
    return action

func translate_and_send_input(action_name: String, event: InputEvent) -> void:
    var action: InputEventAction = translate_event_to_action(action_name, event)
    send_action(action)

func find_associated_action(event: InputEvent) -> String:
    var detected_action: String = ""
    for action in mapping.keys():
        if InputMap.event_is_action(event, mapping[action]):
            detected_action = action
            break
    return detected_action

func _unhandled_input(event):
    # find which action was made
    var action_name: String = find_associated_action(event)
    if action_name.is_empty():
        return
    translate_and_send_input(action_name, event)
