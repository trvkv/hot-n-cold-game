@tool
extends Node3D

class_name ItemContainer

@export var container_mesh_scene: PackedScene: set = set_container, get = get_container
@export var actions: Array[PlayerActions.ACTIONS] = [PlayerActions.ACTIONS.OPEN_CONTAINER]
@export var is_locked: bool = false

@onready var mesh: Node3D = $Mesh

var inventories: Array[PlayerInventory] = []
var is_opened: bool = false

var container_mesh: MeshInstance3D

func _ready() -> void:
    for player_id in PlayersManager.PlayerID:
        var player_inventory: PlayerInventory = PlayerInventory.new()
        player_inventory.player_id = player_id
        inventories.append(player_inventory)
    create_container_instance()

func get_class_name() -> StringName:
    return &"ItemContainer"

func create_container_instance() -> void:
    if not is_instance_valid(mesh):
        return

    for child in mesh.get_children():
        remove_child(child)
        child.queue_free()

    if container_mesh_scene == null:
        return

    if container_mesh_scene.can_instantiate():
        container_mesh = container_mesh_scene.instantiate()
        if is_instance_valid(container_mesh):
            mesh.add_child(container_mesh)
            if is_instance_valid(container_mesh.collision_body):
                container_mesh.collision_body.add_to_group("containers")
                # setting owner to the "topmost" parent. It could be then retrieved
                # inside 'interaction area' during collision detection
                container_mesh.collision_body.set_owner(self)
                EventBus.connect("update_interactees", _on_update_interactees)
            else:
                printerr("Mesh collision body is invalid: ", container_mesh)
        else:
            printerr("Mesh instance is invalid: ", container_mesh)

func _on_update_interactees(_player, interactees, active_interactee) -> void:
    if is_instance_valid(container_mesh):
        if active_interactee == self:
            container_mesh.get_active_material(0).albedo_color = Color(0.0, 0.0, 0.0)
        elif self in interactees:
            container_mesh.get_active_material(0).albedo_color = Color(0.8, 0.8, 0.8)
        else:
            container_mesh.get_active_material(0).albedo_color = Color(1.0, 1.0, 1.0)
    else:
        printerr("Mesh container or collision body invalid for ", self)

func set_container(scene: PackedScene) -> void:
    container_mesh_scene = scene
    create_container_instance()

func get_container() -> PackedScene:
    return container_mesh_scene

func get_inventory(player_id: PlayersManager.PlayerID) -> ItemInventory:
    if inventories == null:
        printerr("Container inventories invalid: ", inventories, ", container: ", self)
        return null
    for player_inventory: PlayerInventory in inventories:
        if is_instance_valid(player_inventory):
            if player_inventory.player_id == player_id:
                return player_inventory.inventory
    printerr("Inventory for player ", player_id, " not found")
    return null

func put(player_id: PlayersManager.PlayerID, item_to_put: ItemBase) -> bool:
    var inventory: ItemInventory = get_inventory(player_id)
    print("Inventory: ", inventory)
    if not is_instance_valid(inventory):
        printerr("Inventory object invalid")
        return false

    if inventory.size() > 0:
        printerr("Inventory already contains an item!")
        return false

    if not inventory.has_item(item_to_put):
        inventory.add_item(item_to_put)
        return true
    return false

func peek(player_id: PlayersManager.PlayerID) -> ItemBase:
    var inventory: ItemInventory = get_inventory(player_id)

    if not is_instance_valid(inventory):
        return null

    var items_in_inventory = inventory.get_items()
    if items_in_inventory.size() > 0:
        # return first element when size is greater than 0
        return items_in_inventory[0]

    return null

func retrieve(player_id: PlayersManager.PlayerID) -> ItemBase:
    var item_to_retrieve = peek(player_id)
    if is_instance_valid(item_to_retrieve):
        var inventory: ItemInventory = get_inventory(player_id)
        if not is_instance_valid(inventory):
            return null
        inventory.remove_item(item_to_retrieve)
        return item_to_retrieve
    return null

func lock() -> bool:
    if not is_locked:
        is_locked = true
        return true
    return false

func unlock() -> bool:
    if is_locked:
        is_locked = false
        return true
    return false

