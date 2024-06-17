extends RefCounted

class_name PlayerInventory

var player_id: PlayersManager.PlayerID = PlayersManager.PlayerID.NONE
var inventory: ItemInventory = ItemInventory.new()
var is_locked: bool = false
var is_opened: bool = false
