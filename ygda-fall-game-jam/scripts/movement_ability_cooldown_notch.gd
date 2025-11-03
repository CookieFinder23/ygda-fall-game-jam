extends ProgressBar

func _physics_process(delta: float) -> void:
	var timer_to_use
	var invert
	if Global.player_reference.movement_ability_in_action.is_stopped():
		timer_to_use = Global.player_reference.movement_ability_cooldown
		invert = true
	else:
		timer_to_use = Global.player_reference.movement_ability_in_action
		invert = false
	
	if invert == true:
		value = clamp(1 - timer_to_use.time_left / timer_to_use.wait_time, 0, 0.97)
	else:
		value = clamp(timer_to_use.time_left / timer_to_use.wait_time, 0, 0.97)
