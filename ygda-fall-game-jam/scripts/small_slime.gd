extends AnimatableBody2D
@onready var stun_timer: Timer = $StunTimer
@onready var i_frames: Timer = $IFrames
@onready var small_slime_sprite: AnimatedSprite2D = $SmallSlimeSprite

var health: int = 1
var lunge_direction
var speed: int
const EXPLOSION = preload("res://scenes/explosion.tscn")

func _physics_process(delta: float) -> void:
	if stun_timer.is_stopped():
		if small_slime_sprite.animation == "stun":
			small_slime_sprite.play("chase")
		move_and_collide(position.direction_to(Global.player_reference.position) * speed * delta)
	elif small_slime_sprite.animation == "chase":
		small_slime_sprite.play("stun")

func take_damage(_damage: int) -> void:
	if i_frames.is_stopped():
		var explosion_instance = EXPLOSION.instantiate()
		get_tree().root.add_child(explosion_instance)
		explosion_instance.global_position = global_position
		Global.enemies_left -= 0.5
		queue_free()

func stun(stun_time: int) -> void:
	stun_timer.wait_time = stun_time
	stun_timer.start()
