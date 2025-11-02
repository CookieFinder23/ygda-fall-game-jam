extends AnimatableBody2D

var health: int = 1
var lunge_direction
var speed: int
const EXPLOSION = preload("res://scenes/explosion.tscn")
func _physics_process(delta: float) -> void:
	move_and_collide(position.direction_to(Global.player_reference.position) * speed * delta)

func take_damage(damage: int) -> void:
	var explosion_instance = EXPLOSION.instantiate()
	get_tree().root.add_child(explosion_instance)
	explosion_instance.global_position = global_position
	queue_free()
