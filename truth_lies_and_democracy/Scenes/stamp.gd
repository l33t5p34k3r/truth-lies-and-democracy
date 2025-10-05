class_name Stamp
extends Node2D

var dragging = false
signal stamping

func _process(_delta: float) -> void:
	if dragging:
		position = get_global_mouse_position()
		#input_help.show()
var overlapping_paper: Array[Paper] = []

func _ready():
	z_index = 101

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is OverlapArea and area.root_node is Paper:
		overlapping_paper.append(area.root_node)

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area is OverlapArea:
		overlapping_paper.erase(area.root_node)

func _input(event):
	if event.is_action_pressed("stamp_down"):
		if overlapping_paper:
			$AudioStreamPlayer.play()
			var stamp_texture = $Sprite2D.texture
			for node in overlapping_paper:
				#var contact_local_pos = node.to_local(global_position)
				var contact_local_pos = node.content.to_local(global_position)
				node.add_stamp_sprite(stamp_texture, contact_local_pos)
