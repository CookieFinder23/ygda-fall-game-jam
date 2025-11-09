extends Control
@onready var main_buttons: VBoxContainer = $MainButtons
@onready var controls: Panel = $Controls
@onready var black: Panel = $Black
@onready var animation_player: AnimationPlayer = $Black/AnimationPlayer
@onready var video_stream_player: VideoStreamPlayer = $CanvasLayer/SubViewportContainer/SubViewport/Panel/VideoStreamPlayer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var credits: Panel = $Credits

var start_game := true

func _ready() -> void:
	main_buttons.visible = true
	controls.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	animation_player.play("fade_out")

func _on_start_button_pressed() -> void:
	start_game = true
	animation_player.play("fade_in")
	black.visible = true

func _on_controls_button_pressed() -> void:
	main_buttons.visible = false
	controls.visible = true

func _on_back_button_pressed() -> void:
	main_buttons.visible = true
	controls.visible = false
	credits.visible = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		black.visible = false
	else:
		if start_game:
			get_tree().change_scene_to_file("res://scenes/world.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/opening_lore.tscn")

func _on_audio_stream_player_2d_finished() -> void:
	audio_stream_player_2d.play()

func _on_replay_button_pressed() -> void:
	start_game = false
	black.visible = true
	animation_player.play("fade_in")

func _on_credits_button_pressed() -> void:
	credits.visible = true
	main_buttons.visible = false
