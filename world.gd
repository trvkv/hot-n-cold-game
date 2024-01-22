extends Node3D

@onready var viewport_player_1: SubViewportContainer = $GridContainer/SubViewportContainer_P1
@onready var viewport_player_2: SubViewportContainer = $GridContainer/SubViewportContainer_P2


func _ready():
	CameraManager.set_active_cameras(CameraManager.CameraType.PLAYER_1 | CameraManager.CameraType.PLAYER_2)

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_home"):
		CameraManager.set_active_cameras(CameraManager.CameraType.PLAYER_1 | CameraManager.CameraType.PLAYER_2)
		viewport_player_1.set_visible(true)
		viewport_player_2.set_visible(true)
	elif event.is_action_pressed("ui_end"):
		CameraManager.set_active_cameras(CameraManager.CameraType.GLOBAL)
		viewport_player_1.set_visible(false)
		viewport_player_2.set_visible(false)
