extends AnimatedSprite2D
@onready var crossbow_projectile_collision: CollisionShape2D = $Hitbox/CrossbowProjectileCollision
@onready var fireball_projectile_collision: CollisionShape2D = $Hitbox/FireballProjectileCollision
@onready var quietus_projectile_collossion: CollisionShape2D = $Hitbox/QuietusProjectileCollossion
@onready var dark_energy_collission_shape: CollisionShape2D = $Hitbox/DarkEnergyCollissionShape
@onready var big_projectile_collission: CollisionShape2D = $Hitbox/BigProjectileCollission
@onready var cultist_energy_collission: CollisionShape2D = $Hitbox/CultistEnergyCollission
@onready var lifetime: Timer = $Lifetime
@onready var world: Node = $".."

const PROJECTILE = preload("res://scenes/projectile.tscn")
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
		"dark_energy": dark_energy_collission_shape,
		"big_projectile": big_projectile_collission,
		"cultist_energy": cultist_energy_collission
	}
	right_rotation = type == "fireball" or type == "dark_energy"
	for projectile in projectiles:
		projectiles[projectile].disabled = type != projectile
	play(type)
	old_rotation = rotation

	
func _physics_process(delta: float) -> void:
	if not freeze:
		if type == "big_projectile":
			if not lifetime.is_stopped():
				look_at(Global.player_reference.position)
			position += transform.x * speed * delta
		else:
			if right_rotation or type == "quietus":
				rotation = old_rotation
			position += transform.x * speed * delta
			if right_rotation:
				rotation_degrees += -90
			if type == "quietus":
				rotation_degrees += 90

func _on_hitbox_body_entered(body: Node2D) -> void:
	if not freeze:
		if body.is_in_group("Wall"):
			die()
		elif (body.is_in_group("Player") and not is_player_owned) or (body.is_in_group("Enemy") and is_player_owned):
			body.take_damage(damage)
			die()

func _on_animation_finished() -> void:
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("shield"):
		call_deferred("die")

func die() -> void:
	if right_rotation or type == "big_projectile" or type == "cultist_energy" or type == "quietus":
		freeze = true
		if type == "big_projectile":
			scale = Vector2(2, 2)
			@warning_ignore("narrowing_conversion")
			var starting_direction: int = rotation_degrees + 180
			const SPREAD = 45
			const AMOUNT = 3
			@warning_ignore("integer_division")
			for i in range(starting_direction - SPREAD/2, starting_direction + SPREAD/2 + 1, SPREAD/(AMOUNT - 1)):
				var projectile_instance = PROJECTILE.instantiate()
				projectile_instance.global_position = global_position - transform.x * speed * 0.05
				projectile_instance.rotation = deg_to_rad(i)
				projectile_instance.speed = 80
				projectile_instance.type = "dark_energy"
				projectile_instance.is_player_owned = false
				world.add_child(projectile_instance)
		play(type + "_impact")
	else:
		queue_free()
