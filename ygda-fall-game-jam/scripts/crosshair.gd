extends AnimatedSprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	global_position = get_global_mouse_position()
	global_position.x = clamp(global_position.x, 156, 484)
	global_position.y = clamp(global_position.y, 16, 344)
	
	if Input.is_action_pressed("attack"):
		play("down")
	else:
		play("up")
