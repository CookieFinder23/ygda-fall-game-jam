extends AnimatableBody2D

@onready var quietus_sprite: AnimatedSprite2D = $QuietusSprite
@onready var stun_timer: Timer = $StunTimer
@onready var world: Node = $".."
@onready var rotate_timer: Timer = $RotateTimer
@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_cooldown: Timer = $ShootCooldown
@onready var mode_cooldown_timer: Timer = $ModeCooldownTimer

const PROJECTILE = preload("res://scenes/projectile.tscn")
const EXPLOSION = preload("res://scenes/explosion.tscn")
var health: int = 9
var phase: Phase = Phase.SLASH
var has_shot: bool = false
const SLASH_SPEED = 80
const SHOOT_SPEED = 1200


enum Phase {
	SLASH,
	SHOOT,
}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if stun_timer.is_stopped():
		look_at(Global.player_reference.position)
		rotation_degrees += 115
		if phase == Phase.SLASH:
			if quietus_sprite.animation != "slash":
				quietus_sprite.play("slash")
			rotation_degrees += get_rotation_offset(rotate_timer)
			move_and_collide(position.direction_to(Global.player_reference.position) * SLASH_SPEED * delta)
		else:
			move_and_collide(position.direction_to(Global.player_reference.position) * get_shoot_speed_offset(shoot_timer) * delta)

func _on_update_mode_timer_timeout() -> void:
	if phase == Phase.SLASH:
		phase = Phase.SHOOT
		mode_cooldown_timer.start()
	elif phase == Phase.SHOOT:
		phase = Phase.SLASH
		mode_cooldown_timer.start()

func get_rotation_offset(timer: Timer) -> float:
	var used_time: float
	var max_time = timer.wait_time / 2
	if timer.time_left > max_time:
		used_time = max_time - (timer.time_left - max_time)
	else:
		used_time = timer.time_left
	return 200 * (used_time - max_time / 2)
	
func get_shoot_speed_offset(timer: Timer) -> float:
	if shoot_timer.is_stopped():
		return 1
	var used_time: float
	var max_time = timer.wait_time / 2

	if timer.time_left > max_time:
		used_time = max_time - (timer.time_left - max_time)
	else:
		used_time = timer.time_left
	
	var final_speed = ((used_time - max_time) + max_time / 2)
	if final_speed < -0.1:
		quietus_sprite.play("before_shoot")
		has_shot = false
	if final_speed > 0.1 and has_shot == false:
		has_shot = true
		shoot()
	return SHOOT_SPEED * final_speed

func shoot():
	quietus_sprite.play("shoot")
	var projectile_instance = PROJECTILE.instantiate()
	projectile_instance.rotation = position.angle_to_point(Global.player_reference.position)
	projectile_instance.speed = 230
	projectile_instance.global_position = global_position + projectile_instance.transform.x * 20
	projectile_instance.type = "quietus"
	projectile_instance.is_player_owned = false
	world.add_child(projectile_instance)
		
func _on_shoot_timer_timeout() -> void:
	shoot_cooldown.start()

func _on_shoot_cooldown_timeout() -> void:
	shoot_timer.start()
	
func take_damage(damage: int) -> void:
	health -= damage
	var explosion_instance = Global.EXPLOSION.instantiate()
	explosion_instance.global_position = global_position
	if health <= 0:
		explosion_instance.death = true
		world.add_child(explosion_instance)
		Global.enemies_left -= 1
		queue_free()
	else:
		explosion_instance.death = false
		world.add_child(explosion_instance)

func stun(stun_time: int) -> void:
	stun_timer.wait_time = stun_time
	stun_timer.start()
