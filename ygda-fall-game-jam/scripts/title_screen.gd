extends Control
@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $Options
@onready var black: Panel = $Black

func _ready() -> void:
	main_buttons.visible = true
	options.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_options_button_pressed() -> void:
	main_buttons.visible = false
	options.visible = true
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_back_button_pressed() -> void:
	main_buttons.visible = true
	options.visible = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	black.queue_free()
