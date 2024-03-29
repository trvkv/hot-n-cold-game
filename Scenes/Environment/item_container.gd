@tool
extends Node3D

class_name ItemContainer

@export var container_mesh_scene: PackedScene: set = set_container, get = get_container

@onready var inventory: ItemInventory = $ItemInventory
@onready var mesh: Node3D = $Mesh

var container_mesh: MeshInstance3D

func _ready() -> void:
    create_container_instance()

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
                EventBus.connect("update_interactees", _on_update_interactees)
                EventBus.connect("interact", _on_interact)
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

func _on_update_interactees(_player, interactees, active_interactee) -> void:
    if is_instance_valid(container_mesh) and is_instance_valid(container_mesh.collision_body):
        if active_interactee == container_mesh.collision_body:
            container_mesh.get_active_material(0).albedo_color = Color(0.0, 0.0, 0.0)
        elif container_mesh.collision_body in interactees:
            container_mesh.get_active_material(0).albedo_color = Color(0.8, 0.8, 0.8)
        else:
            container_mesh.get_active_material(0).albedo_color = Color(1.0, 1.0, 1.0)

func _on_interact(interactee, interactor) -> void:
    if is_instance_valid(container_mesh) and is_instance_valid(container_mesh.collision_body):
        if interactee == container_mesh.collision_body:
            print(self, ": Interacted with ", interactor)
