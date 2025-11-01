extends Node
@onready var projectile: AnimatedSprite2D = $"."

var speed: int
var type: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	projectile.play(type)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	projectile.position += projectile.transform.x * speed * delta

func _on_hitbox_body_entered(body: Node2D) -> void:
	queue_free()
