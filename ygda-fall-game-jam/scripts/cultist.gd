extends AnimatableBody2D

@onready var stun_timer: Timer = $StunTimer
@onready var world: Node = $".."
@onready var teleport_cooldown_timer: Timer = $TeleportCooldownTimer
@onready var wait_to_shoot_timer: Timer = $WaitToShootTimer
@onready var cultist_sprite: AnimatedSprite2D = $CultistSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cultist_collision: CollisionShape2D = $CultistCollision
@onready var time_from_animation_start_to_shoot: Timer = $TimeFromAnimationStartToShoot

const PROJECTILE = preload("res://scenes/projectile.tscn")
const EXPLOSION = preload("res://scenes/explosion.tscn")
const ATTACK_SPREAD = 90
var health: int = 9
var phase: Phase = Phase.TELEPORT
var weak: bool = false
var already_dead: bool = false

enum Phase {
	ATTACK,
	TELEPORT
}

func _ready() -> void:
	if weak:
		teleport_cooldown_timer.wait_time = 1

func _physics_process(delta: float) -> void:
	cultist_collision.disabled = animation_player.is_playing()
	
func attack(direction: String) -> void:
	var starting_degrees: int
	if direction == "up":
		starting_degrees = 90
	if direction == "left":
		starting_degrees = 0
	if direction == "down":
		starting_degrees = 270
	if direction == "right":
		starting_degrees = 180
		
	for i in range(starting_degrees - ATTACK_SPREAD/2, starting_degrees + ATTACK_SPREAD/2 + 1, ATTACK_SPREAD/2):
		var projectile_instance = PROJECTILE.instantiate()
		projectile_instance.global_position = global_position
		projectile_instance.rotation = deg_to_rad(i)
		if weak:
			projectile_instance.speed = 75
		else:
			projectile_instance.speed = 150
		projectile_instance.type = "cultist_energy"
		projectile_instance.is_player_owned = false
		world.add_child(projectile_instance)

func _on_time_from_animation_start_to_shoot_timeout() -> void:
	attack(cultist_sprite.animation)

func _on_cultist_sprite_animation_finished() -> void:
	teleport_cooldown_timer.start()
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "disappear":
		if weak and health < 6:
			Global.enemies_left -= 1
			queue_free()
		if (randi_range(0, 1) == 1 or  Global.player_reference.position.x < 264 or Global.player_reference.position.x >= 375) and (Global.player_reference.position.y > 132 and Global.player_reference.position.y < 228):
			cultist_sprite.flip_h = false
			global_position.y = Global.player_reference.position.y
			if (randi_range(0, 1) == 1 or Global.player_reference.position.x < 264) and Global.player_reference.position.x < 375:
				global_position.x = Global.player_reference.position.x + 100
				cultist_sprite.play("right")
			else:
				global_position.x = Global.player_reference.position.x - 100
				cultist_sprite.play("right")
				cultist_sprite.flip_h = true
		else:
			global_position.x = Global.player_reference.position.x
			if (randi_range(0, 1) == 1 or Global.player_reference.position.y < 132) and Global.player_reference.position.y < 228:
				global_position.y = Global.player_reference.position.y + 100
				cultist_sprite.play("up")
			else:
				global_position.y = Global.player_reference.position.y - 100
				cultist_sprite.play("down")
		time_from_animation_start_to_shoot.start()
		animation_player.play("appear")
		
func _on_teleport_cooldown_timer_timeout() -> void:
	animation_player.play("disappear")

func take_damage(damage: int) -> void:
	health -= damage
	var explosion_instance = Global.EXPLOSION.instantiate()
	explosion_instance.global_position = global_position
	if health <= 0 and not already_dead:
		explosion_instance.global_position = global_position
		explosion_instance.death = true
		world.add_child(explosion_instance)
		Global.enemies_left -= 1
		already_dead = true
		queue_free()
	else:
		explosion_instance.death = false
		world.add_child(explosion_instance)

func stun(stun_time: int) -> void:
	stun_timer.wait_time = stun_time
	stun_timer.start()