func store_item_state(player_id: PlayersManager.PlayerID, data_type: GameStateTypes.TYPES, data) -> void:
    var state := GameStateTypes.GameStateData.new(player_id, data_type, data)
    EventBus.emit_signal("store_game_state", state)

func add_item_state(player_id: PlayersManager.PlayerID, data_type: GameStateTypes.TYPES, data) -> void:
    var state := GameStateTypes.GameStateData.new(player_id, data_type)
    EventBus.emit_signal("retrieve_game_state", state)
    store_item_state(player_id, data_type, data)

func action_open_container(interaction_data: InteractionData) -> void:
    print("Opening container (", interaction_data.initiator, ")")
    interaction_data.response = {"items": peek(interaction_data.player_id)}
    interaction_data.is_successful = not is_locked
    is_opened = not is_locked

func action_lock_container(interaction_data: InteractionData) -> void:
    print("Locking container (", interaction_data.initiator, ")")
    if "active_item" in interaction_data.request:
        var active_item: ItemKey = interaction_data.request["active_item"]
        if is_instance_valid(active_item):
            interaction_data.response = {"active_item": active_item}
            var key_not_used: bool = (active_item.is_used_by == null)
            if key_not_used:
                interaction_data.is_successful = lock()
                active_item.is_used_by = interaction_data.target
            else:
                interaction_data.is_successful = false

func action_unlock_container(interaction_data: InteractionData) -> void:
    print("Unlocking container (", interaction_data.initiator, ")")
    if "active_item" in interaction_data.request:
        var active_item: ItemKey = interaction_data.request["active_item"]
        if is_instance_valid(active_item):
            interaction_data.response = {"active_item": active_item}
            var same_key: bool = (active_item.is_used_by == interaction_data.target)
            if same_key:
                interaction_data.is_successful = unlock()
                active_item.is_used_by = null
            else:
                interaction_data.is_successful = false

func action_put_to_container(interaction_data: InteractionData) -> void:
    print("Putting item to container (", interaction_data.initiator, ")")
    if "active_item" in interaction_data.request:
        var active_item: ItemBase = interaction_data.request["active_item"]
        interaction_data.response = {"active_item": active_item}
        if is_opened and not is_locked:
            interaction_data.is_successful = put(interaction_data.player_id, active_item)
        else:
            interaction_data.is_successful = false

        # change game state only when putting item to container was successful
        if interaction_data.is_successful:
            var player_id = interaction_data.initiator.player_id
            if active_item.get_class_name() == &"ItemFavourite":
                store_item_state(player_id, GameStateTypes.TYPES.FAVOURITE_ITEM_CONTAINER, self)
            elif active_item.get_class_name() == &"ItemKey":
                var data := GameStateTypes.GameStateItem.new(active_item, self)
                add_item_state(player_id, GameStateTypes.TYPES.KEY_ITEM_CONTAINER, data)
    else:
        printerr("No active item selected, while putting item to container")
        interaction_data.is_successful = false

func action_get_from_container(interaction_data: InteractionData) -> void:
    print("Getting item from container (", interaction_data.initiator, ")")
    interaction_data.is_successful = is_opened
    if interaction_data.is_successful:
        if peek(interaction_data.player_id) != null:
            interaction_data.response = {"item": retrieve(interaction_data.player_id)}
        else:
            print("Container is empty!")
    else:
        print("Container closed! Open it first.")

func interact(interaction_data: InteractionData) -> bool:
    if interaction_data.target == self:
        if interaction_data.action == PlayerActions.ACTIONS.OPEN_CONTAINER:
            action_open_container(interaction_data)
        elif interaction_data.action == PlayerActions.ACTIONS.LOCK_CONTAINER:
            action_lock_container(interaction_data)
        elif interaction_data.action == PlayerActions.ACTIONS.UNLOCK_CONTAINER:
            action_unlock_container(interaction_data)
        elif interaction_data.action == PlayerActions.ACTIONS.PUT_TO_CONTAINER:
            action_put_to_container(interaction_data)
        elif interaction_data.action == PlayerActions.ACTIONS.GET_FROM_CONTAINER:
            action_get_from_container(interaction_data)
    return interaction_data.is_successful
