extends Area3D

class_name Trap

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var timer_transparency: Timer = $TimerTransparency
@onready var timer_death: Timer = $TimerDeath
@onready var particles: GPUParticles3D = $GPUParticles3D

var player_id: PlayersManager.PlayerID

var player_caught: Player
var is_bonked: bool = false

func _ready() -> void:
    assert(mesh_instance, "Mesh instance invalid")
    assert(timer_transparency, "Timer for transparency invalid")
    assert(timer_death, "Timer for death invalid")
    assert(particles, "Particles invalid")
    connect("body_entered", _on_body_entered)
    timer_death.connect("timeout", _on_timer_death_timeout)
    timer_transparency.connect("timeout", _on_timer_transparency_timeout)
    timer_transparency.start()

func _on_body_entered(body: Node) -> void:
    if is_bonked:
        return

    var player: Player = body as Player
    if is_instance_valid(player):
        if player_id != player.player_id:
            player_caught = player
            player_caught.freeze()
            particles.emitting = true
            is_bonked = true
            timer_death.start()

func _on_timer_transparency_timeout() -> void:
    var tween: Tween = create_tween()
    tween.tween_property(mesh_instance, "transparency", 1.0, 1.0)

func _on_timer_death_timeout() -> void:
    player_caught.unfreeze()
    particles.emitting = false
    queue_free()
