@tool
extends Node3D

class_name ItemContainer

@export var container_mesh_scene: PackedScene: set = set_container, get = get_container
@export var actions: Array[PlayerActions.ACTIONS] = [PlayerActions.ACTIONS.OPEN_CONTAINER]
@export var is_locked: bool = false
@export var item: ItemBase: set = set_item, get = get_item

@onready var inventory: ItemInventory = $ItemInventory
@onready var mesh: Node3D = $Mesh

var container_mesh: MeshInstance3D

func _ready() -> void:
    create_container_instance()
    if not Engine.is_editor_hint():
        set_item(item)

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

func set_container(scene: PackedScene) -> void:
    container_mesh_scene = scene
    create_container_instance()

func get_container() -> PackedScene:
    return container_mesh_scene

func set_item(item_to_set: ItemBase) -> void:
    item = item_to_set
    if Engine.is_editor_hint():
        return
    if not is_node_ready():
        return
    put(item)

func get_item():
    return item

func put(item_to_put: ItemBase) -> bool:
    if not is_instance_valid(inventory):
        return false

    if inventory.size() > 0:
        print("Inventory already contains an item!")
        return false

    if not inventory.has_item(item_to_put):
        inventory.add_item(item_to_put)
        return true
    return false

func peek(item_type: String = "") -> Array[ItemBase]:
    if not is_instance_valid(inventory):
        return []

    var items_in_inventory = inventory.get_items()
    if item_type.is_empty():
        return items_in_inventory
    return items_in_inventory.filter(func(i): return i.get_class_name() == item_type)

func retrieve(item_to_retrieve: ItemBase) -> bool:
    if inventory.has_item(item_to_retrieve):
        inventory.remove_item(item_to_retrieve)
        return true
    return false

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

func action_open_container(interaction_data: InteractionData) -> void:
    print("Opening container (", interaction_data.initiator, ")")
    interaction_data.response = {"items": peek()}
    interaction_data.is_successful = not is_locked

func action_lock_container(interaction_data: InteractionData) -> void:
    print("Locking container (", interaction_data.initiator, ")")
    interaction_data.is_successful = lock()

func action_unlock_container(interaction_data: InteractionData) -> void:
    print("Unlocking container (", interaction_data.initiator, ")")
    interaction_data.is_successful = unlock()

func action_put_to_container(interaction_data: InteractionData) -> void:
    print("Putting item to container (", interaction_data.initiator, ")")
    if "active_item" in interaction_data.request:
        var active_item = interaction_data.request["active_item"]
        interaction_data.is_successful = put(active_item)
        interaction_data.response = {"active_item": active_item}
        print("    ** Item => ", active_item)
    else:
        printerr("No active item selected, while putting item to container")
        interaction_data.is_successful = false

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
    return interaction_data.is_successful
