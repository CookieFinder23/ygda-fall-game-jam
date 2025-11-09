extends AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var world: Node = $".."

func _on_trophy_area_body_entered(body: Node2D) -> void:
	if body == Global.player_reference:
		animation_player.play("fade_out")
		Global.animation_lock = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	world.fade_to_black()
