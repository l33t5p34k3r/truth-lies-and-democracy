extends Node2D

var dragging = false
#signal dragging_stamp
signal stamping

#var approved = preload("res://Scenes/approved.tscn")

func _process(delta: float) -> void:
	if dragging:
		position = get_global_mouse_position()

#RIGHT MOUSE CLICK TO RELEASE STAMP managable in input system
	if Input.is_action_just_pressed("stamp_down") and dragging == true:
		dragging = false
		print("player tries to put down stamp")

#func _on_stamp_approved_stamping() -> void:
	#inst(get_global_mouse_position())

func _on_button_button_down() -> void:
	if dragging == true:
		stamping.emit()
		
	dragging = true
	#dragging_stamp.emit()

#func inst(pos):
	#var instance = approved.instantiate()
	#instance.position = pos
	#add_child(instance)

#func _on_stamping() -> void:
	#pass # Replace with function body.
