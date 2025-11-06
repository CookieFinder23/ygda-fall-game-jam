extends AnimatableBody2D

@onready var stun_timer: Timer = $StunTimer
@onready var world: Node = $".."
@onready var teleport_cooldown_timer: Timer = $TeleportCooldownTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var time_from_animation_start_to_shoot: Timer = $TimeFromAnimationStartToShoot
@onready var final_boss_sprite: AnimatedSprite2D = $FinalBossSprite
@onready var final_boss_collision: CollisionShape2D = $FinalBossCollision
@onready var wait_to_appear_timer: Timer = $WaitToAppearTimer
@onready var wait_for_mini_wave_to_end: Timer = $WaitForMiniWaveToEnd

const CULTIST = preload("res://scenes/cultist.tscn")
const QUIETUS = preload("res://scenes/quietus.tscn")
const SLIME = preload("res://scenes/slime.tscn")
const IMP = preload("res://scenes/imp.tscn")
const GHOST = preload("res://scenes/ghost.tscn")

const ENEMY_SPAWNER = preload("res://scenes/enemy_spawner.tscn")
const PROJECTILE = preload("res://scenes/projectile.tscn")
const EXPLOSION = preload("res://scenes/explosion.tscn")
const ATTACK_SPREAD = 135
var health: int = 18
var phase: Phase = Phase.TELEPORT
var direction_degrees: int
var head_direction: int
var miniwave_count: int = 0
enum Phase {
	ATTACK,
	SUMMON,
	TELEPORT
}

func _process(float) -> void:
	print(final_boss_collision.disabled)

func _ready() -> void:
	animation_player.play("disappear")

func get_direction_to_player() -> void:
	var head_angle_degrees: float = rad_to_deg(get_angle_to(Global.player_reference.position))
	var head_increment: float = 180 / 4
	head_direction = snapped(wrap(head_angle_degrees + 270, 0, 360), head_increment) / head_increment
	direction_degrees = head_direction * head_increment
	final_boss_sprite.flip_h = head_direction < 5
	if head_direction == 0 or head_direction == 8:
		final_boss_sprite.play("down")
	elif head_direction == 1 or head_direction == 7:
		final_boss_sprite.play("downright")
	elif head_direction == 2 or head_direction == 6:
		final_boss_sprite.play("right")
	elif head_direction == 3 or head_direction == 5:
		final_boss_sprite.play("upright")
	elif head_direction == 4:
		final_boss_sprite.play("up")
	
func primal_aspid_attack() -> void:
	final_boss_collision.disabled = false
	var starting_direction: int = direction_degrees + 90
	for i in range(starting_direction - ATTACK_SPREAD/2, starting_direction + ATTACK_SPREAD/2 + 1, ATTACK_SPREAD/4):
		var projectile_instance = PROJECTILE.instantiate()
		projectile_instance.global_position = global_position
		projectile_instance.rotation = deg_to_rad(i)
		projectile_instance.speed = 100
		projectile_instance.type = "dark_energy"
		projectile_instance.is_player_owned = false
		world.add_child(projectile_instance)

func _on_time_from_animation_start_to_shoot_timeout() -> void:
	primal_aspid_attack()

func _on_final_boss_sprite_animation_finished() -> void:
	teleport_cooldown_timer.start()
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "disappear":
		if 18 - health >= (miniwave_count + 1) * 6:
			miniwave_count += 1
			wait_for_mini_wave_to_end.wait_time = miniwave_count * 3 + 3
			wait_for_mini_wave_to_end.start()
			summon_multiple_enemies(clamp(miniwave_count, 1, 4))
		else:
			wait_to_appear_timer.start()
	if anim_name == "appear":
		final_boss_collision.disabled = false
		
		
func _on_teleport_cooldown_timer_timeout() -> void:
	animation_player.play("disappear")
	final_boss_collision.disabled = true

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


func _on_wait_to_appear_timer_timeout() -> void:
	var proposed_spawn_position = Vector2(randi_range(236, 372), randi_range(96, 264))
	while proposed_spawn_position.distance_to(Global.player_reference.position) < 64:
		proposed_spawn_position = Vector2(randi_range(236, 372), randi_range(96, 264))
	position = proposed_spawn_position
	get_direction_to_player()
	animation_player.play("appear")
	time_from_animation_start_to_shoot.start()

func summon_multiple_enemies(amount: int) -> void:
	var enemy_selection = [CULTIST, SLIME, IMP, GHOST, QUIETUS]
	var corner_selection = [Vector2(188, 48), Vector2(452, 48), Vector2(188, 312), Vector2(452, 312)]
	var corner: Vector2
	for i in range(amount):
		var enemy_spawner_instance = ENEMY_SPAWNER.instantiate()
		enemy_spawner_instance.type = enemy_selection.pick_random()
		enemy_selection.erase(enemy_spawner_instance.type)
		corner = corner_selection.pick_random()
		corner_selection.erase(corner)
		enemy_spawner_instance.position = corner
		enemy_spawner_instance.weak = true
		enemy_spawner_instance.wave_stagger_time = i
		world.add_child(enemy_spawner_instance)
		
func _on_wait_for_mini_wave_to_end_timeout() -> void:
	wait_to_appear_timer.start()

func _on_random_summon_timeout() -> void:
	if Global.enemies_left < 3 and wait_for_mini_wave_to_end.is_stopped():
		summon_multiple_enemies(1)
