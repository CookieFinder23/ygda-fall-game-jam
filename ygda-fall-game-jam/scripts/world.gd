extends Node

@onready var player: CharacterBody2D = $Player
@onready var hearts_container: HFlowContainer = $CanvasLayer/HeartsContainer
@onready var inbetween_wave_timer: Timer = $InbetweenWaveTimer
@onready var wave_cooldown_timer: Timer = $WaveCooldownTimer
@onready var fade_to_black_animation_player: AnimationPlayer = $CanvasLayer/FadeToBlack/FadeToBlackAnimationPlayer
@onready var music: AudioStreamPlayer2D = $Music
@onready var deal_damage_audio: AudioStreamPlayer2D = $DealDamageAudio
@onready var fire_audio: AudioStreamPlayer2D = $FireAudio
@onready var miss_audio: AudioStreamPlayer2D = $MissAudio


const ENEMY_SPAWNER = preload("res://scenes/enemy_spawner.tscn")
const IMP = preload("res://scenes/imp.tscn")
const GHOST = preload("res://scenes/ghost.tscn")
const SLIME = preload("res://scenes/slime.tscn")
const QUIETUS = preload("res://scenes/quietus.tscn")
const CULTIST = preload("res://scenes/cultist.tscn")
const CHARACTER_OPTION = preload("res://scenes/character_option.tscn")
const FINAL_BOSS = preload("res://scenes/final_boss.tscn")

var beat_game := false

func _ready() -> void:
	Global.deal_damage_audio_reference = deal_damage_audio
	Global.fire_audio_reference = fire_audio
	Global.miss_audio_reference = miss_audio
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	Global.wave_number = 0
	Global.picking_character = false
	Global.enemies_left = 0
	Global.begin_next_wave = true
	Global.remaining_characters =  ["ice_mage", "knight", "ninja"]
	Global.final_boss_health = 48
	fade_to_black_animation_player.play("fade_out")

func _on_inbetween_wave_timer_timeout() -> void:
	Global.wave_number += 1
	if Global.wave_number == 1:
		make_wave([IMP, SLIME, GHOST], 2)
	elif Global.wave_number == 2:
		make_wave([IMP, SLIME, GHOST, QUIETUS], 3)
	elif Global.wave_number == 3:
		var wave_three_enemy_selection = [CULTIST, QUIETUS]
		wave_three_enemy_selection.append([IMP, SLIME, GHOST].pick_random())
		make_wave(wave_three_enemy_selection, 3)
	elif Global.wave_number == 4:
		var enemy_instance = FINAL_BOSS.instantiate()
		enemy_instance.global_position = Vector2(320, 300)
		Global.enemies_left = 1
		add_child(enemy_instance)

func _physics_process(_delta: float) -> void:
	hearts_container.update_hearts(player.health)
	if Global.begin_next_wave == true:
		Global.player_reference.transformation_cooldown.start()
		Global.player_reference.set_character(Global.player_reference.transformation_cycle[Global.player_reference.transformation_cycle.size() - 1])
		Global.begin_next_wave = false
		inbetween_wave_timer.start()
		wave_cooldown_timer.start()
	elif Global.enemies_left <= 0 and wave_cooldown_timer.is_stopped() and Global.picking_character == false and Global.player_reference.position.y > 118 and Global.wave_number < 4:
		Global.picking_character = true
		create_character_choice()
		
func create_character_choice() -> void:
	if Global.remaining_characters.size() == 1:
		var character_instance = CHARACTER_OPTION.instantiate()
		character_instance.type = Global.remaining_characters[0]
		character_instance.position = Vector2(320, 50)
		add_child(character_instance)
	else:
		var left_character = Global.remaining_characters.pick_random()
		var right_character = Global.remaining_characters.pick_random()
		while right_character == left_character:
			right_character = Global.remaining_characters.pick_random()
		var left_character_instance = CHARACTER_OPTION.instantiate()
		left_character_instance.position = Vector2(240, 50)
		left_character_instance.type = left_character
		var right_character_instance = CHARACTER_OPTION.instantiate()
		right_character_instance.position = Vector2(400, 50)
		right_character_instance.type = right_character
		add_child(left_character_instance)
		add_child(right_character_instance)
	

func get_corner(corner: int) -> Vector2:
	if corner == 1:
		return Vector2(188, 48)
	elif corner == 2:
		return Vector2(452, 48)
	elif corner == 3:
		return Vector2(188, 312)
	else:
		return Vector2(452, 312)

func make_wave(enemy_selection: Array, amount_of_enemies: int) -> void:
	var corner_selection = [1, 2, 3, 4]
	var enemy
	var corner: int
	var picked_enemies = []
	for i in range(amount_of_enemies):
		enemy = enemy_selection.pick_random()
		picked_enemies.append(enemy)
		corner = corner_selection.pick_random()
		corner_selection.erase(corner)
		enemy_selection.erase(enemy)
		var enemy_instance = ENEMY_SPAWNER.instantiate()
		enemy_instance.global_position = get_corner(corner)
		enemy_instance.type = enemy
		enemy_instance.wave_stagger_time = i * 2
		add_child(enemy_instance)

func fade_to_black()  -> void:
	fade_to_black_animation_player.play("fade_in")
	
func _on_fade_to_black_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		if beat_game:
			pass
			print("!")
		else:
			get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func _on_audio_stream_player_2d_finished() -> void: # since looping doesnt work on itch.io
	music.play()
