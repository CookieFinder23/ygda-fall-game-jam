extends AnimatedSprite2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.player_reference.movement_ability_in_action.is_stopped():
		frame = roundi(Global.player_reference.movement_ability_cooldown.time_left / Global.player_reference.movement_ability_cooldown.wait_time * 62)
	else:
		frame = roundi((1 - (Global.player_reference.movement_ability_in_action.time_left / Global.player_reference.movement_ability_in_action.wait_time)) * 62)
