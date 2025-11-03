extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("spin")
	
func _on_hitbox_body_entered(body: Node2D) -> void:
	body.take_damage(2)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
