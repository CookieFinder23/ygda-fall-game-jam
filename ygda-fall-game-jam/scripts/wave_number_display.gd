extends Label

func _physics_process(_delta: float) -> void:
	text = str(Global.wave_number) + "/4"
