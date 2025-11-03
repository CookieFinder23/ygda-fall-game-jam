extends CPUParticles2D

var death: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if death:
		amount = 32
		scale = Vector2(3, 3)
		initial_velocity_min = 10
		initial_velocity_max = 20
	else:
		amount = 16
		scale = Vector2(1, 1)
		initial_velocity_min = 20
		initial_velocity_max = 40
	emitting = true

func _on_finished() -> void:
	queue_free()
