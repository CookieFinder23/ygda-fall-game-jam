extends AnimatedSprite2D

const TOTAL_FRAMES = 17
const TOTAL_SECONDS = 6

var played: bool = false
@onready var tick_audio: AudioStreamPlayer2D = $TickAudio

func _process(delta: float) -> void:
	frame = roundi( (1 - (Global.player_reference.transformation_cooldown.time_left / TOTAL_SECONDS)) * TOTAL_FRAMES) - 1
	visible = Global.wave_number > 1
	if visible and (frame == 10 or frame == 12 or frame == 14):
		if not played:
			played = true
			tick_audio.play()
	else:
		played = false
	if frame == 16:
		position.x = 573
	else:
		position.x = 570
