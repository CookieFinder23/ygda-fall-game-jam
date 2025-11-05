extends Node

var player_reference: Node = null
const EXPLOSION = preload("res://scenes/explosion.tscn")

var wave_number: int = 0
var picking_character: bool = false
var enemies_left: float = 0 # float becuase slime enemy has two halves
var begin_next_wave: bool = true
var remaining_characters =  ["ice_mage", "knight", "ninja"]
