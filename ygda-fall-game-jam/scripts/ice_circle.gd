extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area2D = $Hitbox

var already_hit_bodies = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("spin")
func _on_hitbox_body_entered(body: Node2D) -> void:
	print("e")
	body.take_damage(3)
	body.stun()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
