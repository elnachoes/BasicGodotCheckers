extends Position2D

export var position_y : int = 0
export var position_x : int = 0

func toggleVisible(toggleVisible : bool) -> void:
	if (toggleVisible):
		show()
	if (not toggleVisible):
		hide()

func _on_Area2D_input_event(_viewport, event, _shape_idx) -> void:
	if (event is InputEventMouseButton):
		if (event.button_index == BUTTON_LEFT and event.pressed == true):
			get_tree().call_group("Gamestate", "setSelectedPosition", self)

