extends Panel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_lore_lifetime_timeout() -> void:
	animation_player.play("fade_out")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
