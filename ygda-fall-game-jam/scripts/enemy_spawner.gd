extends AnimatedSprite2D
@onready var wave_stagger: Timer = $WaveStagger
@onready var world: Node = $".."

var type
var wave_stagger_time

func _ready() -> void:
	if wave_stagger_time > 0:
		spawn()
	else:
		wave_stagger.wait_time = wave_stagger_time
		wave_stagger.start()

func _on_wave_stagger_timeout() -> void:
	spawn()

func spawn() -> void:
	visible = true
	play("default")
	
func _on_animation_finished() -> void:
	Global.enemies_left += 1
	var enemy = type.instantiate()
	enemy.global_position = global_position
	world.add_child(enemy)
	queue_free()
