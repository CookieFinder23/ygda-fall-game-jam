extends CharacterBody2D

@onready var world: Node = $".."
@onready var hunter_body_sprite: AnimatedSprite2D = $HunterBodySprite
@onready var hunter_head_sprite: AnimatedSprite2D = $HunterHeadSprite
@onready var knight_body_sprite: AnimatedSprite2D = $KnightBodySprite
@onready var player_hurtbox_collision: CollisionShape2D = $Hurtbox/PlayerHurtboxCollision
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var movement_ability_cooldown: Timer = $MovementAbilityCooldown
@onready var movement_ability_in_action: Timer = $MovementAbilityInAction
@onready var transformation_cooldown: Timer = $TransformationCooldown
@onready var reload_bar: Sprite2D = $ReloadBar
@onready var reload_bar_animation_player: AnimationPlayer = $ReloadBar/ReloadBarVertical/ReloadBarAnimationPlayer
@onready var hunter_weapon_sprite: AnimatedSprite2D = $HunterWeaponSprite
@onready var knight_weapon_sprite: AnimatedSprite2D = $KnightWeaponSprite
@onready var knight_head_sprite: AnimatedSprite2D = $KnightHeadSprite
@onready var ice_mage_body_sprite: AnimatedSprite2D = $IceMageBodySprite
@onready var ice_mage_head_sprite: AnimatedSprite2D = $IceMageHeadSprite
@onready var change_sceen_to_start_screen: Timer = $ChangeSceenToStartScreen
@onready var i_frames: Timer = $IFrames
@onready var ninja_head_sprite: AnimatedSprite2D = $NinjaHeadSprite
@onready var ninja_body_sprite: AnimatedSprite2D = $NinjaBodySprite
@onready var slash_timer: Timer = $SlashTimer
@onready var shield_collision: CollisionShape2D = $ShieldCollisionArea/ShieldCollision
@onready var shield_collision_area: Area2D = $ShieldCollisionArea
@onready var sword_collision: CollisionShape2D = $SwordCollisionArea/SwordCollision
@onready var sword_collision_area: Area2D = $SwordCollisionArea
@onready var take_damage_audio: AudioStreamPlayer2D = $TakeDamageAudio
@onready var heal_audio: AudioStreamPlayer2D = $HealAudio
@onready var deal_damage_audio: AudioStreamPlayer2D = $DealDamageAudio
@onready var woosh_audio: AudioStreamPlayer2D = $WooshAudio
@onready var smoke_dash_audio: AudioStreamPlayer2D = $SmokeDashAudio

const ICE_CIRCLE = preload("res://scenes/ice_circle.tscn")
const PROJECTILE = preload("res://scenes/projectile.tscn")
const BASE_MOVEMENT_SPEED: int = 30
const VERTICAL_WEAPON_OFFSET: int = 2

var current_body_sprite: AnimatedSprite2D
var current_head_sprite: AnimatedSprite2D
var current_weapon: AnimatedSprite2D
var current_character: Character
var movement_speed: int
var movement_direction: MovementDirection
var health = 6
var next_character: Character
var transformation_cycle = []
var slash_start_degrees: int
var sword_hit_bodies = []

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
	MovementAbilityCooldownLength.FAST: 0.25,
	MovementAbilityCooldownLength.NORMAL: 0.75,
	MovementAbilityCooldownLength.SLOW: 2
}
enum Character {
	HUNTER,
	KNIGHT,
	ICE_MAGE,
	NINJA
}
var character_data = {}

func _enter_tree() -> void:
	Global.player_reference = self

func add_character(character: String) -> void:
	heal_audio.play()
	if health < 6:
		health += 1
	if character == "ice_mage":
		transformation_cycle.append(Character.ICE_MAGE)
	if character == "knight":
		transformation_cycle.append(Character.KNIGHT)
	if character == "ninja":
		transformation_cycle.append(Character.NINJA)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	character_data = {
	Character.HUNTER: [MovementSpeed.NORMAL, AttackCooldownLength.NORMAL, MovementAbilityCooldownLength.NORMAL, hunter_body_sprite, hunter_head_sprite, hunter_weapon_sprite, 8],
	Character.KNIGHT: [MovementSpeed.NORMAL, AttackCooldownLength.FAST, MovementAbilityCooldownLength.FAST, knight_body_sprite, knight_head_sprite, knight_weapon_sprite, 8],
	Character.ICE_MAGE: [MovementSpeed.SLOW, AttackCooldownLength.NORMAL, MovementAbilityCooldownLength.SLOW, ice_mage_body_sprite, ice_mage_head_sprite, null, 8],
	Character.NINJA: [MovementSpeed.FAST, AttackCooldownLength.FAST, MovementAbilityCooldownLength.FAST, ninja_body_sprite, ninja_head_sprite, null, 10]
	}
	transformation_cycle = [Character.HUNTER]
	velocity.y = 0.1 # since for some reason the player has to move a bit for the head to snap into place
	
	current_body_sprite = hunter_body_sprite
	set_character(Character.HUNTER)
	next_character = current_character
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
	
	if current_body_sprite == hunter_body_sprite or current_body_sprite == knight_body_sprite:
		current_body_sprite.position = Vector2.ZERO
	current_head_sprite = character_data[new_sprite][4]
	if current_head_sprite == hunter_head_sprite:
		current_head_sprite.position = Vector2(0, -11)
	elif current_head_sprite == knight_head_sprite:
		current_head_sprite.position = Vector2(0, -11.5)


