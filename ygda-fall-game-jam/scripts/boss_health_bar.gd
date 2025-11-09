extends AnimatedSprite2D
@onready var fade: AnimationPlayer = $Fade

var faded_in := false
func _process(delta: float) -> void:
	if faded_in:
		frame = ceil((1 - (float(Global.final_boss_health) / 48)) * 16)
	elif Global.wave_number == 4:
		frame = 0
		fade.play("fade_in")
		

func _on_fade_animation_finished(anim_name: StringName) -> void:
	faded_in = true
