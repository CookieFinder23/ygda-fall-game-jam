extends Node

@onready var player: CharacterBody2D = $Player
@onready var hearts_container: HBoxContainer = $CanvasLayer/HeartsContainer
@onready var inbetween_wave_timer: Timer = $InbetweenWaveTimer
@onready var wave_cooldown_timer: Timer = $WaveCooldownTimer


const ENEMY_SPAWNER = preload("res://scenes/enemy_spawner.tscn")
const IMP = preload("res://scenes/imp.tscn")
const GHOST = preload("res://scenes/ghost.tscn")
const SLIME = preload("res://scenes/slime.tscn")

func _on_inbetween_wave_timer_timeout() -> void:
	Global.wave_number += 1
	if Global.wave_number == 1:
		wave_1()
	elif Global.wave_number == 2:
		wave_2()

func _physics_process(delta: float) -> void:
	hearts_container.update_hearts(player.health)
	if Global.enemies_left <= 0 and wave_cooldown_timer.is_stopped():
		inbetween_wave_timer.start()
		wave_cooldown_timer.start()
	
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
	var enemy_selection = [IMP, GHOST, SLIME]
	var corner_selection = [1, 2, 3, 4]
	var enemy
	var corner: int
	for i in range(2):
		enemy = enemy_selection[randi_range(0, enemy_selection.size() - 1)]
		corner = corner_selection[randi_range(0, corner_selection.size() - 1)]
		corner_selection.erase(corner)
		enemy_selection.erase(enemy)
		var enemy_instance = ENEMY_SPAWNER.instantiate()
		enemy_instance.global_position = get_corner(corner)
		enemy_instance.type = enemy
		get_tree().root.add_child(enemy_instance)

func wave_2():
	var enemy_selection = [IMP, GHOST, SLIME]
	var corner_selection = [1, 2, 3, 4]
	var enemy
	var corner: int
	for i in range(3):
		enemy = enemy_selection[randi_range(0, enemy_selection.size() - 1)]
		corner = corner_selection[randi_range(0, corner_selection.size() - 1)]
		corner_selection.erase(corner)
		if enemy == IMP:
			enemy_selection.erase(enemy)
		var enemy_instance = ENEMY_SPAWNER.instantiate()
		enemy_instance.global_position = get_corner(corner)
		enemy_instance.type = enemy
		get_tree().root.add_child(enemy_instance)
