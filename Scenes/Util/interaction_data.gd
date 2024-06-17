extends RefCounted

class_name InteractionData

var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.NONE

var action: PlayerActions.ACTIONS = PlayerActions.ACTIONS.INVALID
var is_successful: bool = false

var initiator: Object = null
var target: Object = null

var reverse_container_inventory_search: bool = false

var request: Dictionary = {}
var response: Dictionary = {}
