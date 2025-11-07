extends AnimatedSprite2D

const TOTAL_FRAMES = 19
const TOTAL_SECONDS = 6
const FRAME_OFFSET = -1

func _process(delta: float) -> void:
	frame = wrap(roundi(1 - (Global.player_reference.transformation_cooldown.time_left / TOTAL_SECONDS) * TOTAL_FRAMES) + FRAME_OFFSET, 0, TOTAL_FRAMES - 1)
	visible = Global.wave_number > 1
