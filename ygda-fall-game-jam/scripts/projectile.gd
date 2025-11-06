extends AnimatedSprite2D
@onready var crossbow_projectile_collision: CollisionShape2D = $Hitbox/CrossbowProjectileCollision
@onready var fireball_projectile_collision: CollisionShape2D = $Hitbox/FireballProjectileCollision
@onready var quietus_projectile_collossion: CollisionShape2D = $Hitbox/QuietusProjectileCollossion
@onready var dark_energy_collission_shape: CollisionShape2D = $Hitbox/DarkEnergyCollissionShape

var speed: int
var type: String
var damage: int
var is_player_owned: bool
var old_rotation
var freeze: bool
var right_rotation: bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var projectiles = {
		"crossbow": crossbow_projectile_collision,
		"fireball": fireball_projectile_collision,
		"quietus": quietus_projectile_collossion,
		"dark_energy": dark_energy_collission_shape
	}
	right_rotation = type == "fireball" or type == "dark_energy"
	if type == "dark_energy":
		scale = Vector2(1.5, 1.5)
	else:
		scale = Vector2(1, 1)
	for projectile in projectiles:
		projectiles[projectile].disabled = type != projectile
	play(type)
	old_rotation = rotation

	
func _physics_process(delta: float) -> void:
	if not freeze:
		if right_rotation:
			rotation = old_rotation
		position += transform.x * speed * delta
		if right_rotation:
			rotation_degrees += -90

func _on_hitbox_body_entered(body: Node2D) -> void:
	if not freeze:
		if body.is_in_group("Wall"):
			if right_rotation:
				freeze = true
				play(type + "_impact")
			else:
				queue_free()
		elif (body.is_in_group("Player") and not is_player_owned) or (body.is_in_group("Enemy") and is_player_owned):
			body.take_damage(damage)
			if right_rotation:
				freeze = true
				play(type + "_impact")
			else:
				queue_free()

func _on_animation_finished() -> void:
	queue_free()