func set_weapon(new_weapon: Character) -> void:
	for character in character_data:
		if character_data[character][5] != null:
			character_data[character][5].visible = character == new_weapon
	current_weapon = character_data[new_weapon][5]
	if current_weapon == hunter_weapon_sprite:
		current_weapon.play("idle")

func set_character(character: Character) -> void:
	current_character = character
	attack_cooldown.stop()
	movement_ability_in_action.stop()
	movement_ability_cooldown.stop()
	reload_bar_animation_player.stop()
	reload_bar.visible = false
	shield_collision.disabled = true
	sword_collision.disabled = true
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
	if character == Character.HUNTER or character == Character.KNIGHT:
		movement_ability_in_action.wait_time = 1
		movement_ability_in_action.start()
	elif character == Character.ICE_MAGE:
		var ice_circle_instance = ICE_CIRCLE.instantiate()
		ice_circle_instance.global_position = global_position
		ice_circle_instance.is_attack = false
		get_tree().root.add_child(ice_circle_instance)
		movement_ability_in_action.wait_time = 1
		movement_ability_in_action.start()
	elif character == Character.NINJA:
		var explosion_instance = Global.EXPLOSION.instantiate()
		explosion_instance.global_position = global_position
		explosion_instance.smoke = true
		world.add_child(explosion_instance)
		current_body_sprite.visible = false
		current_head_sprite.visible = false
		position += velocity * 0.75
		movement_ability_in_action.wait_time = 0.1
		movement_ability_in_action.start()
	
func _on_movement_ability_in_action_timeout() -> void:
	movement_ability_cooldown.start()
	if current_character == Character.NINJA:
		var explosion_instance = Global.EXPLOSION.instantiate()
		explosion_instance.global_position = global_position
		explosion_instance.smoke = true
		world.add_child(explosion_instance)
		current_body_sprite.visible = true
		current_head_sprite.visible = true
		if i_frames.time_left < 0.2:
			i_frames.start(0.2)

func do_knight_slash() -> void:
	var time_to_use: float
	sword_collision_area.position = current_weapon.position
	sword_collision_area.rotation = current_weapon.rotation
	if slash_timer.time_left > slash_timer.wait_time / 2:
		time_to_use = slash_timer.wait_time - slash_timer.time_left
	else:
		time_to_use = slash_timer.time_left
	if current_weapon.position.x < current_body_sprite.position.x:
		current_weapon.rotation_degrees = slash_start_degrees - time_to_use * 500 
	else:
		current_weapon.rotation_degrees = slash_start_degrees + time_to_use * 500

