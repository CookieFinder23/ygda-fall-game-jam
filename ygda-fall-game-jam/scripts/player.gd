extends CharacterBody2D

@onready var hunter_sprite: AnimatedSprite2D = $HunterSprite
@onready var knight_sprite: AnimatedSprite2D = $KnightSprite
@onready var player_collision: CollisionShape2D = $PlayerCollision
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var movement_ability_cooldown: Timer = $MovementAbilityCooldown
@onready var timer: Timer = $Timer
@onready var movement_ability_in_action: Timer = $MovementAbilityInAction
@onready var hunter_weapon_sprite: AnimatedSprite2D = $HunterWeaponSprite
@onready var knight_weapon_sprite: AnimatedSprite2D = $KnightWeaponSprite

const BASE_MOVEMENT_SPEED: int = 30

var current_sprite: AnimatedSprite2D
var current_weapon: AnimatedSprite2D
var current_character: Character
var movement_speed: int

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
	AttackCooldownLength.FAST: 1,
	AttackCooldownLength.NORMAL: 3,
	AttackCooldownLength.SLOW: 5
}


enum MovementAbilityCooldownLength {
	FAST,
	NORMAL,
	SLOW
}

var movement_ability_cooldown_length_to_number = {
	MovementAbilityCooldownLength.FAST: 1,
	MovementAbilityCooldownLength.NORMAL: 3,
	MovementAbilityCooldownLength.SLOW: 5
}

enum Character {
	HUNTER,
	KNIGHT
}

var character_data = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	character_data = {
	Character.HUNTER: [MovementSpeed.NORMAL, AttackCooldownLength.NORMAL, MovementAbilityCooldownLength.NORMAL, hunter_sprite, hunter_weapon_sprite],
	Character.KNIGHT: [MovementSpeed.NORMAL, AttackCooldownLength.NORMAL, MovementAbilityCooldownLength.NORMAL, knight_sprite, knight_weapon_sprite]
	}
	current_sprite = hunter_sprite
	set_character(Character.HUNTER)
	play_animation("down")

func set_movement_speed(character: Character) -> void:
	movement_speed = movement_speed_to_number[character_data[character][0]]

func set_attack_cooldown(character: Character) -> void:
	attack_cooldown.wait_time = attack_cooldown_length_to_number[character_data[character][1]]
	
func set_movement_ability_cooldown(character: Character) -> void:
	movement_ability_cooldown.wait_time = movement_ability_cooldown_length_to_number[character_data[character][2]]
	
func set_sprite(new_sprite: Character) -> void:
	for character in character_data:
		character_data[character][3].visible = character == new_sprite
	current_sprite = character_data[new_sprite][3]

func set_weapon(new_weapon: Character) -> void:
	for character in character_data:
		character_data[character][4].visible = character == new_weapon
	current_weapon = character_data[new_weapon][4]

func set_character(character: Character) -> void:
	current_character = character
	attack_cooldown.stop()
	movement_ability_cooldown.stop()
	var old_animation = current_sprite.animation
	set_movement_speed(character)
	set_attack_cooldown(character)
	set_movement_ability_cooldown(character)
	set_sprite(character)
	set_weapon(character)
	play_animation(old_animation)
	
	
func play_animation(animation: String) -> void:
	current_sprite.play(animation)

func do_movement_ability(character: Character) -> void:
	if character == Character.HUNTER:
		movement_ability_in_action.start()
	
func _on_movement_ability_in_action_timeout() -> void:
	if current_character == Character.HUNTER:
		movement_ability_cooldown.start()

func move_weapon_with_mouse() -> void:
	current_weapon.position.x = 0
	current_weapon.position.y = 0
	current_weapon.look_at(get_global_mouse_position())
	current_weapon.position.x = (10 * cos(current_weapon.rotation))
	current_weapon.position.y = (5 * sin(current_weapon.rotation))

func _physics_process(delta: float) -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	if input_direction.y > 0:
		play_animation("down")
		current_weapon.z_index = 1
	elif input_direction.y < 0:
		play_animation("up")
		current_weapon.z_index = 0
	elif input_direction.x > 0:
		play_animation("right")
		current_weapon.z_index = 1
	elif input_direction.x < 0:
		play_animation("left")
		current_weapon.z_index = 1
		
	if (current_character == Character.HUNTER and not movement_ability_in_action.is_stopped()):
		velocity += input_direction * delta * movement_speed * BASE_MOVEMENT_SPEED * 2
	else:
		velocity += input_direction * delta * movement_speed * BASE_MOVEMENT_SPEED

	velocity *= 0.7
	
	
	move_weapon_with_mouse()
	if Input.is_action_just_pressed("attack") and attack_cooldown.is_stopped():
		attack_cooldown.start()
		print("attack")
	
	if Input.is_action_just_pressed("movement_ability") and movement_ability_cooldown.is_stopped() and movement_ability_in_action.is_stopped():
		do_movement_ability(current_character)
		print("movement ability")
	
	move_and_slide()
