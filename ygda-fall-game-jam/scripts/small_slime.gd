extends AnimatableBody2D
@onready var stun_timer: Timer = $StunTimer
@onready var i_frames: Timer = $IFrames
@onready var small_slime_sprite: AnimatedSprite2D = $SmallSlimeSprite
@onready var world: Node = $".."

var health: int = 1
var lunge_direction
var speed: int
var already_dead: bool = false
const EXPLOSION = preload("res://scenes/explosion.tscn")

func _physics_process(delta: float) -> void:
	get_cleared()
	if stun_timer.is_stopped():
		if small_slime_sprite.animation == "stun":
			small_slime_sprite.play("chase")
		move_and_collide(position.direction_to(Global.player_reference.position) * speed * delta)
	elif small_slime_sprite.animation == "chase":
		small_slime_sprite.play("stun")
		
func get_cleared() -> void:
	if Global.clear_screen:
		var explosion_instance = Global.EXPLOSION.instantiate()
		explosion_instance.death = true
		explosion_instance.global_position = global_position
		world.add_child(explosion_instance)
		queue_free()
		
func take_damage(_damage: int) -> void:
	if i_frames.is_stopped() and not already_dead:
		var explosion_instance = Global.EXPLOSION.instantiate()
		explosion_instance.global_position = global_position
		explosion_instance.death = true
		get_tree().root.add_child(explosion_instance)
		Global.enemies_left -= 0.5
		already_dead = true
		queue_free()

func stun(stun_time: int) -> void:
	stun_timer.wait_time = stun_time
	stun_timer.start()
