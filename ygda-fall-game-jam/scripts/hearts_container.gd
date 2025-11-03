extends HBoxContainer
const HEART_GUI = preload("res://scenes/heart_gui.tscn")

func _ready() -> void:
	set_max_hearts(3)

func set_max_hearts(max: int):
	for i in range(max):
		add_child(HEART_GUI.instantiate())

func update_hearts(health: int):
	if health >= 0:
		var hearts = get_children()
		
		for i in range(health):
			hearts[i].update(true)
			
		for i in range(health, hearts.size()):
			hearts[i].update(false)
		
