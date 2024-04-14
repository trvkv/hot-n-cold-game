extends Object

class_name PlayerActions

enum ACTIONS {
    PUT_TO_CONTAINER,
    LOCK_CONTAINER,
    UNLOCK_CONTAINER,
    SET_TRAP,
    OPEN_CONTAINER
}

static func action_to_string(action: int) -> String:
    if action == ACTIONS.PUT_TO_CONTAINER:
        return "Put to container"
    elif action == ACTIONS.LOCK_CONTAINER:
        return "Lock container"
    elif action == ACTIONS.UNLOCK_CONTAINER:
        return "Unlock container"
    elif action == ACTIONS.SET_TRAP:
        return "Set trap"
    elif action == ACTIONS.OPEN_CONTAINER:
        return "Open container"
    printerr("Incorrect action ID: %d, returning null" % action)
    return ""

static func should_action_be_available(action, interactee) -> bool:

    # set trap doesn't require interactable object nearby
    if action == ACTIONS.SET_TRAP:
        return true

    # interactee/container related actions only, below

    if interactee == null:
        return false

    if not interactee.has_method("get_class_name"):
        return false

    if interactee.get_class_name() == &"ItemContainer":
        return true

    return false
