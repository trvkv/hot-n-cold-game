extends Object

class_name PlayerActions

enum ACTIONS {
    INVALID,
    PUT_TO_CONTAINER,
    LOCK_CONTAINER,
    UNLOCK_CONTAINER,
    SET_TRAP,
    OPEN_CONTAINER,
    GET_FROM_CONTAINER
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
    elif action == ACTIONS.GET_FROM_CONTAINER:
        return "Get from container"
    printerr("Incorrect action ID: %d, returning null" % action)
    return ""
