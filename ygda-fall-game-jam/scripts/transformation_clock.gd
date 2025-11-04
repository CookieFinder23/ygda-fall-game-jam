extends AnimatedSprite2D

const TOTAL_FRAMES = 33
const TOTAL_SECONDS = 6

func _process(delta: float) -> void:
	frame = roundi((1 - (Global.player_reference.transformation_cooldown.time_left / TOTAL_SECONDS)) * TOTAL_FRAMES)
	visible = Global.wave_number > 1
