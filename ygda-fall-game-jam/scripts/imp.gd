extends AnimatableBody2D

@onready var imp_sprite: AnimatedSprite2D = $ImpSprite
@onready var stun_timer: Timer = $StunTimer
@onready var world: Node = $".."
@onready var imp_clock: Timer = $ImpClock

var health: int = 9
var phase: int = 3
var quadrant_x: int
var quadrant_y: int
var current_action: Action = Action.ATTACK

const PROJECTILE = preload("res://scenes/projectile.tscn")
const DASH_TIME = 0.5
const DASH_DISTANCE = 312
var weak: bool = false
var already_dead: bool = false

enum Action {
	LEFT,
	RIGHT,
	UP,
	DOWN,
	ATTACK
}

func _ready() -> void:
	if weak:
		health = 6
		imp_clock.wait_time = imp_clock.wait_time * 2

func attack() -> void:
		var projectile_instance = PROJECTILE.instantiate()
		projectile_instance.global_position = global_position
		projectile_instance.rotation = position.angle_to_point(Global.player_reference.position) + deg_to_rad(randf_range(-15, 15))
		projectile_instance.speed = 180
		projectile_instance.type = "fireball"
		projectile_instance.is_player_owned = false
		world.add_child(projectile_instance)
		
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
			else:
				current_action = Action.RIGHT
		else:
			if quadrant_y == 1:
				current_action = Action.UP
			else:
				current_action = Action.DOWN

func _physics_process(delta: float) -> void:
	if stun_timer.is_stopped():
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
