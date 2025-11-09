extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area2D = $Hitbox
@onready var _3d: Sprite2D = $"3D"
@onready var damage_audio: AudioStreamPlayer2D = $DamageAudio
@onready var world: Node = $".."

var is_attack: bool
var stun_time: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("spin")
	if not is_attack:
		scale = Vector2(0.5, 0.5)
		_3d.visible = false
		stun_time = 0.25
		hitbox.collision_layer = 2
		
func _physics_process(delta: float) -> void:
	if not is_attack:
		scale += Vector2(1.5, 1.5) * delta

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_attack:
		body.take_damage(3)
		Global.deal_damage_audio_reference.play()
		stun_time = 1
	body.stun(stun_time)

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
