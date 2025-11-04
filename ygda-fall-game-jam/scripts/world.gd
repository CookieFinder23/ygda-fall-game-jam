extends Node

@onready var player: CharacterBody2D = $Player
@onready var hearts_container: HBoxContainer = $CanvasLayer/HeartsContainer
@onready var inbetween_wave_timer: Timer = $InbetweenWaveTimer
@onready var wave_cooldown_timer: Timer = $WaveCooldownTimer


const ENEMY_SPAWNER = preload("res://scenes/enemy_spawner.tscn")
const IMP = preload("res://scenes/imp.tscn")
const GHOST = preload("res://scenes/ghost.tscn")
const SLIME = preload("res://scenes/slime.tscn")
const QUIETUS = preload("res://scenes/quietus.tscn")
const CHARACTER_OPTION = preload("res://scenes/character_option.tscn")

var remaining_characters = ["ice_mage", "knight"]

func _ready() -> void:
	Global.wave_number = 0
	Global.picking_character = false
	Global.enemies_left = 0
	Global.begin_next_wave = true

func _on_inbetween_wave_timer_timeout() -> void:
	Global.wave_number += 1
	if Global.wave_number == 1:
		wave_1()
	elif Global.wave_number == 2:
		wave_2()

func _physics_process(_delta: float) -> void:
	hearts_container.update_hearts(player.health)
	if Global.begin_next_wave == true:
		Global.player_reference.transformation_cooldown.start()
		Global.player_reference.set_character(Global.player_reference.transformation_cycle[Global.player_reference.transformation_cycle.size() - 1])
		Global.begin_next_wave = false
		inbetween_wave_timer.start()
		wave_cooldown_timer.start()
	elif Global.enemies_left <= 0 and wave_cooldown_timer.is_stopped() and Global.picking_character == false and Global.player_reference.position.y > 128:
		Global.picking_character = true
		create_character_choice()
		
func create_character_choice() -> void:
	var left_character = remaining_characters.pick_random()
	var right_character = remaining_characters.pick_random()
	while right_character == left_character:
		right_character = remaining_characters.pick_random()
	var left_character_instance = CHARACTER_OPTION.instantiate()
	left_character_instance.position = Vector2(240, 60)
	left_character_instance.type = left_character
	var right_character_instance = CHARACTER_OPTION.instantiate()
	right_character_instance.position = Vector2(400, 60)
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
		
func wave_1():
	return
	var enemy_selection = [IMP, GHOST, SLIME]
	var corner_selection = [1, 2, 3, 4]
	var enemy
	var corner: int
	for i in range(2):
		enemy = enemy_selection.pick_random()
		corner = corner_selection.pick_random()
		corner_selection.erase(corner)
		enemy_selection.erase(enemy)
		var enemy_instance = ENEMY_SPAWNER.instantiate()
		enemy_instance.global_position = get_corner(corner)
		enemy_instance.type = enemy
		add_child(enemy_instance)

func wave_2():
	var enemy_selection = [IMP, GHOST, SLIME, QUIETUS]
	var corner_selection = [1, 2, 3, 4]
	var enemy
	var corner: int
	var picked_enemies = []
	for i in range(3):
		enemy = enemy_selection.pick_random()
		picked_enemies.append(enemy)
		corner = corner_selection.pick_random()
		corner_selection.erase(corner)
		enemy_selection.erase(enemy)
		var enemy_instance = ENEMY_SPAWNER.instantiate()
		enemy_instance.global_position = get_corner(corner)
		enemy_instance.type = enemy
		add_child(enemy_instance)
