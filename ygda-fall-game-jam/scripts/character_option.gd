extends AnimatedSprite2D
@onready var character_option_sprite: AnimatedSprite2D = $CharacterOptionSprite
@onready var character_option_area: Area2D = $CharacterOptionArea

var type: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play(type)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Global.picking_character == false:
		queue_free()

func _on_character_option_area_body_entered(body: Node2D) -> void:
	Global.player_reference.add_character(type)
	Global.picking_character = false
	Global.begin_next_wave = true
	
