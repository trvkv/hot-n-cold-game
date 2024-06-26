extends RefCounted

class_name InteractionData

var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.NONE

var action: PlayerActions.ACTIONS = PlayerActions.ACTIONS.INVALID
var is_successful: bool = false

var initiator: Object = null
var target: Object = null

var request: Dictionary = {}
var response: Dictionary = {}

func _to_string():
    return "InteractionData(" + PlayerActions.action_to_string(action) + "): " + str(is_successful)
