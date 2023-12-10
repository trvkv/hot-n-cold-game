extends Sprite3D

var acc: float = 0.0
var current_frame: int = 0

@export var sprite_frames = 1

func _process(delta):
    acc += delta
    if acc > 1.0:
        acc -= 1.0
        current_frame += 1
        if current_frame < sprite_frames:
            frame = current_frame
        else:
            current_frame = 0
