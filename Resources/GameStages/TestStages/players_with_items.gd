extends GameStage

class_name TestPlayersWithItemsGameStage

@export var starting_items: Array[ItemBase]

func _init():
    super("Prepare players [test function]")

func enter() -> void:
    super()

    var items: Array[StringName] = []
    for item in starting_items:
        items.append(item.get_class_name())

    print("Starting with: ", items)

    call_function("set_player_inventory", [PlayersManager.PlayerID.PLAYER_1, items])
    call_function("set_player_inventory", [PlayersManager.PlayerID.PLAYER_2, items])
