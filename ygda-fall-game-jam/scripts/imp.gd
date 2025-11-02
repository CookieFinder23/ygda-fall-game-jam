extends AnimatableBody2D

@onready var imp_sprite: AnimatedSprite2D = $ImpSprite
@onready var player: CharacterBody2D = $Player
@onready var explosion: CPUParticles2D = $Explosion

var health: int = 9
var phase: int = 0
var quadrant_x: int
var quadrant_y: int
var current_action: Action

const EXPLOSION = preload("res://scenes/explosion.tscn")
const PROJECTILE = preload("res://scenes/projectile.tscn")
const DASH_TIME = 0.5
const DASH_DISTANCE = 312

enum Action {
	LEFT,
	RIGHT,
	UP,
	DOWN,
	ATTACK
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	imp_sprite.play("attack")


func attack() -> void:
	imp_sprite.play("attack") # there is a function for on animation finished
		
func _on_imp_clock_timeout() -> void:
	phase = (phase + 1) % 4
	var dash_horizontal: bool = false
	var dash_vertical: bool = false
	if phase == 3:
		if position.x > 320:
			quadrant_x = 1
		else:
			quadrant_x = -1
		if position.y > 180:
			quadrant_y = 1
		else:
			quadrant_y = -1
			
		var player_quadrant_x: int
		if Global.player_reference.position.x > 320:
			player_quadrant_x = 1
		else:
			player_quadrant_x = -1
		var player_quadrant_y: int
		if Global.player_reference.position.y > 180:
			player_quadrant_y = 1
		else:
			player_quadrant_y = -1
		
		var player_same_x = player_quadrant_x == quadrant_x
		var player_same_y = player_quadrant_y == quadrant_y
		if not player_same_x and not player_same_y:
			dash_horizontal = false
			dash_vertical = false
		elif player_same_x and player_same_y:
			if randi_range(0, 1) == 0:
				dash_horizontal = true
				dash_vertical = false
			else:
				dash_horizontal = true
				dash_vertical = true
		elif player_same_x:
			dash_horizontal = true
			dash_vertical = false
		elif player_same_y:
			dash_horizontal = false
			dash_vertical = true
			
	if not dash_horizontal and not dash_vertical:
		current_action = Action.ATTACK
		attack()
	else:
		if dash_horizontal == true:
			if quadrant_x == 1:
				current_action = Action.LEFT
				imp_sprite.play("dash")
			else:
				current_action = Action.RIGHT
				imp_sprite.play("dash")
		else:
			if quadrant_y == 1:
				current_action = Action.UP
				imp_sprite.play("dash")
			else:
				current_action = Action.DOWN
				imp_sprite.play("dash")

func _physics_process(delta: float) -> void:
	if current_action == Action.UP:
		position.y -= DASH_DISTANCE / DASH_TIME * delta
		if position.y <= 48:
			position.y = 48
			current_action = Action.ATTACK
	if current_action == Action.DOWN:
		position.y += DASH_DISTANCE / DASH_TIME * delta
		if position.y >= 312:
			position.y = 312
			current_action = Action.ATTACK
	if current_action == Action.LEFT:
		position.x -= DASH_DISTANCE / DASH_TIME * delta
		if position.x <= 188:
			position.x = 188
			current_action = Action.ATTACK
	if current_action == Action.RIGHT:
		position.x += DASH_DISTANCE / DASH_TIME * delta
		if position.x >= 452:
			position.x = 452
			current_action = Action.ATTACK
		

func _on_imp_sprite_animation_finished() -> void:
	if imp_sprite.animation == "attack":
		var projectile_instance = PROJECTILE.instantiate()
		projectile_instance.global_position = global_position
		projectile_instance.rotation = position.angle_to_point(Global.player_reference.position) + deg_to_rad(randf_range(-15, 15))
		projectile_instance.speed = 200
		projectile_instance.type = "fireball"
		projectile_instance.is_player_owned = false
		get_tree().root.add_child(projectile_instance)

func take_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		var explosion_instance = EXPLOSION.instantiate()
		get_tree().root.add_child(explosion_instance)
		explosion_instance.global_position = global_position
		queue_free()
