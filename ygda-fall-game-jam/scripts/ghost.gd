extends AnimatableBody2D

@onready var ghost_sprite: AnimatedSprite2D = $GhostSprite
@onready var ghost_collision: CollisionShape2D = $GhostCollision
@onready var stun_timer: Timer = $StunTimer
@onready var world: Node = $".."
@onready var teleport_cooldown: Timer = $TeleportCooldown
@onready var animation_player: AnimationPlayer = $AnimationPlayer



const EXPLOSION = preload("res://scenes/explosion.tscn")
var health: int = 9
var phase: Phase = Phase.TELEPORT
const SPEED: int = 90
var weak: bool = false
var speed_modifier = 1
var already_dead: bool = false

enum Phase {
	HUNT,
	TELEPORT
}

func _ready() -> void:
	if weak:
		speed_modifier = 0.7
		health  = 6
		teleport_cooldown.wait_time = teleport_cooldown.wait_time * 1.5
		
	animation_player.play("disappear")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	get_cleared()
	
	if phase == Phase.HUNT and health > 0 and stun_timer.is_stopped():
		move_and_collide(position.direction_to(Global.player_reference.position) * SPEED * delta * speed_modifier)

	if phase == Phase.HUNT:
		ghost_collision.disabled = false
	else:
		ghost_collision.disabled = true
		
	var x_difference = Global.player_reference.position.x - position.x
	var y_difference = Global.player_reference.position.y - position.y
	if abs(x_difference) > abs(y_difference):
		if x_difference > 0:
			ghost_sprite.play("right")
		else:
			ghost_sprite.play("left")
	else:
		if y_difference > 0:
			ghost_sprite.play("down")
		else:
			ghost_sprite.play("up")

func get_cleared() -> void:
	if Global.clear_screen:
		var explosion_instance = Global.EXPLOSION.instantiate()
		explosion_instance.death = true
		explosion_instance.global_position = global_position
		world.add_child(explosion_instance)
		queue_free()

func _on_wait_clock_timeout() -> void:
	phase = Phase.HUNT

func take_damage(damage: int) -> void:
	health -= damage
	var explosion_instance = Global.EXPLOSION.instantiate()
	explosion_instance.global_position = global_position
	if health <= 0 and not already_dead:
		explosion_instance.death = true
		world.add_child(explosion_instance)
		Global.enemies_left -= 1
		already_dead = true
		queue_free()
	else:
		explosion_instance.death = false
		world.add_child(explosion_instance)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "disappear":
		if (randi_range(0, 1) == 1 or Global.player_reference.position.x < 388) and Global.player_reference.position.x < 252:
			global_position.x = Global.player_reference.position.x + 50
		else:
			global_position.x = Global.player_reference.position.x - 50
		if (randi_range(0, 1) == 1 or Global.player_reference.position.y < 216) and Global.player_reference.position.y < 254:
			global_position.y = Global.player_reference.position.y + 50
		else:
			global_position.y = Global.player_reference.position.y - 50
		animation_player.play("appear")
	elif anim_name == "appear":
		phase = Phase.HUNT

func stun(stun_time: int) -> void:
	stun_timer.wait_time = stun_time
	stun_timer.start()


func _on_teleport_cooldown_timeout() -> void:
	if health > 0:
		phase = Phase.TELEPORT
		animation_player.play("disappear")
