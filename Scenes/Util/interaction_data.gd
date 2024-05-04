extends RefCounted

class_name InteractionData

var player_id: int = -1

var action: PlayerActions.ACTIONS = PlayerActions.ACTIONS.INVALID
var is_successful: bool = false

var initiator: Object = null
var target: Object = null

var request: Dictionary = {}
var response: Dictionary = {}
