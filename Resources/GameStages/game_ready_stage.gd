extends GameStage

class_name GameReadyStage

@export var countdown_time: float = 10.0

var timer_started: bool = false
var time_elapsed: float = 0.0

func _init():
    super("Game ready")

func enter() -> void:
    super()
    print("Game ready! Counting...")
    call_function("hide_player_container", [PlayersManager.PlayerID.PLAYER_1])
    call_function("hide_player_container", [PlayersManager.PlayerID.PLAYER_2])
    call_function("freeze", [PlayersManager.PlayerID.PLAYER_1, true])
    call_function("freeze", [PlayersManager.PlayerID.PLAYER_2, true])
    call_function("set_global_message", [""])
    timer_started = true

func exit() -> void:
    call_function("freeze", [PlayersManager.PlayerID.PLAYER_1, false])
    call_function("freeze", [PlayersManager.PlayerID.PLAYER_2, false])
    call_function("show_player_container", [PlayersManager.PlayerID.PLAYER_1])
    call_function("show_player_container", [PlayersManager.PlayerID.PLAYER_2])
    call_function("set_global_message", [""])

func update(delta: float) -> void:
    if not timer_started:
        return

    time_elapsed += delta
    var time_left = countdown_time - time_elapsed

    if time_left < 0.0:
        timer_started = false
        call_function("load_next_game_stage")
        return

    call_function("set_global_message", ["%d" % int(time_left)])
