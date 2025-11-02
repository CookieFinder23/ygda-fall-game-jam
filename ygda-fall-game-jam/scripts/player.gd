extends CharacterBody2D

@onready var hunter_body_sprite: AnimatedSprite2D = $HunterBodySprite
@onready var hunter_head_sprite: AnimatedSprite2D = $HunterHeadSprite
@onready var knight_body_sprite: AnimatedSprite2D = $KnightBodySprite

@onready var player_collision: CollisionShape2D = $PlayerCollision
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var movement_ability_cooldown: Timer = $MovementAbilityCooldown
@onready var movement_ability_in_action: Timer = $MovementAbilityInAction
@onready var transformation_cooldown: Timer = $TransformationCooldown
@onready var reload_bar: Sprite2D = $ReloadBar
@onready var reload_bar_animation_player: AnimationPlayer = $ReloadBar/ReloadBarVertical/ReloadBarAnimationPlayer
@onready var hunter_weapon_sprite: AnimatedSprite2D = $HunterWeaponSprite
@onready var knight_weapon_sprite: AnimatedSprite2D = $KnightWeaponSprite
const PROJECTILE = preload("res://scenes/projectile.tscn")
const BASE_MOVEMENT_SPEED: int = 30
const VERTICAL_WEAPON_OFFSET: int = -5

var current_body_sprite: AnimatedSprite2D
var current_head_sprite: AnimatedSprite2D
var current_weapon: AnimatedSprite2D
var current_character: Character
var movement_speed: int
var movement_direction: MovementDirection
enum MovementDirection {
	UP,
	DOWN,
	LEFT,
	RIGHT
}
enum MovementSpeed {
	FAST,
	NORMAL,
	SLOW
}

var movement_speed_to_number = {
	MovementSpeed.FAST: 125,
	MovementSpeed.NORMAL: 100,
	MovementSpeed.SLOW: 75,
}

enum AttackCooldownLength {
	FAST,
	NORMAL,
	SLOW
}

var attack_cooldown_length_to_number = {
	AttackCooldownLength.FAST: 0.5,
	AttackCooldownLength.NORMAL: 2,
	AttackCooldownLength.SLOW: 3
}

enum MovementAbilityCooldownLength {
	FAST,
	NORMAL,
	SLOW
}

var movement_ability_cooldown_length_to_number = {
	MovementAbilityCooldownLength.FAST: 0.5,
	MovementAbilityCooldownLength.NORMAL: 2,
	MovementAbilityCooldownLength.SLOW: 3
}

enum Character {
	HUNTER,
	KNIGHT
}

var character_data = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	character_data = {
	Character.HUNTER: [MovementSpeed.NORMAL, AttackCooldownLength.NORMAL, MovementAbilityCooldownLength.NORMAL, hunter_body_sprite, hunter_head_sprite, hunter_weapon_sprite],
	Character.KNIGHT: [MovementSpeed.NORMAL, AttackCooldownLength.NORMAL, MovementAbilityCooldownLength.NORMAL, knight_body_sprite, knight_body_sprite, knight_weapon_sprite]
	}
	
	current_body_sprite = hunter_body_sprite
	set_character(Character.HUNTER)
	play_body_animation("idle")

func set_movement_speed(character: Character) -> void:
	movement_speed = movement_speed_to_number[character_data[character][0]]

func set_attack_cooldown(character: Character) -> void:
	attack_cooldown.wait_time = attack_cooldown_length_to_number[character_data[character][1]]
	
func set_movement_ability_cooldown(character: Character) -> void:
	movement_ability_cooldown.wait_time = movement_ability_cooldown_length_to_number[character_data[character][2]]
	
func set_sprite(new_sprite: Character) -> void:
	for character in character_data:
		character_data[character][3].visible = character == new_sprite
		character_data[character][4].visible = character == new_sprite
	current_body_sprite = character_data[new_sprite][3]
	current_head_sprite = character_data[new_sprite][4]


func set_weapon(new_weapon: Character) -> void:
	for character in character_data:
		character_data[character][4].visible = character == new_weapon
	current_weapon = character_data[new_weapon][5]

