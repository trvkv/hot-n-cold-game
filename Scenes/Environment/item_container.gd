@tool
extends Node3D

class_name ItemContainer

@export var container_mesh_scene: PackedScene: set = set_container, get = get_container
@export var actions: Array[PlayerActions.ACTIONS] = [PlayerActions.ACTIONS.OPEN_CONTAINER]

@export var container_material: StandardMaterial3D
@export var highlight_scale: float = 1.03
@export var highlight_transparency: float = 0.95
@export var highlight_material: StandardMaterial3D

@onready var mesh: Node3D = $Mesh
@onready var in_editor: Node3D = $"in-editor"

var inventories: Dictionary = {}

var container_mesh: MeshInstance3D
var highlight_mesh: MeshInstance3D
var game_stage: GameStage

func _ready() -> void:
    for player_id in PlayersManager.PlayerID.values():
        var player_inventory: PlayerInventory = PlayerInventory.new()
        player_inventory.player_id = player_id
        inventories[player_id] = player_inventory
    EventBus.connect("update_game_stage", _on_update_game_stage)
    create_container_instance()

    if not Engine.is_editor_hint():
        if is_instance_valid(in_editor):
            remove_child(in_editor)
            in_editor.queue_free()

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

    if not container_mesh_scene.can_instantiate():
        printerr("Cannot instantiate container mesh scene")
        return

    container_mesh = container_mesh_scene.instantiate()
    if not is_instance_valid(container_mesh):
        printerr("Mesh instance is invalid: ", container_mesh)
        return

    container_mesh.set_surface_override_material(0, container_material)
    mesh.add_child(container_mesh)

    if not is_instance_valid(container_mesh.collision_body):
        printerr("Mesh collision body is invalid: ", container_mesh)
        return

    container_mesh.collision_body.add_to_group("containers")
    # setting owner to the "topmost" parent. It could be then retrieved
    # inside 'interaction area' during collision detection
    container_mesh.collision_body.set_owner(self)

    highlight_mesh = container_mesh_scene.instantiate()
    var new_scale: Vector3 = highlight_mesh.get_scale() * highlight_scale
    highlight_mesh.set_scale(new_scale)
    highlight_mesh.set_transparency(1.0)
    highlight_mesh.set_surface_override_material(0, highlight_material)
    mesh.add_child(highlight_mesh)

    EventBus.connect("update_interactees", _on_update_interactees)

func _on_update_game_stage(action: GameStage.ACTIONS, stage: GameStage) -> void:
    if action == GameStage.ACTIONS.ENTERED:
        game_stage = stage
    elif action == GameStage.ACTIONS.EXITED:
        game_stage = null

func _on_update_interactees(_player, interactees, active_interactee) -> void:

    if not is_instance_valid(container_mesh):
        printerr("Mesh container or collision body invalid for ", self)
        return

    if active_interactee == self:
        highlight_mesh.set_transparency(0.70)
    elif self in interactees:
        highlight_mesh.set_transparency(0.95)
    else:
        highlight_mesh.set_transparency(1.0)

func set_container(scene: PackedScene) -> void:
    container_mesh_scene = scene
    create_container_instance()

func get_container() -> PackedScene:
    return container_mesh_scene

func get_player_inventory(player_id: PlayersManager.PlayerID) -> PlayerInventory:
    if not inventories.has(player_id):
        printerr("Inventory for player ", player_id, " not found")
        return null
    return inventories[player_id]

func get_inventory(player_id: PlayersManager.PlayerID) -> ItemInventory:
    var player_inventory: PlayerInventory = get_player_inventory(player_id)
    if is_instance_valid(player_inventory):
        return player_inventory.inventory
    return null

func put(player_id: PlayersManager.PlayerID, item_to_put: ItemBase) -> bool:
    var inventory: ItemInventory = get_inventory(player_id)
    if not is_instance_valid(inventory):
        printerr("Inventory object invalid")
        return false

    if inventory.size() > 0:
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

func lock(player_id: PlayersManager.PlayerID) -> bool:
    var inventory: PlayerInventory = get_player_inventory(player_id)
    if not is_instance_valid(inventory):
        printerr("Player inventory invalid")
        return false
    if not inventory.is_locked:
        inventory.is_locked = true
        return true
    return false

func unlock(player_id: PlayersManager.PlayerID) -> bool:
    var inventory: PlayerInventory = get_player_inventory(player_id)
    if not is_instance_valid(inventory):
        printerr("Player inventory invalid")
        return false
    if inventory.is_locked:
        inventory.is_locked = false
        return true
    return false

func store_item_state(player_id: PlayersManager.PlayerID, data_type: GameStateTypes.TYPES, data) -> void:
    var state := GameStateTypes.GameStateData.new(player_id, data_type, data)
    EventBus.emit_signal("store_game_state", state)

func add_item_state(player_id: PlayersManager.PlayerID, data_type: GameStateTypes.TYPES, data) -> void:
    var state := GameStateTypes.GameStateData.new(player_id, data_type)
    EventBus.emit_signal("retrieve_game_state", state)
    store_item_state(player_id, data_type, data)

