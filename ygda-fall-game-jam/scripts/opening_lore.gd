extends Panel
@onready var lore_animations: AnimationPlayer = $LoreAnimations
@onready var black_animations: AnimationPlayer = $Black/BlackAnimations
@onready var lore_waittime: Timer = $LoreWaittime
@onready var lore: Label = $Lore
@onready var final_boss_video_player: VideoStreamPlayer = $CanvasLayer/SubViewportContainer/SubViewport/Panel/FinalBossVideoPlayer
@onready var intro_video_player: VideoStreamPlayer = $CanvasLayer/SubViewportContainer/SubViewport/Panel/IntroVideoPlayer
@onready var lore_lifetime: Timer = $LoreLifetime
@onready var black: Panel = $Black
@onready var end_timer: Timer = $EndTimer
@onready var safety_timer: Timer = $SafetyTimer
@onready var skip_fade_animation: AnimationPlayer = $SkipFadeAnimation

var lore_text = ["You are an alien who doesn't know its true form.",
"The further you progress through the dungeon, the more you shift between your forms",
"This is the knight, who wields a powerful sword and a shield that blocks projectiles and stuns enemies.",
"This is the ice mage, who summons rings of ice and a forcefield, which both freeze enemies in their tracks, and block projectiles.",
"This is the ninja, who throws deadly ninja stars, and can dash faster than the eye can see.",
"This is the hunter, who can shoot arrows with pinpoint precision, and sprints with great speed.",
"Legends say this dungeon can find one's true form.",
"All you have to do is slay the dark wizard Eidolon."]
var current_lore := 0
var end := false
var true_end := false
var start := true
var truer_end := false

func _ready() -> void:
	lore.text = lore_text[current_lore]

func _on_lore_lifetime_timeout() -> void:
	if start:
		intro_video_player.play()
		intro_video_player.visible = true
		black_animations.play("fade_out")
		start = false
	if not end and end_timer.is_stopped():
		lore_animations.play("fade_out")
		if current_lore == lore_text.size() - 1:
			black_animations.play("fade_in")
			end = true

func _on_lore_animations_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out" and  current_lore < lore_text.size() - 1:
		current_lore += 1
		lore_waittime.start()
		lore.text = lore_text[current_lore]

func _process(delta: float) -> void:
	if Input.is_anything_pressed() and not true_end:
		end = true
		true_end = true
		black.z_index = 99
		if not (black_animations.is_playing() and black_animations.assigned_animation == "fade_in"):
			black_animations.play("fade_in")
		safety_timer.start()

func _on_lore_waittime_timeout() -> void:
	if end_timer.is_stopped():
		lore_animations.play("fade_in")
		if current_lore == 1:
			skip_fade_animation.play("skip_fade")
		if current_lore == 2:
			lore_lifetime.wait_time = 6
		if current_lore == 3:
			lore_lifetime.wait_time = 7.5
		if current_lore == 6:
			lore_lifetime.wait_time = 4
			lore_waittime.wait_time = 2
			black_animations.play("fade_in")
		if current_lore == 7:
			end_timer.start()

func _on_black_animations_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		if true_end:
			get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
		else:
			final_boss_video_player.visible = true
			intro_video_player.visible = false
			final_boss_video_player.play()
			black_animations.play("fade_out")

func _on_end_timer_timeout() -> void:
	true_end = true
	black.z_index = 99

func _on_safety_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
