extends AnimatableBody2D

@onready var ghost_sprite: AnimatedSprite2D = $GhostSprite
@onready var ghost_collision: CollisionShape2D = $GhostCollision
@onready var wait_clock: Timer = $WaitClock
@onready var stun_timer: Timer = $StunTimer

const EXPLOSION = preload("res://scenes/explosion.tscn")
var health: int = 9
var phase: Phase = Phase.TELEPORT
const SPEED: int = 90

enum Phase {
	HUNT,
	TELEPORT
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ghost_sprite.play("appear")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if phase == Phase.HUNT and health > 0 and stun_timer.is_stopped():
		move_and_collide(position.direction_to(Global.player_reference.position) * SPEED * delta)
	if phase == Phase.HUNT:
		collision_layer = 4
		ghost_sprite.self_modulate.a = 1
	else:
		collision_layer = 0
		ghost_sprite.self_modulate.a = 0.5

func _on_teleport_clock_timeout() -> void:
	if health > 0:
		phase = Phase.TELEPORT
		ghost_sprite.play("disappear")

func _on_ghost_sprite_animation_finished() -> void:
	if health > 0:
		if ghost_sprite.animation == "disappear":
			if (randi_range(0, 1) == 1 or Global.player_reference.position.x < 388) and Global.player_reference.position.x < 252:
				global_position.x = Global.player_reference.position.x + 50
			else:
				global_position.x = Global.player_reference.position.x - 50
			if (randi_range(0, 1) == 1 or Global.player_reference.position.y < 216) and Global.player_reference.position.y < 254:
				global_position.y = Global.player_reference.position.y + 50
			else:
				global_position.y = Global.player_reference.position.y - 50
			ghost_sprite.play("appear")
		elif ghost_sprite.animation == "appear":
			ghost_sprite.play("hunt")
			wait_clock.start()
	elif ghost_sprite.animation == "death":
		queue_free()

func _on_wait_clock_timeout() -> void:
	phase = Phase.HUNT

func take_damage(damage: int) -> void:
	health -= damage
	var explosion_instance = Global.EXPLOSION.instantiate()
	explosion_instance.global_position = global_position
	if health <= 0:
		explosion_instance.death = true
		get_tree().root.add_child(explosion_instance)
		Global.enemies_left -= 1
		queue_free()
	else:
		explosion_instance.death = false
		get_tree().root.add_child(explosion_instance)

func stun(stun_time: int) -> void:
	stun_timer.wait_time = stun_time
	stun_timer.start()
