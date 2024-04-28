@tool
extends Node3D

class_name ItemContainer

@export var container_mesh_scene: PackedScene: set = set_container, get = get_container
@export var actions: Array[PlayerActions.ACTIONS] = [PlayerActions.ACTIONS.OPEN_CONTAINER]
@export var is_locked: bool = false

@onready var inventory: ItemInventory = $ItemInventory
@onready var mesh: Node3D = $Mesh

var container_mesh: MeshInstance3D

func _ready() -> void:
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

func set_container(scene: PackedScene) -> void:
    container_mesh_scene = scene
    create_container_instance()

func get_container() -> PackedScene:
    return container_mesh_scene

func put(item: ItemBase) -> bool:
    if not inventory.has_item(item):
        inventory.add_item(item)
        return true
    return false

func peek(item_type: String = "") -> Array:
    var items = inventory.get_items()
    if item_type.is_empty():
        return items
    return items.filter(func(i): return i.get_class_name() == item_type)

func retrieve(item: ItemBase) -> bool:
    if inventory.has_item(item):
        inventory.remove_item(item)
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

func interact(interactee, interactor, action) -> void:
    if interactee == self:
        if action == PlayerActions.ACTIONS.OPEN_CONTAINER:
            if is_locked:
                print("Container locked (", interactor, ")")
                return
            print("Items inside container: ", peek())
        elif action == PlayerActions.ACTIONS.LOCK_CONTAINER:
            print("Locking container (", interactor, ")")
            if not lock():
                print("Container already locked! (", interactor, ")")
        elif action == PlayerActions.ACTIONS.UNLOCK_CONTAINER:
            print("Unlocking container (", interactor, ")")
            if not unlock():
                print("Container already unlocked! (", interactor, ")")
        elif action == PlayerActions.ACTIONS.PUT_TO_CONTAINER:
            pass
    return
