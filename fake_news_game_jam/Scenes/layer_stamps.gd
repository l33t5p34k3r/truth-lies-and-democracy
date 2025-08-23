extends Node2D

var approved = preload("res://Scenes/approved.tscn")
var declined = preload("res://Scenes/declined.tscn")

@export var paper: Sprite2D   #<---- NEEDS THE text.size of the spawned papers

func _on_stamp_approved_stamping():
	var mouse_pos = get_global_mouse_position()
	if _is_inside(mouse_pos):
		inst(mouse_pos, true)  # true = approved


func _on_stamp_decline_stamping():
	var mouse_pos = get_global_mouse_position()
	if _is_inside(mouse_pos):
		inst(mouse_pos, false) # false = declined

func inst(pos: Vector2, approved_stamp: bool):
	var instance
	if approved_stamp:
		instance = approved.instantiate()
	else:
		instance = declined.instantiate()

	instance.position = to_local(pos)  # convert to local coords
	add_child(instance)

func _is_inside(mouse_pos: Vector2) -> bool:
	if paper == null or paper.texture == null:
		return false
	var local = paper.to_local(mouse_pos)
	var tex_size = paper.texture.get_size()
	var half = tex_size * 0.5
	return local.x > -half.x and local.x < half.x and local.y > -half.y and local.y < half.y
