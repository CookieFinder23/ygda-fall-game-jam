extends AnimatedSprite2D
@onready var random_wait: Timer = $RandomWait

var type

func _ready() -> void:
	random_wait.wait_time = randf_range(0, 1)
	random_wait.start()
	
func _on_random_wait_timeout() -> void:
	visible = true
	play("default")

func _on_animation_finished() -> void:
	Global.enemies_left += 1
	var enemy = type.instantiate()
	enemy.global_position = global_position
	get_tree().root.add_child(enemy)
	queue_free()
