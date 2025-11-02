extends AnimatableBody2D

@onready var ghost_sprite: AnimatedSprite2D = $GhostSprite
@onready var ghost_collision: CollisionShape2D = $GhostCollision
@onready var wait_clock: Timer = $WaitClock
@onready var invisible_clock: Timer = $InvisibleClock
const EXPLOSION = preload("res://scenes/explosion.tscn")
var health: int = 9
var phase: Phase = Phase.TELEPORT
var invisible: bool = true
const SPEED: int = 90

enum Phase {
	HUNT,
	TELEPORT
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	invisible_clock.start()
	ghost_sprite.play("appear")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if phase == Phase.HUNT and health > 0:
		move_and_collide(position.direction_to(Global.player_reference.position) * SPEED * delta)

func _on_teleport_clock_timeout() -> void:
	if health > 0:
		phase = Phase.TELEPORT
		ghost_sprite.play("disappear")

func _on_ghost_sprite_animation_finished() -> void:
	if health > 0:
		if ghost_sprite.animation == "disappear":
			if (randi_range(0, 1) == 1 or Global.player_reference.position.x < 338) and Global.player_reference.position.x < 302:
				global_position.x = Global.player_reference.position.x + 100
			else:
				global_position.x = Global.player_reference.position.x - 100
			if (randi_range(0, 1) == 1 or Global.player_reference.position.y < 166) and Global.player_reference.position.y < 194:
				global_position.y = Global.player_reference.position.y + 100
			else:
				global_position.y = Global.player_reference.position.y - 100
			ghost_sprite.play("appear")
		elif ghost_sprite.animation == "appear":
			ghost_sprite.play("hunt")
			wait_clock.start()
	elif ghost_sprite.animation == "death":
		queue_free()

func _on_wait_clock_timeout() -> void:
	phase = Phase.HUNT

func _on_invisible_clock_timeout() -> void:
	if health > 0:
		if invisible:
			invisible = false
			collision_layer = 4
			ghost_sprite.self_modulate.a = 1
			invisible_clock.wait_time = 1
			invisible_clock.start()
		else:
			invisible = true
			collision_layer = 0
			ghost_sprite.self_modulate.a = 0.5
			invisible_clock.wait_time = 2
			invisible_clock.start()
		
func take_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		var explosion_instance = EXPLOSION.instantiate()
		get_tree().root.add_child(explosion_instance)
		explosion_instance.global_position = global_position
		queue_free()