func move_weapon_with_mouse() -> void:
	if current_character == Character.KNIGHT:
		if movement_ability_in_action.is_stopped():
			current_weapon.play("sword")
			shield_collision.disabled = true
		else:
			current_weapon.play("shield")
			shield_collision.disabled = false
	current_weapon.position = Vector2.ZERO
	current_weapon.look_at(get_global_mouse_position())
	if current_character == Character.KNIGHT and current_weapon.animation == "shield":
			current_weapon.position.x = (30 * cos(current_weapon.rotation))
			current_weapon.position.y = (35 * sin(current_weapon.rotation))
			current_weapon.rotation = 0
			shield_collision_area.position = current_weapon.position
	else:
		if get_global_mouse_position().x > position.x:
			current_weapon.position.x = 10
			current_weapon.position.y = (5 * sin(current_weapon.rotation)) + VERTICAL_WEAPON_OFFSET
		else:
			current_weapon.position.x = -10
			current_weapon.position.y = (5 * sin(current_weapon.rotation)) + VERTICAL_WEAPON_OFFSET
		if current_character == Character.KNIGHT:
			current_weapon.position.y -= VERTICAL_WEAPON_OFFSET
			current_weapon.position.y *= 5
	
	current_weapon.rotation_degrees = wrap(current_weapon.rotation_degrees, 0, 360)
	if current_weapon.rotation_degrees > 90 and current_weapon.rotation_degrees < 270:
		current_weapon.scale = Vector2(1, -1)
	else:
		current_weapon.scale = Vector2(1, 1)

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
		hunter_weapon_sprite.play("reload")
		var projectile_instance = PROJECTILE.instantiate()
		projectile_instance.global_position = current_weapon.global_position
		projectile_instance.rotation = current_weapon.rotation
		projectile_instance.speed = 600
		projectile_instance.type = "crossbow"
		projectile_instance.is_player_owned = true
		projectile_instance.damage = 3
		get_tree().root.add_child(projectile_instance)
		woosh_audio.play()
	elif current_character == Character.ICE_MAGE:
		var ice_circle_instance = ICE_CIRCLE.instantiate()
		ice_circle_instance.global_position.x = clamp(get_global_mouse_position().x, 188, 452)
		ice_circle_instance.global_position.y = clamp(get_global_mouse_position().y, 48, 312)
		ice_circle_instance.is_attack = true
		get_tree().root.add_child(ice_circle_instance)
	elif current_character == Character.KNIGHT:
		sword_hit_bodies = []
		current_weapon.position.x *= 2
		slash_timer.start()
		slash_start_degrees = current_weapon.rotation_degrees
	elif current_character == Character.NINJA:
		look_at(get_global_mouse_position())
		var middle_dir = rotation_degrees
		var spread = 45
		for i in range(3):
			var projectile_instance = PROJECTILE.instantiate()
			projectile_instance.global_position = global_position
			projectile_instance.rotation_degrees = middle_dir + (i - 1) * 15
			projectile_instance.speed = 300
			projectile_instance.type = "ninja_star"
			projectile_instance.is_player_owned = true
			projectile_instance.damage = 1
			get_tree().root.add_child(projectile_instance)
		rotation_degrees = 0
		
func _on_reload_bar_animation_player_animation_finished(_anim_name: StringName) -> void:
	reload_bar.visible = false
	
func set_head_direction() -> void:
	var head_angle_degrees: float = rad_to_deg(get_angle_to(get_global_mouse_position()))
	var amount_of_heads: int = character_data[current_character][6]
	var head_increment: float = 180 / float(amount_of_heads)
	var head_direction: int = snapped(wrap(head_angle_degrees + 270, 0, 360), head_increment) / head_increment
	if head_direction == 16:
		head_direction = 15
	if head_direction > amount_of_heads - 1:
		if head_direction == head_increment:
			if amount_of_heads == 8:
				current_head_sprite.play("7")
			elif amount_of_heads == 5:
				current_head_sprite.play("4")
		else:
			current_head_sprite.play(str((amount_of_heads - 1) - (head_direction - amount_of_heads)))
		current_head_sprite.flip_h = true
		current_body_sprite.flip_h = true
		if current_character == Character.ICE_MAGE:
			if current_body_sprite.animation == "idle_back":
				current_body_sprite.position.x = 5
			else:
				current_body_sprite.position.x = -6
			current_head_sprite.position.x = -5
		elif current_character == Character.HUNTER:
			if current_body_sprite.animation == "walk":
				current_head_sprite.position.x = -2
			else:
				current_head_sprite.position.x = -1
	else:
		current_head_sprite.play(str(head_direction))
		current_head_sprite.flip_h = false
		current_body_sprite.flip_h = false
		current_head_sprite.position.x = -4
		if current_character == Character.ICE_MAGE:
			if current_body_sprite.animation == "idle_back":
				current_body_sprite.position.x = -8
			else:
				current_body_sprite.position.x = 3
			current_head_sprite.position.x = 3
		elif current_character == Character.HUNTER:
			if current_body_sprite.animation == "walk":
				current_head_sprite.position.x = 2
			else:
				current_head_sprite.position.x = 0
		
	if current_character == Character.ICE_MAGE:
		if (current_body_sprite.animation == "idle" or current_body_sprite.animation == "idle_back") and current_body_sprite.frame == 1:
			current_head_sprite.position.y = -5
		else:
			current_head_sprite.position.y = -6
	elif current_character == Character.NINJA:
		if current_body_sprite.animation == "idle":
			if current_body_sprite.frame == 1:
				current_head_sprite.position.y = -12
			else:
				current_head_sprite.position.y = -11.5
			current_head_sprite.position.x = 2
			if current_body_sprite.flip_h:
				current_body_sprite.position.x = 4
			else:
				current_body_sprite.position.x = 0
			current_body_sprite.position.y = 4
		else:
			current_head_sprite.position.y = -11.5
			current_body_sprite.position = Vector2(-4, 0)
			if current_body_sprite.flip_h:
				current_head_sprite.position.x = 0
			else:
				current_head_sprite.position.x = -8
	elif current_character == Character.KNIGHT:
		if current_body_sprite.animation == "idle":
			current_body_sprite.position = Vector2(0, 4)
			current_head_sprite.position = Vector2(0, -11)
			if current_body_sprite.frame == 1:
				current_body_sprite.position.y += 0.5
				current_head_sprite.position.y += 1
		else:
			current_body_sprite.position = Vector2.ZERO
			current_head_sprite.position = Vector2(0, -11.5)
