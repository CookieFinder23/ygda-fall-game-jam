extends AnimatedSprite2D
@onready var crossbow_projectile_collision: CollisionShape2D = $Hitbox/CrossbowProjectileCollision
@onready var fireball_projectile_collision: CollisionShape2D = $Hitbox/FireballProjectileCollision
@onready var quietus_projectile_collossion: CollisionShape2D = $Hitbox/QuietusProjectileCollossion

var speed: int
var type: String
var damage: int
var is_player_owned: bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var projectiles = {
		"crossbow": crossbow_projectile_collision,
		"fireball": fireball_projectile_collision,
		"quietus": quietus_projectile_collossion
	}
	for projectile in projectiles:
		projectiles[projectile].disabled = type != projectile
	play(type)

	
func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Wall"):
		queue_free()
	elif (body.is_in_group("Player") and not is_player_owned) or (body.is_in_group("Enemy") and is_player_owned):
		body.take_damage(damage)
		queue_free()
		
