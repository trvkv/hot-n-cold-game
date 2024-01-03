@tool
extends Node3D

class_name ItemContainer

@export var container_mesh_scene: PackedScene: set = set_container, get = get_container

var container_mesh: MeshInstance3D

var inventory: ItemInventory

func create_container_instance() -> void:
    for child in get_children():
        remove_child(child)
        child.queue_free()

    if container_mesh_scene == null:
        return

    if container_mesh_scene.can_instantiate():
        container_mesh = container_mesh_scene.instantiate()
        if is_instance_valid(container_mesh):
            add_child(container_mesh)

func set_container(scene: PackedScene) -> void:
    container_mesh_scene = scene
    create_container_instance()

func get_container() -> PackedScene:
    return container_mesh_scene