func _physics_process(delta: float) -> void:
	if health > 0:
		if i_frames.is_stopped():
			player_hurtbox_collision.disabled = false
			current_body_sprite.modulate.a = 1
			current_head_sprite.modulate.a = 1
		else:
			player_hurtbox_collision.disabled = true
			current_body_sprite.modulate.a = 0.25 + (1 - (i_frames.time_left / i_frames.wait_time)) * 0.75
			current_head_sprite.modulate.a = 0.25 + (1 - (i_frames.time_left / i_frames.wait_time)) * 0.75
		var input_direction = Input.get_vector("left", "right", "up", "down")
		if Global.animation_lock:
			input_direction = Vector2.ZERO
		if input_direction == Vector2.ZERO:
			if current_character == Character.ICE_MAGE and global_position.y > get_global_mouse_position().y:
				play_body_animation("idle_back")
			else:
				play_body_animation("idle")
		else:
			if current_character == Character.HUNTER and not movement_ability_in_action.is_stopped():
				play_body_animation("movement")
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

		if (current_character == Character.HUNTER and (not movement_ability_in_action.is_stopped() or current_body_sprite.animation == "idle")):
			current_weapon.visible = false
			velocity += input_direction * delta * movement_speed * BASE_MOVEMENT_SPEED * 1.75
		else:
			if (current_weapon != null):
				current_weapon.visible = true
				determine_weapon_layer()
			velocity += input_direction * delta * movement_speed * BASE_MOVEMENT_SPEED
		velocity *= 0.7
		if (current_weapon != null):
			if current_character == Character.KNIGHT and not slash_timer.is_stopped():
				do_knight_slash()
				sword_collision.disabled = false
			else:
				sword_collision.disabled = true
				move_weapon_with_mouse()
		set_head_direction()
		
		var knight_shield_active: bool = false
		if current_character == Character.KNIGHT:
			knight_shield_active = current_weapon.animation == "shield"
		
		if Input.is_action_just_pressed("attack") and attack_cooldown.is_stopped() and not (current_character == Character.HUNTER and not movement_ability_in_action.is_stopped()) and not knight_shield_active:
			attack_cooldown.start()
			reload_bar.visible = not current_character == Character.KNIGHT
			reload_bar_animation_player.speed_scale = 1 / attack_cooldown.wait_time
			reload_bar_animation_player.play("slide_right")
			attack()
		
		if Input.is_action_just_pressed("movement_ability") and movement_ability_cooldown.is_stopped() and movement_ability_in_action.is_stopped():
			do_movement_ability(current_character)
				
		move_and_slide()

func take_damage(_damage: int) -> void:
	if i_frames.is_stopped() and not (current_character == Character.NINJA and not movement_ability_in_action.is_stopped()):
		take_damage_audio.play()
		i_frames.start()
		health -= 1
		var explosion_instance = Global.EXPLOSION.instantiate()
		explosion_instance.global_position = global_position
		if health == 0:
			explosion_instance.death = true
			visible = false
			change_sceen_to_start_screen.start()
		else:
			explosion_instance.death = false
		get_tree().root.add_child(explosion_instance)

func _on_change_sceen_to_start_screen_timeout() -> void:
	world.fade_to_black()
	
func _on_hurtbox_body_entered(_body: Node2D) -> void:
	take_damage(1)

func _on_transformation_cooldown_timeout() -> void:
	if transformation_cycle.size() > 1:
		set_character(next_character)
		if transformation_cycle.find(current_character) == transformation_cycle.size() - 1:
			next_character = transformation_cycle[0]
		else:
			next_character = transformation_cycle[transformation_cycle.find(current_character) + 1]

func _on_hunter_weapon_sprite_animation_finished() -> void:
	if hunter_weapon_sprite.animation == "reload":
		hunter_weapon_sprite.play("idle")

func _on_shield_collision_area_body_entered(body: Node2D) -> void:
	body.stun(0.25)

func _on_sword_collision_area_body_entered(body: Node2D) -> void:
	if not sword_hit_bodies.has(body):
		sword_hit_bodies.append(body)
		body.take_damage(3)
		deal_damage_audio.play()
