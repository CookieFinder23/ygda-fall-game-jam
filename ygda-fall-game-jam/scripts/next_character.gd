extends AnimatedSprite2D

var character_enum_to_animation = {
	0: "hunter",
	1: "knight",
	2: "ice_mage",
	3: "ninja"
}

func _physics_process(delta: float) -> void:
	if Global.wave_number > 1:
		visible = true
		if animation != character_enum_to_animation[Global.player_reference.next_character]:
			play(character_enum_to_animation[Global.player_reference.next_character])
	else:
		visible = false	
	
