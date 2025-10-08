extends CanvasLayer

@onready var headline_label = %TipHeadline
@onready var content_label = %TipContent

# clickable object
@export var target_click_node: Area2D = null
#data object (f.e. paper)
@export var target_data_node: Node2D = null
@export var drag_component: Node2D = null


# TODO: this will not be called if another paper is now highlighted

func _ready():

	target_click_node.mouse_entered.connect(_on_HoverArea_mouse_entered)
	target_click_node.mouse_exited.connect(_on_HoverArea_mouse_exited)
	
	visible = false


func _on_HoverArea_mouse_entered():
	
	#TODO: check all the time if topmost_body
	if not drag_component.is_being_dragged and drag_component.is_topmost_body_at_position(target_data_node.get_global_mouse_position()):
		
		#TODO: add to highlighting_component
		#target_scale = hover_scale
		
		var metadata = {
			"headline": target_data_node.paper_headline,
			"content": target_data_node.paper_content
		}

		show_info(target_data_node.global_position, metadata)
		
func _on_HoverArea_mouse_exited():
	if not drag_component.is_being_dragged:
		#TODO: add to highlighting_component
		#target_scale = normal_scale
		hide_info()


func set_content(metadata: Dictionary):
	headline_label.text = metadata.get("headline")
	content_label.text = metadata.get("content")
	
func show_info(_screen_pos: Vector2, metadata: Dictionary):

	set_content(metadata)
	
	visible = true

func hide_info():
	visible = false
