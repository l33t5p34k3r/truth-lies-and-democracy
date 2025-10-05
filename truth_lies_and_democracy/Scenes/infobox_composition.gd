extends CanvasLayer

@onready var headline_label = %TipHeadline
@onready var content_label = %TipContent



func set_content(metadata: Dictionary):
	print (metadata)
	print (content_label)
	print (headline_label)
	headline_label.text = metadata.get("headline")
	content_label.text = metadata.get("content")
	
func show_info(_screen_pos: Vector2, metadata: Dictionary):

	set_content(metadata)
	
	#var offset = Vector2(2, -2)
	#position = screen_pos + offset
	visible = true

func hide_info():
	visible = false
