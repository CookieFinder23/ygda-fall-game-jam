extends Node

var player_reference: Node = null
const EXPLOSION = preload("res://scenes/explosion.tscn")

var wave_number: int = 0
var enemies_left: float = 0 # float becuase slime enemy has two halves