func set_character(character: Character) -> void:
	current_character = character
	attack_cooldown.stop()
	movement_ability_cooldown.stop()
	var old_animation = current_body_sprite.animation
	set_movement_speed(character)
	set_attack_cooldown(character)
	set_movement_ability_cooldown(character)
	set_sprite(character)
	set_weapon(character)
	play_body_animation(old_animation)
	
	
func play_body_animation(animation: String) -> void:
	current_body_sprite.play(animation)

func do_movement_ability(character: Character) -> void:
	if character == Character.HUNTER:
		movement_ability_in_action.start()
	
func _on_movement_ability_in_action_timeout() -> void:
	if current_character == Character.HUNTER:
		movement_ability_cooldown.start()

func move_weapon_with_mouse() -> void:
	current_weapon.position = Vector2.ZERO
	current_weapon.look_at(get_global_mouse_position())
	if get_global_mouse_position().x > position.x:
		current_weapon.position.x = 12
		current_weapon.position.y = (5 * sin(current_weapon.rotation)) + VERTICAL_WEAPON_OFFSET
	else:
		current_weapon.position.x = -12
		current_weapon.position.y = (5 * sin(current_weapon.rotation)) + VERTICAL_WEAPON_OFFSET
	
	current_weapon.rotation_degrees = wrap(current_weapon.rotation_degrees, 0, 360)
	if current_weapon.rotation_degrees > 90 and current_weapon.rotation_degrees < 270:
		current_weapon.scale.y = -1
	else:
		current_weapon.scale.y = 1

func determine_weapon_layer() -> void:
	if movement_direction == MovementDirection.UP:
		current_weapon.z_index = 0
	elif movement_direction == MovementDirection.DOWN:
		current_weapon.z_index = 1
	elif current_weapon.position.y < VERTICAL_WEAPON_OFFSET:
		current_weapon.z_index = 0
	else:
		current_weapon.z_index = 1

func attack():
	if current_character == Character.HUNTER:
		var projectile_instance = PROJECTILE.instantiate()
		get_tree().root.add_child(projectile_instance)
		projectile_instance.global_position = current_weapon.global_position
		projectile_instance.rotation = current_weapon.rotation
		projectile_instance.speed = 800
		projectile_instance.type = "crossbow"

func _on_reload_bar_animation_player_animation_finished(anim_name: StringName) -> void:
	reload_bar.visible = false
	
func set_head_direction() -> void:
	var head_angle_degrees: float = rad_to_deg(get_angle_to(get_global_mouse_position()))
	var head_direction: int = snapped(wrap(head_angle_degrees + 270, 0, 360), 22.5) / 22.5
	
	if head_direction > 7:
		current_head_sprite.play(str(7 - (head_direction - 8)))
		current_head_sprite.flip_h = true
		current_body_sprite.flip_h = true
	else:
		current_head_sprite.play(str(head_direction))
		current_head_sprite.flip_h = false
		current_body_sprite.flip_h = false
		

	
	
func _physics_process(delta: float) -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	if input_direction == Vector2.ZERO:
		play_body_animation("idle")
	else:
		play_body_animation("walk")
		
	if input_direction.y > 0:
		movement_direction = MovementDirection.DOWN
	elif input_direction.y < 0:
		movement_direction = MovementDirection.UP
	elif input_direction.x > 0:
		movement_direction = MovementDirection.RIGHT
	elif input_direction.x < 0:
		movement_direction = MovementDirection.LEFT

	determine_weapon_layer()
	
	if (current_character == Character.HUNTER and not movement_ability_in_action.is_stopped()):
		velocity += input_direction * delta * movement_speed * BASE_MOVEMENT_SPEED * 2
	else:
		velocity += input_direction * delta * movement_speed * BASE_MOVEMENT_SPEED
	velocity *= 0.7
	
	move_weapon_with_mouse()
	set_head_direction()
	if Input.is_action_just_pressed("attack") and attack_cooldown.is_stopped() and not (current_character == Character.HUNTER and not movement_ability_in_action.is_stopped()):
		attack_cooldown.start()
		reload_bar.visible = true
		reload_bar_animation_player.speed_scale = 1 / attack_cooldown.wait_time
		reload_bar_animation_player.play("slide_right")
		attack()
	
	if Input.is_action_just_pressed("movement_ability") and movement_ability_cooldown.is_stopped() and movement_ability_in_action.is_stopped():
		do_movement_ability(current_character)
	
	move_and_slide()
