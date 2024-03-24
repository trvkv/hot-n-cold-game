extends Object

class_name ItemActions

enum ACTIONS {
    PUT_TO_CONTAINER,
    LOCK_CONTAINER,
    UNLOCK_CONTAINER,
    SET_TRAP
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
    printerr("Incorrect action ID: %d, returning null" % action)
    return ""
