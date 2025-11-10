extends Panel
@onready var animation_player: AnimationPlayer = $Black/AnimationPlayer
@onready var length: Timer = $Length
@onready var first_video: VideoStreamPlayer = $CanvasLayer/SubViewportContainer/SubViewport/Panel/FirstVideo
@onready var second_video: VideoStreamPlayer = $CanvasLayer/SubViewportContainer/SubViewport/Panel/SecondVideo

func _ready() -> void:
	first_video.play()

func _on_first_video_finished() -> void:
	second_video.visible = true
	first_video.visible = false
	second_video.play()
	

func _on_length_timeout() -> void:
	animation_player.play("fade_in")



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
