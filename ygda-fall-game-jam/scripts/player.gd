extends CharacterBody2D

@onready var player_animated_sprite: AnimatedSprite2D = $PlayerAnimatedSprite
@onready var player_collision: CollisionShape2D = $PlayerCollision
var movement_speed: int

enum MovementSpeed {
	FAST,
	NORMAL,
	SLOW
}

enum CooldownLength {
	FAST,
	NORMAL,
	SLOW
}
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_movement_speed(new_movement_speed: MovementSpeed) -> void:
	if new_movement_speed == MovementSpeed.FAST:
		movement_speed = 1000
	elif new_movement_speed == MovementSpeed.NORMAL:
		movement_speed = 500
	elif new_movement_speed == MovementSpeed.SLOW:
		movement_speed = 250
	else:
		push_error("Invalid movement speed set.")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass
