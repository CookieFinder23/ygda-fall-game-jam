extends AnimatableBody2D

@onready var slime_sprite: AnimatedSprite2D = $SlimeSprite
@onready var lunge_range: Area2D = $LungeRange
@onready var lunge_cooldown: Timer = $LungeCooldown
@onready var lunge_in_action: Timer = $LungeInAction
@onready var stun_timer: Timer = $StunTimer
@onready var world: Node = $".."

const SMALL_SLIME = preload("res://scenes/small_slime.tscn")
var health: int = 9
var phase: Phase = Phase.CHASE
var lunge_direction
const CHASE_SPEED: int = 60
const LUNGE_SPEED: int = 190

enum Phase {
	CHASE,
	LUNGE_STARTUP,
	LUNGE
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if stun_timer.is_stopped():
		if phase == Phase.CHASE:
			move_and_collide(position.direction_to(Global.player_reference.position) * CHASE_SPEED * delta)
			if lunge_range.overlaps_body(Global.player_reference) and lunge_cooldown.is_stopped():
				lunge_cooldown.start()
				slime_sprite.play("lunge_startup")
				phase = Phase.LUNGE_STARTUP

		elif phase == Phase.LUNGE:
			move_and_collide(lunge_direction * LUNGE_SPEED * delta)

func take_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		var slow_small_slime_instance = SMALL_SLIME.instantiate()
		slow_small_slime_instance.global_position = global_position
		slow_small_slime_instance.speed = 70
		var fast_small_slime_instance = SMALL_SLIME.instantiate()
		fast_small_slime_instance.global_position = global_position
		fast_small_slime_instance.speed = 90
		world.add_child(slow_small_slime_instance)
		world.add_child(fast_small_slime_instance)
		queue_free()
	else:
		var explosion_instance = Global.EXPLOSION.instantiate()
		explosion_instance.death = false
		explosion_instance.global_position = global_position
		world.add_child(explosion_instance)

func _on_slime_sprite_animation_finished() -> void:
	if slime_sprite.animation == "lunge_startup":
		phase = Phase.LUNGE
		lunge_in_action.start()
		slime_sprite.play("lunge")
		lunge_direction = position.direction_to(Global.player_reference.position)

func _on_lunge_in_action_timeout() -> void:
	phase = Phase.CHASE
	lunge_cooldown.start()
	slime_sprite.play("chase")
	
func stun(stun_time: int) -> void:
	stun_timer.wait_time = stun_time
	stun_timer.start()
	
