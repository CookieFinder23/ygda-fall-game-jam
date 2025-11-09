extends Node

var player_reference: Node = null
var deal_damage_audio_reference: Node = null
var fire_audio_reference: Node = null
var miss_audio_reference: Node = null
const EXPLOSION = preload("res://scenes/explosion.tscn")

var wave_number: int = 0
var picking_character: bool = false
var enemies_left: float = 0 # float becuase slime enemy has two halves
var begin_next_wave: bool = true
var remaining_characters =  ["ice_mage", "knight", "ninja"]
var clear_screen: bool = false
var animation_lock: bool = false
var final_boss_health: int = 48
