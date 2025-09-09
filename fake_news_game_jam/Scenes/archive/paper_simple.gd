extends Sprite2D

var dragging = false

var approved = preload("res://Scenes/approved.tscn")
var declined = preload("res://Scenes/declined.tscn")

func _process(delta: float) -> void:
	if dragging:
		position = get_global_mouse_position()

	if Input.is_action_just_pressed("stamp_down") and dragging == true:
		dragging = false
		print("player tries to put down stamp")

func _on_stamp_approved_stamping():
	var mouse_pos = get_global_mouse_position()
	if _is_inside(mouse_pos):
		inst(mouse_pos, true)  # true = approved

func _on_stamp_decline_stamping():
	var mouse_pos = get_global_mouse_position()
	if _is_inside(mouse_pos):
		inst(mouse_pos, false) # false = declined

func _on_button_button_down() -> void:
	dragging = true

func inst(pos: Vector2, approved_stamp: bool):
	var instance
	if approved_stamp:
		instance = approved.instantiate()
	else:
		instance = declined.instantiate()

	instance.position = to_local(pos)  # convert to local coords
	add_child(instance)

# helper function to check if mouse is over the paper
func _is_inside(mouse_pos: Vector2) -> bool:
	var local = to_local(mouse_pos)
	var tex_size = texture.get_size()
	var half = tex_size * 0.5
	return local.x > -half.x and local.x < half.x and local.y > -half.y and local.y < half.y