func decide_player_id(interaction_data: InteractionData) -> PlayersManager.PlayerID:
    var player_id: PlayersManager.PlayerID = interaction_data.player_id
    if game_stage == null:
        printerr("Game stage is null, returning player ID: ", player_id)
        return player_id
    if game_stage.reverse_container_inventory_search:
        player_id = PlayersManager.get_opponent_id(interaction_data.player_id)
    return player_id

func action_open_container(interaction_data: InteractionData) -> void:
    print("Opening container (", interaction_data.initiator, ")")
    var player_id: PlayersManager.PlayerID = decide_player_id(interaction_data)
    var inventory: PlayerInventory = get_player_inventory(player_id)
    if not is_instance_valid(inventory):
        printerr("Player inventory invalid")
        return
    interaction_data.response = {"items": peek(player_id)}
    if inventory.is_locked:
        interaction_data.is_successful = false
        inventory.is_opened = false
        interaction_data.response["error_message"] = "Container is locked"
    else:
        interaction_data.is_successful = true
        inventory.is_opened = true

func action_lock_container(interaction_data: InteractionData) -> void:
    print("Locking container (", interaction_data.initiator, ")")
    if "active_item" in interaction_data.request:
        var active_item: ItemKey = interaction_data.request["active_item"]
        if active_item != null and active_item is ItemKey:
            interaction_data.response["active_item"] = active_item
            var key_not_used: bool = (active_item.is_used_by == null)
            if key_not_used:
                var player_id: PlayersManager.PlayerID = decide_player_id(interaction_data)
                var success: bool = lock(player_id)
                if success:
                    interaction_data.is_successful = true
                    active_item.is_used_by = interaction_data.target
                    interaction_data.response["success_message"] = "Container locked"
                else:
                    interaction_data.is_successful = false
                    interaction_data.response["error_message"] = "Container already locked"
            else:
                interaction_data.is_successful = false
                interaction_data.response["error_message"] = "Container already locked"

func action_unlock_container(interaction_data: InteractionData) -> void:
    print("Unlocking container (", interaction_data.initiator, ")")
    if "active_item" in interaction_data.request:
        var active_item: ItemKey = interaction_data.request["active_item"]
        if is_instance_valid(active_item):
            interaction_data.response = {"active_item": active_item}
            var same_key: bool = (active_item.is_used_by == interaction_data.target)
            if same_key:
                var player_id: PlayersManager.PlayerID = decide_player_id(interaction_data)
                var success: bool = unlock(player_id)
                if success:
                    interaction_data.is_successful = true
                    active_item.is_used_by = null
                    interaction_data.response["success_message"] = "Container unlocked"
                else:
                    interaction_data.is_successful = false
                    interaction_data.response["error_message"] = "Container already unlocked"
            else:
                interaction_data.is_successful = false
                interaction_data.response["error_message"] = "Container was locked with different key"

func action_put_to_container(interaction_data: InteractionData) -> void:
    print("Putting item to container (", interaction_data.initiator, ")")
    if "active_item" in interaction_data.request:
        var active_item: ItemBase = interaction_data.request["active_item"]
        interaction_data.response = {"active_item": active_item}
        var player_id: PlayersManager.PlayerID = decide_player_id(interaction_data)
        var inventory: PlayerInventory = get_player_inventory(player_id)
        if inventory.is_locked:
            interaction_data.is_successful = false
            interaction_data.response["error_message"] = "Container is locked"
            return

        if not inventory.is_opened:
            interaction_data.is_successful = false
            interaction_data.response["error_message"] = "Open the container first"
            return

        var success: bool = put(player_id, active_item)
        if not success:
            interaction_data.is_successful = false
            interaction_data.response["error_message"] = "Container is full"
            return

        interaction_data.is_successful = true

        # change game state only when putting item to container was successful
        if game_stage == null:
            printerr("Game stage is null")
            return

        if game_stage.save_favourite_items:
            player_id = interaction_data.initiator.player_id
            if active_item.get_class_name() == &"ItemFavourite":
                store_item_state(player_id, GameStateTypes.TYPES.FAVOURITE_ITEM_CONTAINER, self)
    else:
        printerr("No active item selected, while putting item to container")
        interaction_data.is_successful = false

func action_get_from_container(interaction_data: InteractionData) -> void:
    print("Getting item from container (", interaction_data.initiator, ")")
    var player_id: PlayersManager.PlayerID = decide_player_id(interaction_data)
    var inventory: PlayerInventory = get_player_inventory(player_id)
    if not is_instance_valid(inventory):
        printerr("Player inventory invalid")
        return

    if not inventory.is_opened:
        interaction_data.is_successful = false
        interaction_data.response["error_message"] = "Open container first"
        return

    var item: ItemBase = peek(player_id)
    if item == null:
        interaction_data.is_successful = false
        interaction_data.response["error_message"] = "Container is empty!"
        return

    interaction_data.is_successful = true
    interaction_data.response = {"item": retrieve(player_id)}

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
