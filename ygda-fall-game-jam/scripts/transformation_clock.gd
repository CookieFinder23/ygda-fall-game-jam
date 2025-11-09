extends AnimatedSprite2D

const TOTAL_FRAMES = 17
const TOTAL_SECONDS = 6

var played: bool = false
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _process(delta: float) -> void:
	frame = roundi( (1 - (Global.player_reference.transformation_cooldown.time_left / TOTAL_SECONDS)) * TOTAL_FRAMES) - 1
	visible = Global.wave_number > 1
	if visible and (frame == 12 or frame == 14 or frame == 16):
		if not played:
			played = true
			audio_stream_player_2d.play()
	else:
		played = false
	if frame == 16:
		position.x = 573
	else:
		position.x = 570
