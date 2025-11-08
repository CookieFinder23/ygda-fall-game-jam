extends CPUParticles2D

var death: bool = false
var smoke: bool = false
const EXPLOSION = preload("res://assets/explosion.tres")
const SMOKE = preload("res://assets/smoke.tres")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if smoke:
		color_ramp = SMOKE
		scale = Vector2(10, 10)
		initial_velocity_min = 2
		initial_velocity_max = 3
		amount = 64
		lifetime = 0.75
	elif death:
		color_ramp = EXPLOSION
		amount = 32
		scale = Vector2(3, 3)
		initial_velocity_min = 10
		initial_velocity_max = 20
	else:
		color_ramp = EXPLOSION
		amount = 16
		scale = Vector2(1, 1)
		initial_velocity_min = 20
		initial_velocity_max = 40
	emitting = true

func _on_finished() -> void:
	queue_free()
