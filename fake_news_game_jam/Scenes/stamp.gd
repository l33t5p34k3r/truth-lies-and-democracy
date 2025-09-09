extends Node2D

var dragging = false
signal stamping

func _process(_delta: float) -> void:
	if dragging:
		position = get_global_mouse_position()
		#input_help.show()

#RIGHT MOUSE CLICK TO RELEASE STAMP managable in input system
	if Input.is_action_just_pressed("stamp_down") and dragging == true:
		dragging = false
		#input_help.hide()
		print("player tries to put down stamp")


func _on_button_button_down() -> void:
	if dragging == true:
		stamping.emit()

	dragging = true
