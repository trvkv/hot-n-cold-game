extends Node3D

class_name SceneLoader

enum SCENE {
    MAIN_MENU,
    ADJUSTMENTS,
    GAME_WORLD,
    SUMMARY
}

const SCENE_LIST: Dictionary = {
    SCENE.MAIN_MENU: "res://Scenes/GUI/main_menu.tscn",
    SCENE.ADJUSTMENTS: "res://Scenes/GUI/adjustments_menu.tscn",
    SCENE.GAME_WORLD: "res://Scenes/game_world.tscn",
    SCENE.SUMMARY: "res://Scenes/GUI/winner_highlight.tscn"
}

static func get_scene(scene: SCENE) -> PackedScene:
    if not scene in SCENE_LIST.keys():
        printerr("Scene ", scene, " not present in scene list")
        return null
    return load(SCENE_LIST[scene])
