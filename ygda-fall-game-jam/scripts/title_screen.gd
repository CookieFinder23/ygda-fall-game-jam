extends Control
@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $Options
@onready var black: Panel = $Black
@onready var animation_player: AnimationPlayer = $Black/AnimationPlayer
@onready var video_stream_player: VideoStreamPlayer = $CanvasLayer/SubViewportContainer/SubViewport/Panel/VideoStreamPlayer

func _ready() -> void:
	#video_stream_player.speed_scale = 0.2
	main_buttons.visible = true
	options.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	animation_player.play("fade_out")

func _on_start_button_pressed() -> void:
	animation_player.play("fade_in")
	black.visible = true

func _on_options_button_pressed() -> void:
	main_buttons.visible = false
	options.visible = true
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_back_button_pressed() -> void:
	main_buttons.visible = true
	options.visible = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		black.visible = false
	else:
		get_tree().change_scene_to_file("res://scenes/world.tscn")
