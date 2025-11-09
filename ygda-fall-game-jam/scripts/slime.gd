extends AnimatableBody2D

@onready var slime_sprite: AnimatedSprite2D = $SlimeSprite
@onready var lunge_range: Area2D = $LungeRange
@onready var lunge_cooldown: Timer = $LungeCooldown
@onready var stun_timer: Timer = $StunTimer
@onready var world: Node = $".."

const SMALL_SLIME = preload("res://scenes/small_slime.tscn")
var health: int = 6
var phase: Phase = Phase.CHASE
var lunge_direction
const CHASE_SPEED: int = 60
const LUNGE_SPEED: int = 190
var weak: bool
var speed_modifier = 1
var already_dead: bool = false

enum Phase {
	CHASE,
	LUNGE_STARTUP,
	LUNGE
}

func _ready() -> void:
	if weak:
		health = 3
		speed_modifier = 0.7

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	get_cleared()
		
	if stun_timer.is_stopped() and slime_sprite.animation != "split":
		if phase == Phase.CHASE:
			if slime_sprite.animation == "lunge":
				move_and_collide(position.direction_to(Global.player_reference.position) * LUNGE_SPEED * delta * speed_modifier)
			else:
				move_and_collide(position.direction_to(Global.player_reference.position) * CHASE_SPEED * delta * speed_modifier)
			if lunge_range.overlaps_body(Global.player_reference) and lunge_cooldown.is_stopped():
				lunge_cooldown.start()
				slime_sprite.play("lunge_startup")
				phase = Phase.LUNGE_STARTUP
		elif phase == Phase.LUNGE:
			move_and_collide(lunge_direction * LUNGE_SPEED * delta * speed_modifier)

func get_cleared() -> void:
	if Global.clear_screen:
		var explosion_instance = Global.EXPLOSION.instantiate()
		explosion_instance.death = true
		explosion_instance.global_position = global_position
		world.add_child(explosion_instance)
		queue_free()

func take_damage(damage: int) -> void:
	if slime_sprite.animation != "split":
		health -= damage
		var explosion_instance = Global.EXPLOSION.instantiate()
		explosion_instance.death = false
		explosion_instance.global_position = global_position
		world.add_child(explosion_instance)
		if health <= 0:
			slime_sprite.play("split")


func _on_slime_sprite_animation_finished() -> void:
	if slime_sprite.animation == "lunge_startup":
		phase = Phase.LUNGE
		slime_sprite.play("lunge")
		lunge_direction = position.direction_to(Global.player_reference.position) + Vector2(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
	elif slime_sprite.animation == "lunge":
		phase = Phase.CHASE
		slime_sprite.play("chase")
		lunge_cooldown.start()
	elif slime_sprite.animation == "split":
		var slow_small_slime_instance = SMALL_SLIME.instantiate()
		slow_small_slime_instance.global_position = global_position + Vector2(-10, 0)
		slow_small_slime_instance.speed = 80 * speed_modifier
		var fast_small_slime_instance = SMALL_SLIME.instantiate()
		fast_small_slime_instance.global_position = global_position + Vector2(10, 0)
		fast_small_slime_instance.speed = 100 * speed_modifier
		world.add_child(slow_small_slime_instance)
		world.add_child(fast_small_slime_instance)
		queue_free()
	
func stun(stun_time: int) -> void:
	stun_timer.wait_time = stun_time
	stun_timer.start()
	
