extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area2D = $Hitbox
@onready var _3d: Sprite2D = $"3D"
var is_attack: bool
var stun_time: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("spin")
	if not is_attack:
		scale = Vector2(0.5, 0.5)
		_3d.visible = false
		stun_time = 0.25
		
func _physics_process(delta: float) -> void:
	if not is_attack:
		scale += Vector2(1.5, 1.5) * delta

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_attack:
		body.take_damage(3)
		stun_time = 1
	body.stun(stun_time)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
