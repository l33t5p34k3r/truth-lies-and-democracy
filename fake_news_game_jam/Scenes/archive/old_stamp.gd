extends Node2D

@export var stamp_texture: Texture2D
@export var stamp_label: String = "APPROVED"

func _on_area_entered(area):
	if area is Sprite2D and area.has_method("receive_stamp"):
		area.receive_stamp(global_position, stamp_texture, stamp_label)
