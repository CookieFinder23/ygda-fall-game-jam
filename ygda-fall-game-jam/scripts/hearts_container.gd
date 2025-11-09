extends HFlowContainer
const HEART_GUI = preload("res://scenes/heart_gui.tscn")

func _ready() -> void:
	set_max_hearts(6)

func set_max_hearts(max_hearts: int):
	for i in range(max_hearts):
		add_child(HEART_GUI.instantiate())

func update_hearts(health: int):
	if health >= 0:
		var hearts = get_children()
		
		for i in range(health):
			hearts[i].update(true)
			
		for i in range(health, hearts.size()):
			hearts[i].update(false)
		
